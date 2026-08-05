import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/auth/welcome_screen.dart';
import 'package:mobile/features/profile/notification_settings_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/features/profile/voice_settings_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Configurações'),
          const SizedBox(height: 16),
          const SettingsProfileHeader(),
          const SizedBox(height: 18),
          const Text(
            'Preferências',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SettingsRow(
            label: 'Idioma do app',
            trailing: 'Português',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsLanguageScreen()),
            ),
          ),
          SettingsRow(
            label: 'Notificações',
            trailing: 'Ativadas',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          SettingsRow(
            label: 'Voz',
            trailing: 'Feminina',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Conta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LuminColors.panel,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Os dados exibidos aqui ainda são locais. A integração com a API deve preencher nome, avatar e preferências.',
              style: TextStyle(color: LuminColors.muted, height: 1.35),
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (_) => false,
              ),
              child: const Text(
                'Sair da conta',
                style: TextStyle(color: LuminColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: LuminColors.text,
            child: Icon(Icons.person, color: LuminColors.background),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beatriz Galdino',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 2),
                Text(
                  'Nível N2',
                  style: TextStyle(color: LuminColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
