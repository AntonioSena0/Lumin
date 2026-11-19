import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/core/i18n/i18n.dart';

const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

class GoogleAuthResult {
  const GoogleAuthResult({required this.loggedIn, this.pending});

  final bool loggedIn;
  final OAuthPendingProfile? pending;
}

class OAuthPendingProfile {
  const OAuthPendingProfile({
    required this.email,
    required this.name,
    required this.idToken,
  });

  final String email;
  final String name;
  final String idToken;
}

class GoogleAuthService {
  GoogleAuthService._();

  static bool _ready = false;

  static bool get isConfigured => googleClientId.isNotEmpty;

  static Future<void> ensureInitialized() async {
    if (_ready) return;
    await GoogleSignIn.instance.initialize(
      clientId: googleClientId.isEmpty ? null : googleClientId,
      serverClientId: googleClientId.isEmpty ? null : googleClientId,
    );
    _ready = true;
  }

  static Future<GoogleAuthResult> login() async {
    try {
      await ensureInitialized();

      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();

      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw Exception(tr('O Google não devolveu um token de identificação.'));
      }

      final response = await luminApi.oauth(provider: 'GOOGLE', idToken: idToken);

      if (response.status == 202) {
        final pending = response.map;
        return GoogleAuthResult(
          loggedIn: false,
          pending: OAuthPendingProfile(
            email: '${pending['email'] ?? ''}',
            name: '${pending['name'] ?? ''}',
            idToken: idToken,
          ),
        );
      }

      if (response.ok) {
        return const GoogleAuthResult(loggedIn: true);
      }

      throw Exception(response.error);
    } on GoogleSignInException catch (e) {
      throw Exception(readableError(e.code));
    }
  }

  static String readableError(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return tr('O client ID do Google não está configurado corretamente neste build.');
      case GoogleSignInExceptionCode.userMismatch:
        return tr('Nenhuma conta Google disponível no aparelho.');
      case GoogleSignInExceptionCode.providerConfigurationError:
        return tr('O provedor do Google não está configurado no aparelho.');
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return tr('Login cancelado.');
      case GoogleSignInExceptionCode.uiUnavailable:
        return tr('Não foi possível abrir a tela do Google.');
      default:
        return tr('Não foi possível concluir o login social.');
    }
  }

  static void disconnect() {
    GoogleSignIn.instance.disconnect();
  }
}

class GoogleRegisterScreen extends StatefulWidget {
  const GoogleRegisterScreen({super.key, required this.pending});

  final OAuthPendingProfile pending;

  @override
  State<GoogleRegisterScreen> createState() => _GoogleRegisterScreenState();
}

class _GoogleRegisterScreenState extends State<GoogleRegisterScreen> {
  final nameController = TextEditingController();
  List<Map<String, dynamic>> languages = [];
  int? nativeLanguage;
  int? chosenLanguage;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.pending.name;
    load();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final response = await luminApi.languages();
    if (!mounted) return;
    setState(() {
      languages = response.list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (languages.length >= 2) {
        nativeLanguage ??= languages.first['id'] as int?;
        chosenLanguage ??= languages[1]['id'] as int?;
      } else if (languages.length == 1) {
        nativeLanguage ??= languages.first['id'] as int?;
        chosenLanguage ??= nativeLanguage;
      }
    });
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    if (name.isEmpty || nativeLanguage == null || chosenLanguage == null) {
      setState(() => error = tr('Preencha o nome e escolha os idiomas.'));
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });

    final response = await luminApi.registerOauth(
      name: name,
      nativeLanguage: nativeLanguage!,
      chosenLanguage: chosenLanguage!,
      provider: 'GOOGLE',
      idToken: widget.pending.idToken,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (response.ok) {
      Navigator.of(context).pop(true);
      return;
    }

    if (response.status == 409) {
      setState(() => error = tr('Essa conta do Google já está vinculada.'));
      return;
    }

    setState(() => error = response.error);
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Quase lá'),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            t('${widget.pending.email} ainda não tem conta no Lumin.', "${widget.pending.email} doesn't have a Lumin account yet."),
            style: const TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 22),
          LuminField(label: tr('Nome de usuário'), controller: nameController),
          const SizedBox(height: 14),
          LanguageChoice(
            label: tr('Língua nativa'),
            languages: languages,
            selectedId: nativeLanguage,
            onSelect: (id) => setState(() => nativeLanguage = id),
          ),
          const SizedBox(height: 14),
          LanguageChoice(
            label: tr('Idioma de estudo'),
            languages: languages,
            selectedId: chosenLanguage,
            onSelect: (id) => setState(() => chosenLanguage = id),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 28),
          LuminButton(
            label: loading ? tr('Criando conta...') : tr('Criar conta'),
            onPressed: loading ? () {} : submit,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr('Cancelar')),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageChoice extends StatelessWidget {
  const LanguageChoice({
    super.key,
    required this.label,
    required this.languages,
    required this.selectedId,
    required this.onSelect,
  });

  final String label;
  final List<Map<String, dynamic>> languages;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lang in languages)
              ChoiceChip(
                label: Text('${lang['name'] ?? ''}'),
                selected: lang['id'] == selectedId,
                onSelected: (_) {
                  final id = lang['id'];
                  if (id is int) onSelect(id);
                },
              ),
          ],
        ),
      ],
    );
  }
}
