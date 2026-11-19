import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/i18n.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/language_flag.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  /// Cria o estado da busca de pessoas.
  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final searchController = TextEditingController();

  /// Libera o controlador do campo de busca.
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Mostra a lista de pessoas filtrada pelo termo digitado.
  @override
  Widget build(BuildContext context) {
    return UserListScreen(
      key: ValueKey(searchController.text),
      title: tr('Pessoas'),
      load: () => luminApi.users(q: searchController.text.trim(), size: 50),
      header: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: tr('Buscar pessoas'),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({
    super.key,
    required this.title,
    required this.load,
    this.header,
  });

  final String title;
  final Future<ApiResult> Function() load;
  final Widget? header;

  /// Cria o estado da lista de usuários.
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>>? users;
  String? error;

  /// Carrega a lista ao abrir a tela.
  @override
  void initState() {
    super.initState();
    load();
  }

  /// Busca os usuários e guarda o conteúdo da página ou o erro.
  Future<void> load() async {
    final response = await widget.load();
    if (!mounted) return;
    setState(() {
      error = response.ok ? null : response.error;
      final content = response.map['content'];
      users = content is List
          ? content.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
    });
  }

  /// Mostra carregamento, erro, lista vazia ou os usuários encontrados.
  @override
  Widget build(BuildContext context) {
    final list = users;
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: widget.title),
          if (widget.header != null) ...[
            const SizedBox(height: 12),
            widget.header!,
          ],
          const SizedBox(height: 16),
          if (list == null)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Text(error!, style: const TextStyle(color: Colors.redAccent))
          else if (list.isEmpty)
            Center(
              child: Text(
                tr('Nenhuma pessoa encontrada.'),
                style: const TextStyle(color: LuminColors.muted),
              ),
            )
          else
            for (final user in list)
              if (user['id'] is int)
                UserTile(
                  user: user,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(userId: user['id'] as int),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onTap});

  final Map<String, dynamic> user;
  final VoidCallback onTap;

  /// Mostra avatar, nome e bandeira do idioma de estudo do usuário.
  @override
  Widget build(BuildContext context) {
    final avatar = user['avatar'];
    final chosen = user['chosenLanguage'];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            LuminAvatar(
              imgUrl: avatar is Map ? '${avatar['imgUrl'] ?? ''}' : null,
              name: '${user['name'] ?? ''}',
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${user['name'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (chosen is Map) LanguageFlag(code: '${chosen['code'] ?? ''}', size: 16),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});

  final int userId;

  /// Cria o estado do perfil público.
  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? profile;
  String? error;
  bool busy = false;

  /// Carrega o perfil ao abrir a tela.
  @override
  void initState() {
    super.initState();
    load();
  }

  /// Busca o perfil público do usuário.
  Future<void> load() async {
    final response = await luminApi.userProfile(widget.userId);
    if (!mounted) return;
    setState(() {
      profile = response.ok ? response.map : null;
      error = response.ok ? null : response.error;
    });
  }

  /// Segue ou deixa de seguir o usuário e recarrega o perfil.
  Future<void> toggleFollow() async {
    final current = profile;
    if (current == null || busy) return;
    final following = current['followedByMe'] == true;
    setState(() => busy = true);
    final response = following
        ? await luminApi.unfollow(widget.userId)
        : await luminApi.follow(widget.userId);
    if (!mounted) return;
    setState(() => busy = false);
    if (!response.ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
      return;
    }
    await load();
  }

  /// Mostra o perfil público ou o estado de carregamento e erro.
  @override
  Widget build(BuildContext context) {
    final data = profile;
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: tr('Perfil')),
          const SizedBox(height: 16),
          if (data != null)
            PublicProfileView(
              profile: data,
              busy: busy,
              onToggleFollow: toggleFollow,
              onOpenFollowers: () => openList(tr('Seguidores'), () => luminApi.followers(widget.userId)),
              onOpenFollowing: () => openList(tr('Seguindo'), () => luminApi.following(widget.userId)),
            )
          else if (error != null)
            Text(error!, style: const TextStyle(color: Colors.redAccent))
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Abre a lista de seguidores ou seguindo e recarrega as contagens ao voltar.
  void openList(String title, Future<ApiResult> Function() load) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => UserListScreen(title: title, load: load)))
        .then((_) => this.load());
  }
}

class PublicProfileView extends StatelessWidget {
  const PublicProfileView({
    super.key,
    required this.profile,
    required this.onToggleFollow,
    this.onOpenFollowers,
    this.onOpenFollowing,
    this.busy = false,
  });

  final Map<String, dynamic> profile;
  final VoidCallback onToggleFollow;
  final VoidCallback? onOpenFollowers;
  final VoidCallback? onOpenFollowing;
  final bool busy;

  /// Mostra avatar, nome, idiomas, contagens e o botão de seguir quando não é o próprio perfil.
  @override
  Widget build(BuildContext context) {
    final avatar = profile['avatar'];
    final native = profile['nativeLanguage'];
    final chosen = profile['chosenLanguage'];
    final followed = profile['followedByMe'] == true;
    final isMe = profile['me'] == true;
    final name = '${profile['name'] ?? ''}';

    return Column(
      children: [
        LuminAvatar(
          imgUrl: avatar is Map ? '${avatar['imgUrl'] ?? ''}' : null,
          name: name,
          radius: 52,
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (native is Map) LanguageFlag(code: '${native['code'] ?? ''}', size: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 16, color: LuminColors.muted),
            ),
            if (chosen is Map) LanguageFlag(code: '${chosen['code'] ?? ''}', size: 18),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onOpenFollowers,
                child: ProfileStat(value: '${profile['followers'] ?? 0}', label: tr('Seguidores')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onOpenFollowing,
                child: ProfileStat(value: '${profile['following'] ?? 0}', label: tr('Seguindo')),
              ),
            ),
          ],
        ),
        if (!isMe) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: followed
                ? OutlinedButton(
                    onPressed: busy ? null : onToggleFollow,
                    child: Text(tr('Deixar de seguir')),
                  )
                : FilledButton(
                    onPressed: busy ? null : onToggleFollow,
                    style: FilledButton.styleFrom(backgroundColor: LuminColors.violet),
                    child: Text(tr('Seguir')),
                  ),
          ),
        ],
      ],
    );
  }
}
