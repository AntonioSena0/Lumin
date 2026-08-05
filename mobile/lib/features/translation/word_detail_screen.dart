import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: LuminSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackTitle(title: 'Detalhes da tradução'),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LuminColors.violet, LuminColors.magenta],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUTTER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('→ Manteiga', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const DetailBox(
                title: 'Pronúncia',
                body: '/ bó-ter /',
                icon: Icons.volume_up,
              ),
              const DetailBox(
                title: 'Significado',
                body:
                    'Alimento sólido amarelado feito a partir da nata do leite.',
              ),
              const DetailBox(
                title: 'Exemplos',
                body:
                    'Please, pass the butter.\nI always spread butter on my toast.',
              ),
              const Spacer(),
              LuminButton(
                label: 'Praticar palavra',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: LuminColors.magenta,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
          if (icon != null) Icon(icon),
        ],
      ),
    );
  }
}
