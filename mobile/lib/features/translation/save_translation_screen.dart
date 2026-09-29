import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class SaveTranslationScreen extends StatefulWidget {
  const SaveTranslationScreen({
    super.key,
    this.originalText = '',
    this.translatedText = '',
  });

  final String originalText;
  final String translatedText;

  @override
  State<SaveTranslationScreen> createState() => _SaveTranslationScreenState();
}

class _SaveTranslationScreenState extends State<SaveTranslationScreen> {
  late final TextEditingController originalController;
  late final TextEditingController translatedController;
  List<Map<String, dynamic>> categories = [];
  int? categoryId;
  String nativeName = 'Nativo';
  String chosenName = 'Estudo';
  String? error;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    originalController = TextEditingController(text: widget.originalText);
    translatedController = TextEditingController(text: widget.translatedText);
    load();
  }

  @override
  void dispose() {
    originalController.dispose();
    translatedController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final results = await Future.wait([luminApi.categories(), luminApi.me()]);
    if (!mounted) return;
    setState(() {
      categories = results[0].list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (categories.isNotEmpty && categories.first['id'] is int) {
        categoryId = categories.first['id'] as int;
      }
      final me = results[1].map;
      final native = me['nativeLanguage'];
      final chosen = me['chosenLanguage'];
      if (native is Map && native['name'] is String) {
        nativeName = native['name'] as String;
      }
      if (chosen is Map && chosen['name'] is String) {
        chosenName = chosen['name'] as String;
      }
    });
  }

  Future<void> save() async {
    if (originalController.text.trim().isEmpty ||
        translatedController.text.trim().isEmpty ||
        categoryId == null) {
      setState(() => error = 'Preencha os textos e a categoria.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    final response = await luminApi.saveWord(
      original: originalController.text.trim(),
      translated: translatedController.text.trim(),
      categoryId: categoryId!,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (response.ok) {
      final wordId = response.map['wordId'];
      if (wordId is int) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: wordId)),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() => error = response.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: LuminSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackTitle(title: 'Salvar tradução'),
              const SizedBox(height: 16),
              _PreviewCard(
                original: originalController.text,
                translated: translatedController.text,
                sourceLanguage: nativeName,
                targetLanguage: chosenName,
              ),
              const SizedBox(height: 18),
              LuminField(
                label: 'Palavra em $nativeName',
                controller: originalController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LuminField(
                label: 'Tradução em $chosenName',
                controller: translatedController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _DirectionBar(source: nativeName, target: chosenName),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: categoryId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  for (final category in categories)
                    if (category['id'] is int)
                      DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Text('${category['name'] ?? ''}'),
                      ),
                ],
                onChanged: (id) => setState(() => categoryId = id),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const Spacer(),
              LuminButton(
                label: loading ? 'Salvando...' : 'Salvar tradução',
                onPressed: loading ? () {} : save,
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Center(child: Text('Cancelar')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.original,
    required this.translated,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String original;
  final String translated;
  final String sourceLanguage;
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final hasText = original.trim().isNotEmpty && translated.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF6E7), Color(0xFFF3E4C8)],
        ),
        border: Border.all(
          color: LuminColors.magenta.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(label: sourceLanguage, color: LuminColors.magenta),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF8A6E4F),
                size: 18,
              ),
              const Spacer(),
              _Tag(label: targetLanguage, color: const Color(0xFF4A7C59)),
            ],
          ),
          const SizedBox(height: 18),
          if (!hasText)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'A prévia aparece aqui',
                  style: TextStyle(color: Color(0xFF8A6E4F), fontSize: 14),
                ),
              ),
            )
          else ...[
            Center(
              child: Text(
                original.trim().toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5C4636),
                  fontSize: 13,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFB08D62),
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                translated.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF3E2F22),
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DirectionBar extends StatelessWidget {
  const _DirectionBar({required this.source, required this.target});

  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DirectionStep(label: source, icon: Icons.translate),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_forward,
            color: LuminColors.magenta,
            size: 18,
          ),
        ),
        Expanded(
          child: _DirectionStep(label: target, icon: Icons.flag_outlined),
        ),
      ],
    );
  }
}

class _DirectionStep extends StatelessWidget {
  const _DirectionStep({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: LuminColors.muted),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
