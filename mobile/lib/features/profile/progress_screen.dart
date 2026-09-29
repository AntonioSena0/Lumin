import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/shared/widgets/neon_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String level = '';
  double progress = 0;
  String xpText = '';
  String practiced = '0';
  String saved = '0';
  String weak = '0';
  String accuracy = '';
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([luminApi.profile(), luminApi.progress(), luminApi.home()]);
    if (!mounted) return;
    setState(() {
      final data = results[0].map;
      if (data['practicedWords'] != null) practiced = '${data['practicedWords']}';
      if (data['savedWords'] != null) saved = '${data['savedWords']}';
      if (data['weakWords'] != null) weak = '${data['weakWords']}';
      final accuracyValue = data['accuracy'];
      if (accuracyValue is num) accuracy = '${(accuracyValue * 100).round()}%';

      final home = results[2].map;
      if (home['level'] != null) level = '${home['level']}';
      final rawProgress = home['levelProgress'];
      if (rawProgress is num) progress = rawProgress.clamp(0, 1).toDouble();
      final xp = home['xp'];
      if (xp is num) xpText = '$xp XP';

      final progresses = results[1].list;
      if (level.isEmpty && progresses.isNotEmpty && progresses.first is Map) {
        final first = Map<String, dynamic>.from(progresses.first as Map);
        if (first['level'] != null) level = '${first['level']}';
        if (xpText.isEmpty) {
          final total = first['xp'];
          if (total is num) xpText = '$total XP';
        }
      }

      final cats = data['categoriesProgress'];
      if (cats is List) {
        categories = cats.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Meu progresso'),
          const SizedBox(height: 16),
          ProgressSummary(level: level, progress: progress, xpText: xpText),
          const SizedBox(height: 18),
          NeonCard(
            glowColor: LuminColors.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeonCardTitle(text: 'SEU DESEMPENHO'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _BigMetric(value: practiced, label: 'praticadas')),
                    Container(width: 1, height: 42, color: LuminColors.violet.withValues(alpha: 0.3)),
                    Expanded(child: _BigMetric(value: saved, label: 'salvas')),
                    Container(width: 1, height: 42, color: LuminColors.violet.withValues(alpha: 0.3)),
                    Expanded(child: _BigMetric(value: weak, label: 'a treinar')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.track_changes, color: LuminColors.violet, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      accuracy.isEmpty ? 'Sem precisão ainda' : 'Precisão média de $accuracy',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Rotina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ProgressMetric(title: 'Palavras praticadas', value: practiced, description: 'Palavras praticadas ao menos uma vez'),
          ProgressMetric(title: 'Palavras salvas', value: saved, description: 'Salvas para revisar depois'),
          ProgressMetric(title: 'Palavras com dificuldade', value: weak, description: 'Ainda precisam de mais treino'),
          ProgressMetric(title: 'Precisão média', value: accuracy.isEmpty ? '-' : accuracy, description: 'Baseada nos exercícios respondidos'),
          const SizedBox(height: 18),
          const Text('Categorias recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final category in categories)
            CategoryProgress(
              label: '${category['categoryName'] ?? ''}',
              value: categoryValue(category),
            ),
        ],
      ),
    );
  }

  double categoryValue(Map<String, dynamic> category) {
    final total = category['totalWords'];
    final practiced = category['practicedWords'];
    if (total is num && practiced is num && total > 0) {
      return (practiced / total).clamp(0, 1).toDouble();
    }
    return 0;
  }
}

class ProgressSummary extends StatelessWidget {
  const ProgressSummary({super.key, required this.level, required this.progress, required this.xpText});

  final String level;
  final double progress;
  final String xpText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.isEmpty ? 'Sem nivelamento' : 'Nível $level',
            style: const TextStyle(color: LuminColors.magenta, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: LuminColors.panelLight,
            color: LuminColors.magenta,
          ),
          const SizedBox(height: 10),
          Text(
            xpText,
            style: const TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeonCardValue(text: value, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class ProgressMetric extends StatelessWidget {
  const ProgressMetric({super.key, required this.title, required this.value, required this.description});

  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(value, style: const TextStyle(color: LuminColors.magenta, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(color: LuminColors.muted, fontSize: 12, height: 1.25)),
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
      decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
              Text('${(value * 100).round()}%', style: const TextStyle(color: LuminColors.muted, fontSize: 12)),
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
