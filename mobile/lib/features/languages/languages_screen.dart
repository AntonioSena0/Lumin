import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/explore/explore_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/shared/widgets/language_flag.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> languages = [];
  int? nativeId;
  int? chosenId;
  bool loading = true;

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
    final results = await Future.wait([luminApi.languages(), luminApi.me()]);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (results[0].ok) {
        languages = results[0].list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (results[1].ok) {
        final native = results[1].map['nativeLanguage'];
        final chosen = results[1].map['chosenLanguage'];
        if (native is Map && native['id'] is int) {
          nativeId = native['id'] as int;
        }
        if (chosen is Map && chosen['id'] is int) {
          chosenId = chosen['id'] as int;
        }
      }
    });
  }

  List<Map<String, dynamic>> get filtered {
    final term = searchController.text.trim().toLowerCase();
    if (term.isEmpty) return languages;
    return languages
        .where(
          (lang) =>
              '${lang['name'] ?? ''}'.toLowerCase().contains(term) ||
              '${lang['code'] ?? ''}'.toLowerCase().contains(term),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Idiomas',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          LuminField(
            label: 'Pesquisar idiomas',
            controller: searchController,
            icon: Icons.search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            const Center(
              child: Text(
                'Nenhum idioma encontrado.',
                style: TextStyle(color: LuminColors.muted, fontSize: 12),
              ),
            )
          else
            for (final lang in filtered)
              if (lang['id'] is int)
                LanguageTile(
                  code: '${lang['code'] ?? ''}',
                  label: '${lang['name'] ?? ''}',
                  tag: lang['id'] == nativeId
                      ? 'Sua língua'
                      : lang['id'] == chosenId
                      ? 'Em estudo'
                      : null,
                  onTap: () => openWords(lang),
                ),
        ],
      ),
    );
  }

  void openWords(Map<String, dynamic> lang) {
    final id = lang['id'];
    if (id is! int) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryWordsScreen(
          categoryId: 0,
          title: '${lang['name'] ?? ''}',
          languageId: id,
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.code,
    required this.label,
    this.tag,
    this.onTap,
  });

  final String code;
  final String label;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Center(child: LanguageFlag(code: code, size: 21)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (tag != null)
                    Text(
                      tag!,
                      style: const TextStyle(
                        color: LuminColors.magenta,
                        fontSize: 11,
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
