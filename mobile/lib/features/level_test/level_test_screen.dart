import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_assets.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/level_test/placement_screen.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/core/i18n/i18n.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key, this.canSkip = true});

  final bool canSkip;

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  static const String _font = 'Poppins';
  static const Color _violet = Color(0xFFB03CF0);
  static const Color _card = Color(0xFF0E0B1D);

  bool loading = false;
  List<Map<String, dynamic>> languages = [];
  int? selectedLanguageId;

  @override
  void initState() {
    super.initState();
    load();
  }

  void goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  Future<void> load() async {
    setState(() => loading = true);
    final results = await Future.wait([luminApi.languages(), luminApi.me()]);
    if (!mounted) return;
    setState(() => loading = false);
    final langs = results[0]
        .list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final me = results[1].map;
    final chosen = me['chosenLanguage'];
    final chosenId = chosen is Map ? chosen['id'] : null;
    setState(() {
      languages = langs;
      if (chosenId is int) {
        selectedLanguageId = chosenId;
      } else if (langs.isNotEmpty && langs.first['id'] is int) {
        selectedLanguageId = langs.first['id'] as int;
      }
    });
  }

  void start() {
    if (selectedLanguageId == null) {
      goHome();
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PlacementScreen(languageId: selectedLanguageId!),
          ),
        )
        .then((_) {
      if (mounted) load();
    });
  }

  void goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    goHome();
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
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        const SizedBox(height: 14),
                        _infoCard(),
                        const SizedBox(height: 18),
                        _LevelRow(
                          code: 'N1',
                          text: tr('Iniciante'),
                          color: Color(0xFF4F9A45),
                        ),
                        const SizedBox(height: 7),
                        _LevelRow(
                          code: 'N2',
                          text: tr('Intermediário'),
                          color: Color(0xFF7A3F9E),
                        ),
                        const SizedBox(height: 7),
                        _LevelRow(
                          code: 'N3',
                          text: tr('Avançado'),
                          color: Color(0xFFC23B3B),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Center(
                          child: _GradientButton(
                            label: loading ? tr('Carregando...') : tr('Começar'),
                            onTap: loading ? null : start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (widget.canSkip)
          Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: goHome,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(48, 40),
              ),
              child: Text(
                tr('Pular'),
                style: TextStyle(
                  fontFamily: _font,
                  color: LuminColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: 18),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  tr('Teste de Nivelamento'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  tr('Vamos identificar seu nível no\nidioma escolhido'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 326 / 216,
              child: ExcludeSemantics(
                child: Image.asset(
                  LuminAssets.levelTest,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              tr('O que será avaliado?'),
              style: TextStyle(
                fontFamily: _font,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          _TopicLine(tr('Gramática')),
          _TopicLine(tr('Leitura')),
          _TopicLine(tr('Escuta')),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 20, 14),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.schedule, size: 14, color: _violet),
                ),
                SizedBox(width: 6),
                Text(
                  tr('Tempo estimado 5 minutos'),
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicLine extends StatelessWidget {
  const _TopicLine(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SizedBox(
        height: 25,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.code,
    required this.text,
    required this.color,
  });

  final String code;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ],
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
          width: 243,
          height: 51,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF4A0BC6),
                Color(0xFF8A1FDB),
                Color(0xFFD10FD3),
              ],
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
                    fontFamily: 'Poppins',
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

// Mantidas para não quebrar outros arquivos que possam importá-las.
class TestTopic extends StatelessWidget {
  const TestTopic({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: LuminColors.magenta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: LuminColors.magenta,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              text,
              style: const TextStyle(color: LuminColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}