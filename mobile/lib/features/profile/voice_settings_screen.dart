import 'package:flutter/material.dart';
import 'package:mobile/features/profile/settings_language_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BackTitle(title: 'Voz'),
          SizedBox(height: 16),
          PreferenceOption(
            title: 'Feminina',
            description: 'Voz padrão para pronúncia e exemplos',
            selected: true,
          ),
          PreferenceOption(
            title: 'Masculina',
            description: 'Alternativa para treinar escuta com outro timbre',
            selected: false,
          ),
          PreferenceOption(
            title: 'Sistema',
            description: 'Usa a voz configurada no dispositivo',
            selected: false,
          ),
        ],
      ),
    );
  }
}
