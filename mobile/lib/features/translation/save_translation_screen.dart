import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/language_flag.dart';

const String _font = 'Poppins';

class SaveTranslationScreen extends StatefulWidget {
  const SaveTranslationScreen({
    super.key,
    this.originalText = '',
    this.translatedText = '',
    this.imagePath,
    this.imageBytes,
  });

  final String originalText;
  final String translatedText;

  /// Caminho da foto tirada na câmera (exibida no topo da tela).
  final String? imagePath;

  /// Alternativa ao [imagePath], quando a foto está em memória.
  final Uint8List? imageBytes;

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
  String nativeCode = '';
  String chosenCode = '';
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
      if (native is Map) {
        if (native['name'] is String) nativeName = native['name'] as String;
        if (native['code'] is String) nativeCode = native['code'] as String;
      }
      if (chosen is Map) {
        if (chosen['name'] is String) chosenName = chosen['name'] as String;
        if (chosen['code'] is String) chosenCode = chosen['code'] as String;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: LuminSpacing.page,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(context),
                          const SizedBox(height: 14),
                          Center(
                            child: _PhotoCard(
                              imagePath: widget.imagePath,
                              imageBytes: widget.imageBytes,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _WireField(
                            label: 'Texto Original',
                            controller: originalController,
                          ),
                          const SizedBox(height: 14),
                          _WireField(
                            label: 'Tradução',
                            controller: translatedController,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _LangPill(
                                  name: nativeName,
                                  code: nativeCode,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: _LangPill(
                                  name: chosenName,
                                  code: chosenCode,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Categoria: mantida como no app.
                          DropdownButtonFormField<int>(
                            initialValue: categoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                            ),
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
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                        children: [
                          const SizedBox(height: 22),
                          _SaveButton(
                            label: loading ? 'Salvando...' : 'Salvar',
                            onTap: loading ? null : save,
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontFamily: _font,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3F13C9),
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
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
            'Salvar Tradução',
            style: TextStyle(
              fontFamily: _font,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto tirada, com borda em degradê violeta → magenta.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({this.imagePath, this.imageBytes});

  final String? imagePath;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    Widget photo;
    if (imageBytes != null) {
      photo = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      photo = Image.file(File(imagePath!), fit: BoxFit.cover);
    } else {
      photo = Container(
        color: LuminColors.panel,
        child: const Icon(
          Icons.image_outlined,
          size: 40,
          color: LuminColors.muted,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 257 / 165,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7A1FE0), Color(0xFFD10FD3)],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox.expand(child: photo),
          ),
        ),
      ),
    );
  }
}

class _WireField extends StatelessWidget {
  const _WireField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontFamily: _font,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: LuminColors.panelLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({required this.name, required this.code});

  final String name;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          code.isEmpty
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.flag_outlined, color: LuminColors.muted),
                )
              : SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipOval(child: LanguageFlag(code: code, size: 36)),
                ),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Container(
          width: 192,
          height: 42,
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
                    fontSize: 22,
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