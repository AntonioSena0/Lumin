import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/camera/camera_screen.dart';
import 'package:mobile/features/translation/translation_history_screen.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class SaveTranslationScreen extends StatelessWidget {
  const SaveTranslationScreen({
    super.key,
    this.originalText = 'Butter',
    this.translatedText = 'Manteiga',
  });

  final String originalText;
  final String translatedText;

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
              const SizedBox(height: 18),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E6C8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LuminColors.magenta, width: 3),
                ),
                child: Center(
                  child: Text(
                    '$originalText\n$translatedText',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5C4636),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LuminField(label: 'Texto original', initialValue: originalText),
              const SizedBox(height: 12),
              LuminField(label: 'Tradução', initialValue: translatedText),
              const SizedBox(height: 16),
              const TranslationDirection(),
              const SizedBox(height: 14),
              const LuminField(label: 'Categoria'),
              const Spacer(),
              LuminButton(
                label: 'Salvar',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const TranslationHistoryScreen(),
                  ),
                ),
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

class TranslationDirection extends StatelessWidget {
  const TranslationDirection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: CameraPill(label: 'Inglês')),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.sync_alt, color: LuminColors.magenta),
        ),
        Expanded(child: CameraPill(label: 'Português')),
      ],
    );
  }
}
