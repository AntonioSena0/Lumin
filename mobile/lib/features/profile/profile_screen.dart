import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/repositories/lumin_repository.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/level_test/level_test_screen.dart';
import 'package:mobile/features/profile/edit_profile_screen.dart';
import 'package:mobile/features/profile/progress_screen.dart';
import 'package:mobile/features/profile/saved_words_screen.dart';
import 'package:mobile/features/profile/settings_screen.dart';
import 'package:mobile/features/study/study_sessions_screen.dart';
import 'package:mobile/features/translation/translation_history_screen.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String level = '';
  String practiced = '0';
  String saved = '0';
  String? avatarUrl;
  int sessionCount = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait<Object?>([
      luminApi.me(),
      luminRepository.profileSummary(),
      luminRepository.homeSummary(),
    ]);
    if (!mounted) return;
    setState(() {
      final user = (results[0] as ApiResult).map;
      if (user['name'] is String) name = user['name'] as String;
      final avatar = user['avatar'];
      if (avatar is Map && avatar['imgUrl'] is String) {
        avatarUrl = avatar['imgUrl'] as String;
      }
      final profileResult = results[1] as RepositoryResult<ProfileSummaryModel>;
      final data = profileResult.data;
      if (data != null) {
        practiced = '${data.practicedWords}';
        saved = '${data.savedWords}';
      }
      final homeResult = results[2] as RepositoryResult<HomeSummaryModel>;
      final home = homeResult.data;
      if (home != null) level = home.level;
    });
    final sessions = await luminApi.sessions(page: 0, size: 1);
    if (!mounted) return;
    final total = sessions.map['totalElements'];
    if (sessions.ok && total is num) setState(() => sessionCount = total.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 28),
          Center(
            child: LuminAvatar(imgUrl: avatarUrl, name: name, radius: 52),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name.isEmpty ? '...' : name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Center(
            child: Text(
              level.isEmpty ? '' : 'Nível $level',
              style: const TextStyle(
                color: LuminColors.magenta,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ProfileStat(value: practiced, label: 'Palavras praticadas'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ProfileStat(value: saved, label: 'Palavras salvas'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsRow(
            label: 'Editar dados',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ).then((_) => load()),
          ),
          SettingsRow(
            label: 'Meu progresso',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
          ),
          SettingsRow(
            label: 'Minhas sessões',
            trailing: sessionCount > 0 ? '$sessionCount' : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudySessionsScreen()),
            ),
          ),
          SettingsRow(
            label: 'Teste de nivelamento',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(              builder: (_) => const LevelTestScreen(canSkip: false)),
            ),
          ),
          SettingsRow(
            label: 'Histórico de traduções',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TranslationHistoryScreen(),
              ),
            ),
          ),
          SettingsRow(
            label: 'Palavras salvas',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SavedWordsScreen())),
          ),
          SettingsRow(
            label: 'Configurações',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: LuminColors.magenta,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: LuminColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(color: LuminColors.muted, fontSize: 12),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
