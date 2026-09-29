import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool daily = true;
  bool review = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response = await luminApi.settings();
    if (!mounted || !response.ok) return;
    setState(() {
      if (response.map['notifyDaily'] is bool) daily = response.map['notifyDaily'] as bool;
      if (response.map['notifyReview'] is bool) review = response.map['notifyReview'] as bool;
    });
  }

  Future<void> toggleDaily() async {
    final previous = daily;
    setState(() => daily = !daily);
    final response = await luminApi.updateSettings({'notifyDaily': daily});
    if (!mounted) return;
    if (!response.ok) {
      setState(() => daily = previous);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  Future<void> toggleReview() async {
    final previous = review;
    setState(() => review = !review);
    final response = await luminApi.updateSettings({'notifyReview': review});
    if (!mounted) return;
    if (!response.ok) {
      setState(() => review = previous);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Notificações'),
          const SizedBox(height: 16),
          const NotificationStatusPanel(),
          const SizedBox(height: 16),
          PreferenceOption(
            title: 'Rotina diária',
            description: 'Um lembrete curto para continuar aprendendo',
            selected: daily,
            onTap: toggleDaily,
          ),
          PreferenceOption(
            title: 'Revisão de palavras',
            description: 'Avisos quando uma palavra salva precisa ser praticada',
            selected: review,
            onTap: toggleReview,
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
