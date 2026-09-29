import 'package:flutter/material.dart';
import 'package:mobile/core/models/word_entry.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  final searchController = TextEditingController();
  List<WordEntry> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load(null);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load(String? search) async {
    setState(() {
      loading = true;
      error = null;
    });
    final response = await luminApi.words(
      saved: true,
      search: (search == null || search.trim().isEmpty) ? null : search.trim(),
      page: 0,
      size: 30,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
      if (!response.ok) {
        error = response.error;
        return;
      }
      items = WordEntry.fromContent(response.map);
    });
  }

  void openDetail(WordEntry entry) {
    final id = entry.id;
    if (id == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: id)))
        .then((_) => load(searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Palavras salvas'),
          const SizedBox(height: 14),
          LuminField(label: 'Buscar palavra salva', controller: searchController),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => load(searchController.text),
              child: const Text('Buscar'),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            )
          else if (items.isEmpty)
            const Center(
              child: Text(
                'Nenhuma palavra salva ainda.',
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              ),
            )
          else
            for (final entry in items)
              SavedWordTile(
                original: entry.original,
                translated: entry.translated,
                detail: savedDetail(entry),
                onTap: () => openDetail(entry),
              ),
        ],
      ),
    );
  }

  String savedDetail(WordEntry entry) {
    final parts = <String>[];
    if (entry.categoryName.isNotEmpty) parts.add(entry.categoryName);
    if (entry.correctAnswers > 0 || entry.incorrectAnswers > 0) {
      parts.add('${entry.correctAnswers} acertos / ${entry.incorrectAnswers} erros');
    }
    return parts.isEmpty ? 'Sem exercícios ainda' : parts.join(' · ');
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
                  Text(original, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(translated, style: const TextStyle(color: LuminColors.text)),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(color: LuminColors.muted, fontSize: 12),
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
