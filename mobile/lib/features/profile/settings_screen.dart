import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/auth/welcome_screen.dart';
import 'package:mobile/features/profile/change_password_screen.dart';
import 'package:mobile/features/profile/notification_settings_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/features/profile/voice_settings_screen.dart';
import 'package:mobile/features/study/study_sessions_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String name = '';
  String? avatarUrl;
  String appLanguage = '';
  String notifications = '';
  String voice = '';
  String email = '';
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final results = await Future.wait([luminApi.me(), luminApi.settings()]);
    if (!mounted) return;
    if (!results[0].ok || !results[1].ok) {
      setState(() {
        loading = false;
        error = !results[0].ok ? results[0].error : results[1].error;
      });
      return;
    }
    setState(() {
      loading = false;
      final user = results[0].map;
      if (user['name'] is String) name = user['name'] as String;
      if (user['email'] is String) email = user['email'] as String;
      final avatar = user['avatar'];
      if (avatar is Map && avatar['imgUrl'] is String) {
        avatarUrl = avatar['imgUrl'] as String;
      }
      final settings = results[1].map;
      final lang = settings['appLanguage'];
      if (lang is Map && lang['name'] is String) {
        appLanguage = lang['name'] as String;
      } else if (settings['appLanguageId'] != null) {
        appLanguage = '${settings['appLanguageId']}';
      }
      if (settings['notifyDaily'] != null) {
        notifications = settings['notifyDaily'] == true ? 'Ativadas' : 'Desativadas';
      }
      if (settings['voice'] != null) {
        voice = '${settings['voice']}';
      }
    });
  }

  Future<void> logout() async {
    await luminApi.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Configurações'),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            SettingsErrorState(message: error!, onRetry: load)
          else ...[
            SettingsProfileHeader(name: name, email: email, avatarUrl: avatarUrl),
            const SizedBox(height: 18),
            const Text('Preferências', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            SettingsRow(
              label: 'Idioma do app',
              trailing: appLanguage,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsLanguageScreen()),
              ).then((_) => load()),
            ),
            SettingsRow(
              label: 'Notificações',
              trailing: notifications,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              ).then((_) => load()),
            ),
            SettingsRow(
              label: 'Voz',
              trailing: voice,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
              ).then((_) => load()),
            ),
            SettingsRow(
              label: 'Alterar senha',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),
            SettingsRow(
              label: 'Minhas sessões',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudySessionsScreen()),
              ),
            ),
            const SizedBox(height: 34),
            Center(
              child: TextButton(
                onPressed: logout,
                child: const Text('Sair da conta', style: TextStyle(color: LuminColors.danger)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key, this.name = '', this.email = '', this.avatarUrl});

  final String name;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          LuminAvatar(imgUrl: avatarUrl, name: name, radius: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '...' : name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (email.isNotEmpty)
                  Text(email, style: const TextStyle(color: LuminColors.muted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsErrorState extends StatelessWidget {
  const SettingsErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.cloud_off, color: LuminColors.danger, size: 36),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: LuminColors.danger, fontSize: 12)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    );
  }
}
