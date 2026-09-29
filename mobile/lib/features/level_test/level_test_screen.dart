import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_assets.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/level_test/placement_screen.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key, this.canSkip = true});

  final bool canSkip;

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
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
    final langs = results[0].list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlacementScreen(languageId: selectedLanguageId!)),
    ).then((_) {
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
        child: Padding(
          padding: LuminSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teste de nivelamento',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Vamos identificar seu nível no idioma escolhido.',
                style: TextStyle(color: LuminColors.muted),
              ),
              const SizedBox(height: 28),
              Container(
                height: 210,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  LuminAssets.levelTest,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'O que será avaliado?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const TestTopic(label: 'Vocabulário'),
              const TestTopic(label: 'Leitura'),
              const TestTopic(label: 'Escuta'),
              const SizedBox(height: 18),
              const Row(
                children: [
                  LevelChip(label: 'N1', text: 'Iniciante'),
                  SizedBox(width: 8),
                  LevelChip(label: 'N2', text: 'Intermediário'),
                  SizedBox(width: 8),
                  LevelChip(label: 'N3', text: 'Avançado'),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Idioma do teste', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final lang in languages)
                      ChoiceChip(
                        label: Text('${lang['name'] ?? ''}'),
                        selected: lang['id'] == selectedLanguageId,
                        onSelected: (_) {
                          final id = lang['id'];
                          if (id is int) setState(() => selectedLanguageId = id);
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.canSkip) ...[
                    TextButton(onPressed: goHome, child: const Text('Pular')),
                    const SizedBox(width: 12),
                  ] else ...[
                    TextButton(onPressed: goBack, child: const Text('Voltar')),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: LuminButton(
                      label: loading ? 'Carregando...' : 'Começar',
                      onPressed: loading ? () {} : start,
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
