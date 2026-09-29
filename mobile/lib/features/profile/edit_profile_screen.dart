import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/auth/verify_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  List<Map<String, dynamic>> languages = [];
  List<Map<String, dynamic>> avatars = [];
  int? nativeLanguage;
  int? chosenLanguage;
  int? avatarId;
  String? avatarUrl;
  String currentEmail = '';
  bool loading = true;
  bool saving = false;
  String? error;
  String? notice;
  String? pendingEmail;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final responses = await Future.wait([luminApi.me(), luminApi.languages(), luminApi.avatars()]);
    if (!mounted) return;

    if (!responses[0].ok) {
      setState(() {
        loading = false;
        error = responses[0].error;
      });
      return;
    }

    final me = responses[0].map;
    final native = me['nativeLanguage'];
    final chosen = me['chosenLanguage'];
    final avatar = me['avatar'];
    final pending = me['pendingEmail'];

    setState(() {
      loading = false;
      nameController.text = '${me['name'] ?? ''}';
      emailController.text = '${me['email'] ?? ''}';
      currentEmail = '${me['email'] ?? ''}';
      if (native is Map && native['id'] is int) nativeLanguage = native['id'] as int;
      if (chosen is Map && chosen['id'] is int) chosenLanguage = chosen['id'] as int;
      if (avatar is Map && avatar['id'] is int) avatarId = avatar['id'] as int;
      if (avatar is Map && avatar['imgUrl'] is String) avatarUrl = avatar['imgUrl'] as String;
      pendingEmail = pending is String && pending.isNotEmpty ? pending : null;
      if (responses[1].ok) {
        languages = responses[1].list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      if (responses[2].ok) {
        avatars = responses[2].list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    });
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      setState(() => error = 'O nome não pode ficar vazio.');
      return;
    }

    final body = <String, dynamic>{};

    body['name'] = name;
    if (email != currentEmail) body['email'] = email;
    if (nativeLanguage != null) body['nativeLanguage'] = nativeLanguage;
    if (chosenLanguage != null) body['chosenLanguage'] = chosenLanguage;

    if (body.isEmpty) {
      setState(() => error = 'Nada para atualizar.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
      notice = null;
    });

    final response = await luminApi.updateMe(body);

    if (!mounted) return;
    setState(() => saving = false);

    if (!response.ok) {
      setState(() => error = response.error);
      return;
    }

    final emailChanged = email != currentEmail;
    final updated = response.map;
    final newEmail = '${updated['email'] ?? currentEmail}';

    setState(() {
      currentEmail = newEmail;
      emailController.text = newEmail;
      if (emailChanged) {
        notice = 'Enviamos um código para $email. Confirme para concluir a troca.';
        pendingEmail = email;
      } else {
        notice = 'Dados atualizados.';
      }
    });

    if (emailChanged) {
      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => VerifyScreen(
            email: email,
            title: 'Confirmar novo e-mail',
            onVerified: () => Navigator.of(context).pop(true),
          ),
        ),
      );
      if (!mounted) return;
      if (confirmed == true) {
        setState(() {
          pendingEmail = null;
          notice = 'E-mail atualizado com sucesso.';
        });
        await load();
      }
    }
  }

  Future<void> pickAvatar() async {
    if (avatars.isEmpty) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: LuminColors.panel,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final avatar in avatars)
              if (avatar['id'] is int)
                ListTile(
                  onTap: () => Navigator.of(context).pop(avatar['id'] as int),
                  leading: avatar['imgUrl'] is String
                      ? LuminAvatar(imgUrl: '${avatar['imgUrl']}', name: '${avatar['name'] ?? ''}', radius: 18)
                      : LuminAvatar(imgUrl: null, name: '${avatar['name'] ?? ''}', radius: 18),
                  title: Text('${avatar['name'] ?? ''}'),
                  trailing: avatar['id'] == avatarId ? const Icon(Icons.check, color: LuminColors.magenta) : null,
                ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      saving = true;
      error = null;
    });

    final response = await luminApi.changeAvatar(selected);
    if (!mounted) return;
    setState(() => saving = false);

    if (response.ok) {
      setState(() {
        avatarId = selected;
        final match = avatars.where((a) => a['id'] == selected).toList();
        if (match.isNotEmpty && match.first['imgUrl'] is String) {
          avatarUrl = match.first['imgUrl'] as String;
        }
        notice = 'Avatar atualizado.';
      });
    } else {
      setState(() => error = response.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LuminPage(child: Center(child: CircularProgressIndicator()));
    }

    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Editar dados'),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: saving ? () {} : pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  LuminAvatar(imgUrl: avatarUrl, name: nameController.text, radius: 40),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: LuminColors.magenta,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: LuminColors.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              avatars.isEmpty ? 'Toque para trocar' : 'Toque na imagem para trocar',
              style: const TextStyle(color: LuminColors.muted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 20),
          LuminField(label: 'Nome de usuário', controller: nameController),
          const SizedBox(height: 12),
          LuminField(label: 'E-mail', controller: emailController, keyboardType: TextInputType.emailAddress),
          if (pendingEmail != null) ...[
            const SizedBox(height: 8),
            Text(
              'E-mail pendente: $pendingEmail',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Língua nativa', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lang in languages)
                ChoiceChip(
                  label: Text('${lang['name'] ?? ''}'),
                  selected: lang['id'] == nativeLanguage,
                  onSelected: (_) {
                    final id = lang['id'];
                    if (id is int) setState(() => nativeLanguage = id);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Idioma de estudo', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lang in languages)
                ChoiceChip(
                  label: Text('${lang['name'] ?? ''}'),
                  selected: lang['id'] == chosenLanguage,
                  onSelected: (_) {
                    final id = lang['id'];
                    if (id is int) setState(() => chosenLanguage = id);
                  },
                ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          if (notice != null) ...[
            const SizedBox(height: 14),
            Text(notice!, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
          ],
          const SizedBox(height: 28),
          LuminButton(
            label: saving ? 'Salvando...' : 'Salvar alterações',
            onPressed: saving ? () {} : save,
          ),
        ],
      ),
    );
  }
}
