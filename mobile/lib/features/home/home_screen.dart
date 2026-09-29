import 'package:flutter/material.dart';
import 'package:mobile/core/models/word_entry.dart';
import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/repositories/lumin_repository.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/explore/explore_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/shared/widgets/language_flag.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenProfile});

  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  String? avatarUrl;
  double progress = 0;
  String level = '';
  String xpText = '';
  String languageName = '';
  String languageCode = '';
  String continueTitle = 'Vocabulário';
  String continueSubtitle = 'Comece agora';
  String continueCategory = '';
  int? continueWordId;
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait<Object?>([
      luminApi.me(),
      luminRepository.homeSummary(),
      luminApi.categories(),
    ]);
    if (!mounted) return;
    setState(() {
      final user = (results[0] as ApiResult).map;
      if (user['name'] is String) name = user['name'] as String;
      final avatar = user['avatar'];
      if (avatar is Map && avatar['imgUrl'] is String) {
        avatarUrl = avatar['imgUrl'] as String;
      }

      final homeResult = results[1] as RepositoryResult<HomeSummaryModel>;
      final home = homeResult.data;
      if (home != null) {
        level = home.level;
        progress = home.levelProgress.clamp(0, 1).toDouble();
        xpText = '${home.xp} XP';
        languageName = home.languageName;
        languageCode = home.languageCode;
      }

      final recent = home?.recentWords;
      if (recent != null && recent.isNotEmpty) {
        final entry = recent.first;
        if (entry.translated.isNotEmpty) {
          continueTitle = 'Vocabulário: ${entry.translated}';
        }
        if (entry.original.isNotEmpty) {
          continueSubtitle = 'Praticar ${entry.original}';
        }
        continueCategory = entry.categoryName;
        continueWordId = entry.wordId;
      }

      modules = (results[2] as ApiResult).list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] is int)
          .toList();
    });
  }

  void openProfile() {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!();
    }
  }

  void openModules() {
    if (modules.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeModulesScreen(modules: modules, onSelected: load),
      ),
    );
  }

  void openModule(Map<String, dynamic> module) {
    final id = module['id'];
    if (id is! int) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryWordsScreen(
              categoryId: id,
              title: '${module['name'] ?? ''}',
            ),
          ),
        )
        .then((_) => load());
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Olá!' : 'Olá, $name!',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Pronta para traduzir o mundo hoje?',
                      style: TextStyle(color: LuminColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: openProfile,
                child: LuminAvatar(imgUrl: avatarUrl, name: name, radius: 19),
              ),
            ],
          ),
          const SizedBox(height: 18),
          EvolutionPanel(
            progress: progress,
            level: level,
            xpText: xpText,
            languageName: languageName,
            languageCode: languageCode,
          ),
          const SizedBox(height: 22),
          const Text(
            'Continue aprendendo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          PracticeTile(
            title: continueTitle,
            subtitle: continueSubtitle,
            icon: moduleIcon(continueCategory),
            onTap: () {
              if (continueWordId == null) {
                openModules();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordDetailScreen(wordId: continueWordId),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Módulos',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final module in modules)
                GestureDetector(
                  onTap: () => openModule(module),
                  child: ModuleTile(
                    icon: moduleIcon('${module['name'] ?? ''}'),
                    label: '${module['name'] ?? ''}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EvolutionPanel extends StatelessWidget {
  const EvolutionPanel({
    super.key,
    this.progress = 0,
    this.level = '',
    this.xpText = '',
    this.languageName = '',
    this.languageCode = '',
  });

  final double progress;
  final String level;
  final String xpText;
  final String languageName;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evolução',
                  style: TextStyle(color: LuminColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  level.isEmpty ? 'Comece seu nivelamento' : 'Nível $level',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (xpText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    xpText,
                    style: const TextStyle(
                      color: LuminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (languageName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      LanguageFlag(code: languageCode, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          languageName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: LuminColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 66,
            width: 66,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: LuminColors.panelLight,
              color: LuminColors.magenta,
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeTile extends StatelessWidget {
  const PracticeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: LuminColors.magenta,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: LuminColors.text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: LuminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: LuminColors.magenta,
              child: Icon(Icons.play_arrow, color: LuminColors.text),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

IconData moduleIcon(String name) {
  final key = name.toLowerCase();
  if (key.contains('comida') ||
      key.contains('food') ||
      key.contains('aliment')) {
    return Icons.restaurant;
  }
  if (key.contains('bebida') || key.contains('drink')) return Icons.local_cafe;
  if (key.contains('casa') || key.contains('house') || key.contains('home')) {
    return Icons.home;
  }
  if (key.contains('roupa') || key.contains('cloth')) return Icons.checkroom;
  if (key.contains('tecnolog') || key.contains('tech')) return Icons.devices;
  if (key.contains('natureza') || key.contains('nature')) return Icons.park;
  if (key.contains('viagem') || key.contains('travel')) {
    return Icons.flight_takeoff;
  }
  if (key.contains('estudo') || key.contains('educa')) {
    return Icons.menu_book;
  }
  if (key.contains('arte') || key.contains('cultura')) {
    return Icons.palette_outlined;
  }
  if (key.contains('saude') || key.contains('health')) {
    return Icons.health_and_safety_outlined;
  }
  if (key.contains('trabalho') || key.contains('work')) {
    return Icons.work_outline;
  }
  if (key.isEmpty) {
    return Icons.translate;
  }
  return Icons.category_outlined;
}

class HomeModulesScreen extends StatefulWidget {
  const HomeModulesScreen({
    super.key,
    required this.modules,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> modules;
  final Future<void> Function() onSelected;

  @override
  State<HomeModulesScreen> createState() => _HomeModulesScreenState();
}

class _HomeModulesScreenState extends State<HomeModulesScreen> {
  List<WordEntry> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final response = await luminApi.words(page: 0, size: 40);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) items = WordEntry.fromContent(response.map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Módulos'),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            for (final module in widget.modules)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CategoryRow(
                  icon: moduleIcon('${module['name'] ?? ''}'),
                  title: '${module['name'] ?? ''}',
                  subtitle: '${module['description'] ?? ''}',
                  onTap: () => openCategory(module),
                ),
              ),
          const SizedBox(height: 20),
          const Text(
            'Suas palavras',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ModuleWordRow(
                entry: item,
                onOpen: () => openWord(item),
                onSaved: load,
              ),
            ),
        ],
      ),
    );
  }

  void openCategory(Map<String, dynamic> module) {
    final id = module['id'];
    if (id is! int) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryWordsScreen(
              categoryId: id,
              title: '${module['name'] ?? ''}',
            ),
          ),
        )
        .then((_) => widget.onSelected());
  }

  void openWord(WordEntry entry) {
    final id = entry.id;
    if (id == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: id)))
        .then((_) => widget.onSelected());
  }
}

class ModuleWordRow extends StatelessWidget {
  const ModuleWordRow({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onSaved,
  });

  final WordEntry entry;
  final VoidCallback onOpen;
  final Future<void> Function() onSaved;

  @override
  Widget build(BuildContext context) {
    final saved = entry.isSaved;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.original,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    entry.translated,
                    style: const TextStyle(
                      color: LuminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => toggle(context),
            icon: Icon(
              saved ? Icons.star : Icons.star_border,
              color: LuminColors.magenta,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggle(BuildContext context) async {
    final id = entry.id;
    if (id == null) return;
    if (entry.isSaved) {
      await luminApi.unsaveWord(id);
    } else {
      final categoryId = entry.raw['categoryId'];
      if (categoryId is! int) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta palavra ainda não tem categoria.'),
          ),
        );
        return;
      }
      await luminApi.saveWord(
        original: entry.original,
        translated: entry.translated,
        categoryId: categoryId,
      );
    }
    await onSaved();
  }
}
