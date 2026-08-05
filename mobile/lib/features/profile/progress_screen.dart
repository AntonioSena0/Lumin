import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BackTitle(title: 'Meu progresso'),
          SizedBox(height: 16),
          ProgressSummary(),
          SizedBox(height: 18),
          Text(
            'Rotina',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          ProgressMetric(
            title: 'Dias ativos',
            value: '12',
            description: 'Traduções feitas em dias diferentes',
          ),
          ProgressMetric(
            title: 'Palavras aprendidas',
            value: '128',
            description: 'Palavras salvas e praticadas ao menos uma vez',
          ),
          ProgressMetric(
            title: 'Precisão média',
            value: '78%',
            description: 'Baseada nos exercícios respondidos',
          ),
          SizedBox(height: 18),
          Text(
            'Categorias recentes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          CategoryProgress(label: 'Alimentos', value: 0.72),
          CategoryProgress(label: 'Viagem', value: 0.48),
          CategoryProgress(label: 'Casa', value: 0.36),
        ],
      ),
    );
  }
}

class ProgressSummary extends StatelessWidget {
  const ProgressSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nível N2',
            style: TextStyle(
              color: LuminColors.magenta,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.58,
            minHeight: 8,
            backgroundColor: LuminColors.panelLight,
            color: LuminColors.magenta,
          ),
          SizedBox(height: 10),
          Text(
            '580 de 1000 XP para revisar o nível atual',
            style: TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ProgressMetric extends StatelessWidget {
  const ProgressMetric({
    super.key,
    required this.title,
    required this.value,
    required this.description,
  });

  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              value,
              style: const TextStyle(
                color: LuminColors.magenta,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: LuminColors.muted,
                    fontSize: 12,
                    height: 1.25,
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

class CategoryProgress extends StatelessWidget {
  const CategoryProgress({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(color: LuminColors.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: LuminColors.panelLight,
            color: LuminColors.magenta,
          ),
        ],
      ),
    );
  }
}
