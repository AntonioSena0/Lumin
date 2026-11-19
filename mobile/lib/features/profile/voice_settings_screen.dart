import 'package:flutter/material.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/core/i18n/i18n.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  String selected = 'FEMALE';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response = await luminApi.settings();
    if (!mounted) return;
    final voice = response.map['voice'];
    if (response.ok && voice is String) setState(() => selected = voice);
  }

  Future<void> select(String value) async {
    final previous = selected;
    setState(() => selected = value);
    final response = await luminApi.updateSettings({'voice': value});
    if (!mounted) return;
    if (!response.ok) {
      setState(() => selected = previous);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: tr('Voz')),
          const SizedBox(height: 16),
          PreferenceOption(
            title: tr('Feminina'),
            description: tr('Voz padrão para pronúncia e exemplos'),
            selected: selected == 'FEMALE',
            onTap: () => select('FEMALE'),
          ),
          PreferenceOption(
            title: tr('Masculina'),
            description: tr('Alternativa para treinar escuta com outro timbre'),
            selected: selected == 'MALE',
            onTap: () => select('MALE'),
          ),
        ],
      ),
    );
  }
}
