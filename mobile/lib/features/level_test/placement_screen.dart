import 'package:flutter/material.dart';
import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key, required this.languageId});

  final int languageId;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  List<PlacementQuestionModel> questions = [];
  final answers = <int, String>{};
  int index = 0;
  bool loading = true;
  bool sending = false;
  String? error;
  PlacementTestResultModel? result;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response = await luminRepository.placementQuestions(widget.languageId);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) {
        questions = response.data ?? [];
      } else {
        error = response.error;
      }
    });
  }

  Future<void> send() async {
    setState(() {
      sending = true;
      error = null;
    });
    final payload = [
      for (final entry in answers.entries) {'questionId': entry.key, 'answer': entry.value},
    ];
    final response = await luminRepository.submitPlacement(widget.languageId, payload);
    if (!mounted) return;
    setState(() => sending = false);
    if (response.ok && response.data != null) {
      setState(() => result = response.data);
    } else {
      setState(() => error = response.error);
    }
  }

  void goHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      return LuminPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu nível', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              result!.level,
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: LuminColors.magenta),
            ),
            const SizedBox(height: 8),
            Text(
              'Acertos: ${result!.score} de ${result!.totalQuestions}',
              style: const TextStyle(color: LuminColors.muted),
            ),
            const SizedBox(height: 28),
            LuminButton(label: 'Começar a aprender', onPressed: goHome),
          ],
        ),
      );
    }
    if (loading) {
      return const LuminPage(child: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return LuminPage(
        child: Column(
          children: [
            Text(error ?? 'Sem questões.'),
            const SizedBox(height: 16),
            LuminButton(label: 'Pular', onPressed: goHome),
          ],
        ),
      );
    }
    final question = questions[index];
    final options = question.options;
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Questão ${index + 1} de ${questions.length}', style: const TextStyle(color: LuminColors.muted, fontSize: 12)),
          const SizedBox(height: 12),
          Text(question.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                        answers[question.id] = option;
                        if (index < questions.length - 1) {
                          index++;
                        }
                    });
                  },
                  child: Text(option),
                ),
              ),
            ),
          const SizedBox(height: 28),
          Row(
            children: [
              TextButton(onPressed: goHome, child: const Text('Pular')),
              const SizedBox(height: 28),
              Text('${answers.length}/${questions.length}'),
            ],
          ),
          const SizedBox(height: 8),
          LuminButton(
            label: sending ? 'Enviando...' : 'Finalizar',
            onPressed: (sending || answers.length != questions.length) ? () {} : send,
          ),
        ],
      ),
    );
  }
}
