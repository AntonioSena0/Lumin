import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BackTitle(title: 'Notificações'),
          SizedBox(height: 16),
          NotificationStatusPanel(),
          SizedBox(height: 16),
          PreferenceOption(
            title: 'Rotina diária',
            description: 'Um lembrete curto para continuar aprendendo',
            selected: true,
          ),
          PreferenceOption(
            title: 'Revisão de palavras',
            description:
                'Avisos quando uma palavra salva precisa ser praticada',
            selected: true,
          ),
          PreferenceOption(
            title: 'Novidades sociais',
            description: 'Seguidores e interações quando a API social existir',
            selected: false,
          ),
        ],
      ),
    );
  }
}

class NotificationStatusPanel extends StatelessWidget {
  const NotificationStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_active, color: LuminColors.magenta),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'As notificações devem reforçar rotina, não competição.',
              style: TextStyle(color: LuminColors.muted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
