import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class TranslationHistoryScreen extends StatelessWidget {
  const TranslationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Histórico de traduções'),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: HistoryTab(label: 'Todas', selected: true)),
              SizedBox(width: 8),
              Expanded(child: HistoryTab(label: 'Salvas', selected: false)),
            ],
          ),
          const SizedBox(height: 14),
          HistoryItem(
            original: 'BUTTER',
            translated: 'Manteiga',
            saved: true,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WordDetailScreen())),
          ),
          HistoryItem(
            original: 'MELLOW',
            translated: 'Adocicado(a)',
            saved: true,
            onTap: () {},
          ),
          HistoryItem(
            original: 'COFFEE',
            translated: 'Café',
            saved: false,
            onTap: () {},
          ),
          const SizedBox(height: 180),
          const Center(
            child: Text(
              'Suas traduções salvas aparecerão aqui para você revisar e aprender.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LuminColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: selected ? LuminColors.magenta : LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.original,
    required this.translated,
    required this.saved,
    required this.onTap,
  });

  final String original;
  final String translated;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LuminColors.panelLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    original,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text('→ $translated'),
                ],
              ),
            ),
            Icon(
              saved ? Icons.star : Icons.star_border,
              color: LuminColors.text,
            ),
          ],
        ),
      ),
    );
  }
}
