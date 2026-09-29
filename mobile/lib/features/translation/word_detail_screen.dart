import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/study/exercise_screen.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/neon_card.dart';

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({super.key, this.wordId});

  final int? wordId;

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  Map<String, dynamic> word = {};
  bool loading = true;
  bool practicing = false;
  bool saving = false;
  bool saved = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (widget.wordId == null) {
      setState(() => loading = false);
      return;
    }
    final response = await luminApi.findUserWord(widget.wordId!);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) {
        word = response.map;
        saved = word['isSaved'] == true;
      } else {
        error = response.error;
      }
    });
  }

  Future<void> toggleSaved() async {
    final wordId = widget.wordId;
    if (wordId == null) return;
    setState(() => saving = true);
    final response = saved
        ? await luminApi.unsaveWord(wordId)
        : await luminApi.saveWord(
            original: '${word['original'] ?? ''}',
            translated: '${word['translated'] ?? ''}',
            categoryId: word['categoryId'] is int ? word['categoryId'] as int : 0,
          );
    if (!mounted) return;
    setState(() => saving = false);
    if (response.ok) {
      setState(() => saved = !saved);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  Future<void> practice() async {
    if (widget.wordId == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => practicing = true);
    final response = await luminApi.startSession(widget.wordId!);
    if (!mounted) return;
    setState(() => practicing = false);
    final session = response.map['session'] ?? response.map;
    final id = session is Map ? session['id'] : null;
    if (response.ok && id is int) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ExerciseScreen(sessionId: id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar a sessão.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: LuminSpacing.page,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                  child: Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackTitle(title: 'Detalhes da tradução'),
                    const SizedBox(height: 18),
                    NeonCard(
                      padding: const EdgeInsets.all(18),
                      glowColor: LuminColors.violet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${word['original'] ?? ''}'.toUpperCase(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text('→ ${word['translated'] ?? ''}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    DetailBox(title: 'Significado', body: '${word['description'] ?? ''}'),
                    DetailBox(title: 'Categoria', body: '${word['categoryName'] ?? ''}'),
                    DetailBox(
                      title: 'Desempenho',
                      body: '${word['correctAnswers'] ?? 0} acertos · ${word['incorrectAnswers'] ?? 0} erros',
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: saving || widget.wordId == null ? () {} : toggleSaved,
                            child: Text(saved ? 'Remover salva' : 'Salvar palavra'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LuminButton(
                            label: practicing ? 'Criando...' : 'Praticar palavra',
                            onPressed: practicing ? () {} : practice,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DetailBox extends StatelessWidget {
  const DetailBox({super.key, required this.title, required this.body, this.icon});

  final String title;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        padding: const EdgeInsets.all(14),
        glowColor: LuminColors.magenta,
        glowStrength: 0.55,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: LuminColors.magenta, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
          if (icon != null) Icon(icon),
        ],
        ),
      ),
    );
  }
}
