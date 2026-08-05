import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/profile/progress_screen.dart';
import 'package:mobile/features/profile/saved_words_screen.dart';
import 'package:mobile/features/profile/settings_screen.dart';
import 'package:mobile/features/translation/translation_history_screen.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          const Center(
            child: CircleAvatar(
              radius: 52,
              backgroundColor: LuminColors.text,
              child: Icon(
                Icons.person,
                color: LuminColors.background,
                size: 70,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Beatriz Galdino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          const Center(
            child: Text(
              'Nível N2',
              style: TextStyle(
                color: LuminColors.magenta,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: ProfileStat(value: '128', label: 'Palavras aprendidas'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ProfileStat(value: '12', label: 'Dias de rotina'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsRow(
            label: 'Meu progresso',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
          ),
          SettingsRow(
            label: 'Histórico',
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
