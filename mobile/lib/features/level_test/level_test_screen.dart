import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_assets.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';

class LevelTestScreen extends StatelessWidget {
  const LevelTestScreen({super.key});

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
              const Spacer(),
              LuminButton(
                label: 'Começar',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AppShell()),
                ),
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
