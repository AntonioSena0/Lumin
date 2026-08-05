import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BackTitle(title: 'Idioma do app'),
          SizedBox(height: 16),
          PreferenceOption(
            title: 'Português',
            description: 'Interface principal do TCC',
            selected: true,
          ),
          PreferenceOption(
            title: 'Inglês',
            description: 'Preparado para internacionalização futura',
            selected: false,
          ),
          PreferenceOption(
            title: 'Espanhol',
            description: 'Pode entrar depois da entrega principal',
            selected: false,
          ),
        ],
      ),
    );
  }
}

class PreferenceOption extends StatelessWidget {
  const PreferenceOption({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
  });

  final String title;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? LuminColors.panelLight : LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? LuminColors.magenta : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: LuminColors.muted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? LuminColors.magenta : LuminColors.muted,
          ),
        ],
      ),
    );
  }
}
