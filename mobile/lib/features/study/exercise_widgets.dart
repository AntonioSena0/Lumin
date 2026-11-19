import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/i18n.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

enum ExerciseKind { choice, sentence, text, speaking }

/// Define como o usuário responde: escolhendo, montando a frase com blocos, digitando ou falando.
ExerciseKind exerciseKind(Map<String, dynamic> exercise) {
  if ('${exercise['type']}'.toLowerCase() == 'speaking') return ExerciseKind.speaking;
  final options = exercise['options'];
  if (options is! List || options.isEmpty) return ExerciseKind.text;
  final subType = '${exercise['subType']}';
  if (subType == 'TRANSLATE' || subType == 'REWRITE') return ExerciseKind.sentence;
  return ExerciseKind.choice;
}

/// Retorna o rótulo e o ícone do tipo de exercício exibidos acima do enunciado.
(String, IconData) exerciseLabel(Map<String, dynamic> exercise) {
  if ('${exercise['type']}'.toLowerCase() == 'speaking') {
    return (tr('Fale a frase'), Icons.mic_none_rounded);
  }
  return switch ('${exercise['subType']}') {
    'FILL_IN' => (tr('Complete a frase'), Icons.space_bar_rounded),
    'TRANSLATE' => (tr('Monte a tradução'), Icons.translate_rounded),
    'MULTIPLE_CHOICE' => (tr('Escolha a resposta'), Icons.checklist_rounded),
    'REWRITE' => (tr('Reescreva a frase'), Icons.edit_note_rounded),
    _ => (tr('Exercício'), Icons.school_outlined),
  };
}

class FillInPrompt extends StatelessWidget {
  const FillInPrompt({super.key, required this.prompt, required this.filled});

  final String prompt;
  final String? filled;

  /// Mostra a frase com a lacuna preenchida pela palavra escolhida ou com um espaço destacado.
  @override
  Widget build(BuildContext context) {
    final parts = prompt.split(RegExp(r'_{3,}'));
    const base = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.5, color: LuminColors.text);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < parts.length - 1)
              TextSpan(
                text: filled == null ? '        ' : ' $filled ',
                style: TextStyle(
                  color: LuminColors.cyan,
                  backgroundColor: LuminColors.cyan.withValues(alpha: 0.14),
                  decoration: TextDecoration.underline,
                  decorationColor: LuminColors.cyan,
                  decorationThickness: 2,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ChoiceAnswer extends StatelessWidget {
  const ChoiceAnswer({super.key, required this.options, required this.selected, required this.onSelect});

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  /// Mostra as opções como blocos tocáveis, destacando a escolhida.
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          WordBlock(text: option, active: option == selected, onTap: () => onSelect(option)),
      ],
    );
  }
}

class SentenceBuilder extends StatefulWidget {
  const SentenceBuilder({super.key, required this.blocks, required this.onChanged});

  final List<String> blocks;
  final ValueChanged<String> onChanged;

  /// Cria o estado que guarda a ordem dos blocos escolhidos.
  @override
  State<SentenceBuilder> createState() => _SentenceBuilderState();
}

class _SentenceBuilderState extends State<SentenceBuilder> {
  final placed = <int>[];

  /// Move um bloco do banco para a frase ou de volta, avisando a resposta montada.
  void toggle(int index) {
    setState(() => placed.contains(index) ? placed.remove(index) : placed.add(index));
    widget.onChanged(placed.map((i) => widget.blocks[i]).join(' '));
  }

  /// Mostra a frase em montagem acima e o banco com os blocos ainda disponíveis abaixo.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: placed.isEmpty ? Colors.white12 : LuminColors.violet),
          ),
          child: placed.isEmpty
              ? Center(
                  child: Text(
                    tr('Toque nos blocos para montar a frase'),
                    style: const TextStyle(color: LuminColors.muted, fontSize: 13),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var p = 0; p < placed.length; p++)
                      WordBlock(
                        key: ValueKey('placed-$p'),
                        text: widget.blocks[placed[p]],
                        active: true,
                        onTap: () => toggle(placed[p]),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < widget.blocks.length; i++)
              if (!placed.contains(i)) WordBlock(text: widget.blocks[i], onTap: () => toggle(i)),
          ],
        ),
      ],
    );
  }
}

class WordBlock extends StatelessWidget {
  const WordBlock({super.key, required this.text, required this.onTap, this.active = false});

  final String text;
  final VoidCallback onTap;
  final bool active;

  /// Mostra uma palavra como bloco com borda inferior, no estilo de peça tocável.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? LuminColors.violet : LuminColors.panelLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                bottom: BorderSide(color: active ? LuminColors.magenta : Colors.black45, width: 3),
              ),
            ),
            child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({super.key, required this.correct, required this.correctAnswer, required this.onContinue});

  final bool correct;
  final String? correctAnswer;
  final VoidCallback onContinue;

  /// Mostra se a resposta estava certa, a resposta correta quando errou e o botão para seguir.
  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF2BD98F) : LuminColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color),
              const SizedBox(width: 8),
              Text(
                correct ? tr('Correto!') : tr('Não foi dessa vez.'),
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ],
          ),
          if (!correct && correctAnswer != null && correctAnswer!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(tr('Resposta certa:'), style: const TextStyle(color: LuminColors.muted, fontSize: 12)),
            Text(correctAnswer!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: LuminColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onContinue,
              child: Text(tr('Continuar'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
