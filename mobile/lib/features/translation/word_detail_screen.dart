import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/study/exercise_screen.dart';
import 'package:mobile/main.dart';

const String _font = 'Poppins';
const Color _card = Color(0xFF3B393D);
const Color _violetText = Color(0xFFB800D0);

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({super.key, this.wordId});

  final int? wordId;

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  Map<String, dynamic> word = {};
  String pronunciation = '';
  bool loadingPronunciation = false;
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

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
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
    if (error != null) return;
    final given = _cleanPhonetic('${word['pronunciation'] ?? ''}');
    if (given.isNotEmpty) {
      setState(() => pronunciation = given);
      return;
    }
    final original = '${word['original'] ?? ''}'.trim();
    if (original.isEmpty) return;
    setState(() => loadingPronunciation = true);
    final fetched = await _fetchPhonetic(original);
    if (!mounted) return;
    setState(() {
      loadingPronunciation = false;
      pronunciation = _cleanPhonetic(fetched);
    });
  }

  /// Remove as barras e espaços da transcrição: "/ˈbʌtɚ/" -> "ˈbʌtɚ".
  String _cleanPhonetic(String value) {
    return value.replaceAll('/', '').trim();
  }

  /// Busca a transcrição fonética (inglês) no dicionário online gratuito.
  Future<String> _fetchPhonetic(String term) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 6);
    try {
      final url =
          'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(term.toLowerCase())}';
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200) return '';
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      if (data is List && data.isNotEmpty && data.first is Map) {
        final first = data.first as Map;
        final main = first['phonetic'];
        if (main is String && main.trim().isNotEmpty) return main;
        final list = first['phonetics'];
        if (list is List) {
          for (final item in list) {
            if (item is Map &&
                item['text'] is String &&
                (item['text'] as String).trim().isNotEmpty) {
              return item['text'] as String;
            }
          }
        }
      }
    } catch (_) {
      // sem internet ou palavra não encontrada
    } finally {
      client.close();
    }
    return '';
  }

  Future<void> speak() async {
    final text = '${word['original'] ?? ''}'.trim();
    if (text.isEmpty) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
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
            categoryId: word['categoryId'] is int
                ? word['categoryId'] as int
                : 0,
          );
    if (!mounted) return;
    setState(() => saving = false);
    if (response.ok) {
      setState(() => saved = !saved);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.error)));
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

  List<_Example> get examples {
    final raw = word['examples'];
    final out = <_Example>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is String && e.trim().isNotEmpty) {
          out.add(_Example(e.trim(), ''));
        } else if (e is Map) {
          final text =
              e['text'] ?? e['sentence'] ?? e['original'] ?? e['example'] ?? '';
          final tr = e['translation'] ?? e['translated'] ?? '';
          if ('$text'.trim().isNotEmpty) {
            out.add(_Example('$text'.trim(), '$tr'.trim()));
          }
        }
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      out.add(_Example(raw.trim(), ''));
    }
    return out;
  }

  Widget _header() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Voltar',
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
            ),
          ),
          const Text(
            'Detalhes da Tradução',
            style: TextStyle(
              fontFamily: _font,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (widget.wordId != null && error == null && !loading)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: saved ? 'Remover das salvas' : 'Salvar palavra',
                padding: EdgeInsets.zero,
                onPressed: saving ? null : toggleSaved,
                icon: Icon(
                  saved ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 28,
                  color: saved ? _violetText : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
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
              ? Column(
                  children: [
                    _header(),
                    Expanded(
                      child: Center(
                        child: Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final exs = examples;
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _header(),
                                const SizedBox(height: 16),
                                _HeroCard(
                                  original: '${word['original'] ?? ''}',
                                  translated: '${word['translated'] ?? ''}',
                                ),
                                const SizedBox(height: 12),
                                _InfoCard(
                                  title: 'Pronúncia',
                                  trailing: IconButton(
                                    tooltip: 'Ouvir pronúncia',
                                    onPressed: speak,
                                    icon: const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  child: Text(
                                    loadingPronunciation
                                        ? '/ … /'
                                        : (pronunciation.isEmpty
                                              ? '/ — /'
                                              : '/ $pronunciation /'),
                                    style: const TextStyle(
                                      fontFamily: _font,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                      fontStyle: FontStyle.italic,
                                      color: _violetText,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _InfoCard(
                                  title: 'Significado',
                                  child: Text(
                                    '${word['description'] ?? ''}',
                                    style: const TextStyle(
                                      fontFamily: _font,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (exs.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _InfoCard(
                                    title: 'Exemplos',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var i = 0; i < exs.length; i++)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: i == 0 ? 0 : 14,
                                            ),
                                            child: _ExampleView(exs[i]),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                DetailBox(
                                  title: 'Categoria',
                                  body: '${word['categoryName'] ?? ''}',
                                ),
                                DetailBox(
                                  title: 'Desempenho',
                                  body:
                                      '${word['correctAnswers'] ?? 0} acertos · ${word['incorrectAnswers'] ?? 0} erros',
                                ),
                              ],
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Center(
                                  child: _GradientButton(
                                    label: practicing
                                        ? 'Criando...'
                                        : 'Praticar palavra',
                                    onTap: practicing ? null : practice,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _Example {
  const _Example(this.text, this.translation);

  final String text;
  final String translation;
}

class _ExampleView extends StatelessWidget {
  const _ExampleView(this.example);

  final _Example example;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          example.text,
          style: const TextStyle(
            fontFamily: _font,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: _violetText,
          ),
        ),
        if (example.translation.isNotEmpty)
          Text(
            '(${example.translation})',
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.original, required this.translated});

  final String original;
  final String translated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF5B00C8), Color(0xFFD10FD3)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            original.toUpperCase(),
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.arrow_right_alt, color: Colors.white, size: 30),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  translated,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          if (trailing == null)
            Padding(padding: const EdgeInsets.only(right: 6), child: child)
          else
            Row(
              children: [
                Expanded(child: child),
                trailing!,
              ],
            ),
        ],
      ),
    );
  }
}

class DetailBox extends StatelessWidget {
  const DetailBox({
    super.key,
    required this.title,
    required this.body,
    this.icon,
  });

  final String title;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _InfoCard(
        title: title,
        trailing: icon == null ? null : Icon(icon, color: Colors.white),
        child: Text(
          body,
          style: const TextStyle(
            fontFamily: _font,
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Container(
          width: 262,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF4A0BC6), Color(0xFF8A1FDB), Color(0xFFD10FD3)],
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}