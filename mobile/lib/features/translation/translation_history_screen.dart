import 'package:flutter/material.dart';
import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class TranslationHistoryScreen extends StatefulWidget {
  const TranslationHistoryScreen({super.key});

  @override
  State<TranslationHistoryScreen> createState() => _TranslationHistoryScreenState();
}

class _TranslationHistoryScreenState extends State<TranslationHistoryScreen> {
  bool onlySaved = false;
  List<UserWordModel> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final result = await luminRepository.words(saved: onlySaved ? true : null, page: 0, size: 30);
    if (!mounted) return;
    setState(() {
      loading = false;
      items = result.data?.content ?? [];
      if (!result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error)));
      }
    });
  }

  void openDetail(UserWordModel entry) {
    final id = entry.wordId;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: id)))
        .then((_) => load());
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Histórico de traduções'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: HistoryTab(
                  label: 'Todas',
                  selected: !onlySaved,
                  onTap: () {
                    setState(() => onlySaved = false);
                    load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HistoryTab(
                  label: 'Salvas',
                  selected: onlySaved,
                  onTap: () {
                    setState(() => onlySaved = true);
                    load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty)
            const Center(
              child: Text(
                'Suas traduções salvas aparecerão aqui para você revisar e aprender.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              ),
            )
          else
            for (final entry in items)
              HistoryItem(
                original: entry.original,
                translated: entry.translated,
                saved: entry.isSaved,
                onTap: () => openDetail(entry),
              ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? LuminColors.magenta : LuminColors.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
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
                  Text(original, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text('→ $translated'),
                ],
              ),
            ),
            Icon(saved ? Icons.star : Icons.star_border, color: LuminColors.text),
          ],
        ),
      ),
    );
  }
}
