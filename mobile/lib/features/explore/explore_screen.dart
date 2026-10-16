import 'package:flutter/material.dart';
import 'package:mobile/core/models/word_entry.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/translation/translation_history_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

const String _font = 'Poppins';
const Color _accent = Color(0xFFC21BD6);

const TextStyle _sectionTitle = TextStyle(
  fontFamily: _font,
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: Colors.white,
  height: 1.35,
);

String _plain(String input) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  var out = input.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}

/// Ícone de cada categoria (usado em "Traduzido por outros usuários"
/// e também disponível para a tela inicial).
IconData exploreCategoryIcon(String name) {
  final key = _plain(name);
  bool has(List<String> words) => words.any(key.contains);

  if (has(['comod', 'casa', 'house', 'home'])) return Icons.home_work;
  if (has(['objeto', 'domestic'])) return Icons.chair;
  if (has(['animal'])) return Icons.pets;
  if (has(['veiculo', 'transporte', 'vehicle'])) return Icons.directions_car;
  if (has(['corpo', 'humano', 'body'])) return Icons.accessibility_new;
  if (has(['esporte', 'exercicio', 'sport', 'fitness'])) {
    return Icons.sports_soccer;
  }
  if (has(['lazer', 'entretenimento', 'leisure'])) return Icons.theater_comedy;
  if (has(['viage', 'turismo', 'travel'])) return Icons.flight;
  if (has(['compra', 'comercio', 'shop'])) return Icons.shopping_cart;
  if (has(['comunica'])) return Icons.forum;
  if (has(['jogo', 'videogame', 'game'])) return Icons.sports_esports;
  if (has(['culinaria', 'cozinha', 'cook'])) return Icons.restaurant_menu;
  if (has(['ferramenta', 'equipamento', 'tool'])) return Icons.build;
  if (has(['roupa', 'cloth'])) return Icons.checkroom;
  if (has(['aliment', 'comida', 'food'])) return Icons.restaurant;
  if (has(['bebida', 'drink'])) return Icons.local_cafe;
  if (has(['tecnolog', 'tech'])) return Icons.devices;
  if (has(['natureza', 'nature'])) return Icons.park;
  if (has(['estudo', 'educa'])) return Icons.menu_book;
  if (has(['arte', 'cultura'])) return Icons.palette_outlined;
  if (has(['saude', 'health'])) return Icons.health_and_safety_outlined;
  if (has(['trabalho', 'work'])) return Icons.work_outline;
  return Icons.category_outlined;
}

/// Texto de apoio da categoria: "1.2k traduções" quando a API informa a
/// contagem; caso contrário usa a descrição da categoria.
String categorySubtitle(Map<String, dynamic> category) {
  for (final key in const [
    'translationsCount',
    'translations',
    'wordsCount',
    'wordCount',
    'totalWords',
    'count',
  ]) {
    final v = category[key];
    if (v is int) {
      final text = v >= 1000
          ? '${(v / 1000).toStringAsFixed(1).replaceAll('.0', '')}k'
          : '$v';
      return '$text traduções';
    }
  }
  return '${category['description'] ?? ''}';
}

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
        categories = responses[1]
            .list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
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
          const Text(
            'Explorar',
            style: TextStyle(
              fontFamily: _font,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ExploreSearchField(
            controller: searchController,
            loading: searchingNow,
            onSearch: search,
          ),
          const SizedBox(height: 22),
          if (error != null) ...[
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
            const SizedBox(height: 12),
          ],
          if (searching) ...[
            const Text('Resultados', style: _sectionTitle),
            const SizedBox(height: 12),
            if (results.isEmpty)
              const Text(
                'Nenhuma palavra encontrada.',
                style: TextStyle(
                  fontFamily: _font,
                  color: LuminColors.muted,
                  fontSize: 12,
                ),
              )
            else
              for (final entry in results)
                WordSearchTile(entry: entry, onTap: () => openWord(entry)),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Minhas Palavras', style: _sectionTitle),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TranslationHistoryScreen(),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: Text(
                      'Ver Tudo',
                      style: TextStyle(
                        fontFamily: _font,
                        color: _accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (myWords.isEmpty)
              const Text(
                'Salve uma tradução com a câmera para vê-la aqui.',
                style: TextStyle(
                  fontFamily: _font,
                  color: LuminColors.muted,
                  fontSize: 12,
                ),
              )
            else
              Row(
                children: [
                  for (int i = 0; i < myWords.length && i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 6,
                          right: i == 0 ? 6 : 0,
                        ),
                        child: WordMiniCard(
                          entry: myWords[i],
                          onTap: () => openWord(myWords[i]),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 22),
            const Text(
              'Traduzido por outros\nusuários',
              style: _sectionTitle,
            ),
            const SizedBox(height: 10),
            if (categories.isEmpty)
              const Text(
                'Nenhuma categoria disponível.',
                style: TextStyle(
                  fontFamily: _font,
                  color: LuminColors.muted,
                  fontSize: 12,
                ),
              )
            else
              for (final category in categories)
                CategoryRow(
                  icon: exploreCategoryIcon('${category['name'] ?? ''}'),
                  title: '${category['name'] ?? ''}',
                  subtitle: categorySubtitle(category),
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
            builder: (_) => CategoryWordsScreen(
              categoryId: id,
              title: '${category['name'] ?? ''}',
            ),
          ),
        )
        .then((_) => load());
  }
}

/// Barra de busca do wireframe: ícone de lupa à esquerda e texto de apoio.
/// Busca ao tocar na lupa ou ao confirmar no teclado; limpar o campo
/// volta para a tela padrão.
class ExploreSearchField extends StatelessWidget {
  const ExploreSearchField({
    super.key,
    required this.controller,
    required this.onSearch,
    this.loading = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSearch,
      onChanged: (value) {
        if (value.trim().isEmpty) onSearch('');
      },
      style: const TextStyle(
        fontFamily: _font,
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Pesquisar palavras ou frases..',
        hintStyle: const TextStyle(
          fontFamily: _font,
          color: Color(0xFF9A96A8),
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
        prefixIcon: IconButton(
          tooltip: 'Buscar',
          onPressed: () => onSearch(controller.text),
          icon: const Icon(Icons.search, size: 28, color: Color(0xFFB9B5C6)),
        ),
        suffixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        filled: true,
        fillColor: LuminColors.panelLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CategoryWordsScreen extends StatefulWidget {
  const CategoryWordsScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.languageId,
  });

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
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            )
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
                      .push(
                        MaterialPageRoute(
                          builder: (_) => WordDetailScreen(wordId: id),
                        ),
                      )
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
        decoration: BoxDecoration(
          color: LuminColors.panelLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.original,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '→ ${entry.translated}',
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  if (entry.categoryName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      entry.categoryName,
                      style: const TextStyle(
                        fontFamily: _font,
                        color: LuminColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
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
    final pron = entry.raw['pronunciation'];
    final detail = (pron is String && pron.trim().isNotEmpty)
        ? '/ ${pron.trim()} /'
        : entry.translated;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 126),
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.categoryName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _font,
                color: _accent,
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.original,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _font,
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _font,
                color: LuminColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8A1FDB), Color(0xFFE01BD8)],
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

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
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8A1FDB), Color(0xFFB01ED0)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}