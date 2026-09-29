import 'package:flutter/material.dart';
import 'package:mobile/core/speech/speech_service.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class SpeakingAnswerInput extends StatelessWidget {
  const SpeakingAnswerInput({
    super.key,
    required this.controller,
    required this.listening,
    required this.onTap,
  });

  final TextEditingController controller;
  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answer = controller.text.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: BoxDecoration(
        color: LuminColors.panelLight,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: listening ? LuminColors.violet : Colors.white12,
        ),
        boxShadow: listening
            ? [
                BoxShadow(
                  color: LuminColors.violet.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listening ? 'Ouvindo...' : 'Resposta por voz',
                  style: const TextStyle(
                    color: LuminColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  answer.isEmpty ? 'Toque no microfone e fale' : answer,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: answer.isEmpty ? LuminColors.muted : Colors.white,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            tooltip: listening ? 'Parar gravação' : 'Falar resposta',
            icon: Icon(
              listening ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
              color: listening ? LuminColors.violet : Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final answerController = TextEditingController();
  Map<String, dynamic>? exercise;
  int currentIndex = 0;
  int totalExercises = 0;
  bool loading = true;
  bool sending = false;
  bool? lastCorrect;
  String? error;
  String voice = 'FEMALE';
  final speechRecognizer = SpeechToText();
  bool listening = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
    load();
  }

  @override
  void dispose() {
    answerController.dispose();
    speechRecognizer.stop();
    SpeechService.instance.stop();
    super.dispose();
  }

  bool get isLast => totalExercises > 0 && currentIndex >= totalExercises - 1;

  bool get isDone => totalExercises > 0 && currentIndex >= totalExercises;

  bool get isSpeakingExercise =>
      '${exercise?['type']}'.toLowerCase() == 'speaking';

  Future<String?> getSpeechLocaleId() async {
    final language = exercise?['language'];
    if (language is! Map || language['code'] is! String) return null;
    final code = (language['code'] as String).toLowerCase();
    final locales = await speechRecognizer.locales();
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith(code)) {
        return locale.localeId;
      }
    }
    return null;
  }

  Future<void> loadSettings() async {
    final response = await luminApi.settings();
    if (!mounted) return;
    final value = response.map['voice'];
    if (response.ok && value is String) setState(() => voice = value);
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final results = await Future.wait([
      luminApi.session(widget.sessionId),
      luminApi.currentExercise(widget.sessionId),
    ]);
    if (!mounted) return;

    final session = results[0];
    if (session.ok) {
      currentIndex = (session.map['currentIndex'] as num?)?.toInt() ?? 0;
      totalExercises = (session.map['totalExercises'] as num?)?.toInt() ?? 0;
    }

    final current = results[1];
    setState(() {
      loading = false;
      if (current.ok) {
        exercise = current.map;
        answerController.clear();
        lastCorrect = null;
        speakPrompt();
      } else if (isDone) {
        exercise = null;
      } else {
        exercise = null;
        error = current.error;
      }
    });
  }

  void speakPrompt() {
    final prompt = exercise?['prompt'];
    if (prompt is String && prompt.isNotEmpty) {
      SpeechService.instance.speak(prompt, voice: voice);
    }
  }

  Future<void> toggleSpeechInput() async {
    if (listening) {
      await speechRecognizer.stop();
      if (mounted) setState(() => listening = false);
      return;
    }

    final available = await speechRecognizer.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() => listening = status == 'listening');
      },
      onError: (speechError) {
        if (!mounted) return;
        setState(() {
          listening = false;
          error = 'Não foi possível reconhecer sua fala.';
        });
      },
    );

    if (!mounted) return;
    if (!available) {
      setState(() {
        listening = false;
        error = 'O reconhecimento de voz não está disponível neste aparelho.';
      });
      return;
    }

    setState(() {
      listening = true;
      error = null;
      answerController.clear();
    });

    final localeId = await getSpeechLocaleId();
    await speechRecognizer.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          answerController.text = result.recognizedWords;
          answerController.selection = TextSelection.collapsed(
            offset: answerController.text.length,
          );
        });
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> answer() async {
    final current = exercise;
    final id = current?['id'];
    if (id is! int || answerController.text.trim().isEmpty) return;
    setState(() {
      sending = true;
      lastCorrect = null;
      error = null;
    });
    final response = await luminApi.answerExercise(
      widget.sessionId,
      id,
      answerController.text.trim(),
    );
    if (!mounted) return;
    if (!response.ok) {
      setState(() {
        sending = false;
        error = response.error;
      });
      return;
    }
    if (listening) {
      await speechRecognizer.stop();
      listening = false;
    }
    lastCorrect = response.map['correct'] == true;
    await load();
    if (!mounted) return;
    setState(() => sending = false);
  }

  Future<void> finish() async {
    setState(() => sending = true);
    final response = await luminApi.finishSession(widget.sessionId);
    if (!mounted) return;
    setState(() => sending = false);
    if (response.ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => error = response.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = exercise;
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(
            title: current?['title'] is String
                ? current!['title'] as String
                : 'Exercício',
          ),
          if (totalExercises > 0 && !isDone) ...[
            const SizedBox(height: 4),
            Text(
              'Exercício ${currentIndex + 1} de $totalExercises',
              style: const TextStyle(color: LuminColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (current == null) ...[
            Text(
              isDone
                  ? 'Sessão concluída. Toque em finalizar para salvar seu progresso.'
                  : error ?? 'Sessão encerrada.',
              style: const TextStyle(color: LuminColors.muted),
            ),
            const SizedBox(height: 28),
            LuminButton(
              label: sending ? 'Salvando...' : 'Finalizar sessão',
              onPressed: sending ? () {} : finish,
            ),
          ] else ...[
            Text(
              '${current['instruction'] ?? ''}',
              style: const TextStyle(color: LuminColors.muted),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuminColors.panel,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current['prompt'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: speakPrompt,
                      icon: const Icon(
                        Icons.volume_up,
                        color: LuminColors.magenta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (isSpeakingExercise)
              SpeakingAnswerInput(
                controller: answerController,
                listening: listening,
                onTap: toggleSpeechInput,
              )
            else
              LuminField(label: 'Sua resposta', controller: answerController),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            if (lastCorrect != null) ...[
              const SizedBox(height: 10),
              Text(
                lastCorrect! ? 'Correto!' : 'Não foi dessa vez.',
                style: TextStyle(
                  color: lastCorrect!
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 28),
            LuminButton(
              label: sending ? 'Corrigindo...' : 'Responder',
              onPressed: sending ? () {} : answer,
            ),
            if (isLast) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: sending ? () {} : finish,
                  child: const Text('Finalizar sessão'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
