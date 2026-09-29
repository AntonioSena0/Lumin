import 'package:flutter/material.dart';
import 'package:mobile/core/models/word_entry.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/translation_history_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  List<WordEntry> myWords = [];
  List<Map<String, dynamic>> categories = [];
  List<WordEntry> results = [];
  bool searching = false;
  bool searchingNow = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final responses = await Future.wait([
      luminApi.words(saved: true, page: 0, size: 4),
      luminApi.categories(),
    ]);
    if (!mounted) return;
    setState(() {
      if (responses[0].ok) {
        myWords = WordEntry.fromContent(responses[0].map);
      } else {
        error = responses[0].error;
      }
      if (responses[1].ok) {
        categories = responses[1].list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    });
  }

  Future<void> search(String value) async {
    final term = value.trim();
    if (term.isEmpty) {
      setState(() {
        searching = false;
        results = [];
      });
      return;
    }
    setState(() {
      searchingNow = true;
      error = null;
    });

    final mine = await luminApi.words(search: term, page: 0, size: 20);
    if (!mounted) return;

    final found = WordEntry.fromContent(mine.map);
    if (mine.ok && found.isNotEmpty) {
      setState(() {
        searchingNow = false;
        results = found;
        searching = true;
      });
      return;
    }

    final catalog = await luminApi.catalogWords(page: 0, size: 60);
    if (!mounted) return;

    final matches = catalog.ok
        ? WordEntry.fromContent(catalog.map)
              .where(
                (e) =>
                    e.original.toLowerCase().contains(term.toLowerCase()) ||
                    e.translated.toLowerCase().contains(term.toLowerCase()),
              )
              .toList()
        : <WordEntry>[];

    setState(() {
      searchingNow = false;
      searching = true;
      results = matches;
      if (!mine.ok) error = mine.error;
    });
  }

  void openWord(WordEntry entry) {
    final id = entry.id;
    if (id == null) return;
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
          const Text('Explorar', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          LuminField(
            label: 'Pesquise palavras ou frases',
            controller: searchController,
            icon: Icons.search,
            onSubmitted: search,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: searchingNow ? () {} : () => search(searchController.text),
              child: Text(searchingNow ? 'Buscando...' : 'Buscar'),
            ),
          ),
          const SizedBox(height: 20),
          if (error != null) ...[
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 12),
          ],
          if (searching) ...[
            const Text('Resultados', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (results.isEmpty)
              const Text(
                'Nenhuma palavra encontrada.',
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              )
            else
              for (final entry in results)
                WordSearchTile(entry: entry, onTap: () => openWord(entry)),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Minhas palavras', style: TextStyle(fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TranslationHistoryScreen()),
                  ),
                  child: const Text('Ver tudo', style: TextStyle(color: LuminColors.magenta, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myWords.isEmpty)
              const Text(
                'Salve uma tradução com a câmera para vê-la aqui.',
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              )
            else
              Row(
                children: [
                  for (int i = 0; i < myWords.length && i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 5, right: i == 0 ? 5 : 0),
                        child: WordMiniCard(entry: myWords[i], onTap: () => openWord(myWords[i])),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 22),
            const Text('Traduzido por outros usuários', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const Text(
                'Nenhuma categoria disponível.',
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              )
            else
              for (final category in categories)
                CategoryRow(
                  icon: Icons.folder,
                  title: '${category['name'] ?? ''}',
                  subtitle: '${category['description'] ?? ''}',
                  onTap: () => openCategory(category),
                ),
          ],
        ],
      ),
    );
  }

  void openCategory(Map<String, dynamic> category) {
    final id = category['id'];
    if (id is! int) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryWordsScreen(categoryId: id, title: '${category['name'] ?? ''}'),
          ),
        )
        .then((_) => load());
  }
}

class CategoryWordsScreen extends StatefulWidget {
  const CategoryWordsScreen({super.key, required this.categoryId, required this.title, this.languageId});

  final int categoryId;
  final String title;
  final int? languageId;

  @override
  State<CategoryWordsScreen> createState() => _CategoryWordsScreenState();
}

class _CategoryWordsScreenState extends State<CategoryWordsScreen> {
  List<WordEntry> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response = widget.languageId == null
        ? await luminApi.categoryWords(categoryId: widget.categoryId)
        : await luminApi.words(
            categoryId: widget.categoryId == 0 ? null : widget.categoryId,
            languageId: widget.languageId,
            page: 0,
            size: 40,
          );
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) {
        items = WordEntry.fromContent(response.map);
      } else {
        error = response.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: widget.title),
          const SizedBox(height: 14),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))
          else if (items.isEmpty)
            const Text(
              'Nenhuma palavra encontrada.',
              style: TextStyle(color: LuminColors.muted, fontSize: 12),
            )
          else
            for (final entry in items)
              WordSearchTile(
                entry: entry,
                onTap: () {
                  final id = entry.id;
                  if (id == null) return;
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: id)))
                      .then((_) => load());
                },
              ),
        ],
      ),
    );
  }
}

class WordSearchTile extends StatelessWidget {
  const WordSearchTile({super.key, required this.entry, required this.onTap});

  final WordEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: LuminColors.panelLight, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.original, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text('→ ${entry.translated}'),
                  if (entry.categoryName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      entry.categoryName,
                      style: const TextStyle(color: LuminColors.muted, fontSize: 11),
                    ),
                  ],
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

class WordMiniCard extends StatelessWidget {
  const WordMiniCard({super.key, required this.entry, required this.onTap});

  final WordEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.categoryName.toUpperCase(),
              style: const TextStyle(color: LuminColors.magenta, fontSize: 10, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(entry.original, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(entry.translated, style: const TextStyle(color: LuminColors.muted, fontSize: 12)),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: LuminColors.magenta,
                child: Icon(Icons.play_arrow, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(9)),
        child: Row(
          children: [
            Icon(icon, color: LuminColors.magenta),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
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
