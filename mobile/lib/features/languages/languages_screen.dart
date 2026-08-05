import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Idiomas',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          LuminField(label: 'Pesquisar idiomas'),
          SizedBox(height: 16),
          Text(
            'Recentes',
            style: TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
          SizedBox(height: 8),
          LanguageTile(code: 'EN', label: 'Inglês'),
          LanguageTile(code: 'ES', label: 'Espanhol'),
          SizedBox(height: 14),
          Text(
            'Todos os idiomas',
            style: TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
          SizedBox(height: 8),
          LanguageTile(code: 'FR', label: 'Francês'),
          LanguageTile(code: 'DE', label: 'Alemão'),
          LanguageTile(code: 'IT', label: 'Italiano'),
          LanguageTile(code: 'ZH', label: 'Chinês'),
          LanguageTile(code: 'KO', label: 'Coreano'),
          LanguageTile(code: 'JA', label: 'Japonês'),
        ],
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key, required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: LuminColors.panelLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                code,
                style: const TextStyle(
                  color: LuminColors.magenta,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
