import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SavedWordsScreen extends StatelessWidget {
  const SavedWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Palavras salvas'),
          const SizedBox(height: 14),
          const LuminField(label: 'Buscar palavra salva'),
          const SizedBox(height: 16),
          const Text(
            'Alimentos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SavedWordTile(
            original: 'Butter',
            translated: 'Manteiga',
            detail: 'Praticada 4 vezes',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WordDetailScreen())),
          ),
          SavedWordTile(
            original: 'Coffee',
            translated: 'Café',
            detail: 'Adicionada hoje',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          const Text(
            'Casa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SavedWordTile(
            original: 'Chair',
            translated: 'Cadeira',
            detail: 'Precisa revisar',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SavedWordTile extends StatelessWidget {
  const SavedWordTile({
    super.key,
    required this.original,
    required this.translated,
    required this.detail,
    required this.onTap,
  });

  final String original;
  final String translated;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: LuminColors.panelLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.star, color: LuminColors.magenta),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    original,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    translated,
                    style: const TextStyle(color: LuminColors.text),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: LuminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
