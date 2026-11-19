import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/i18n.dart';
import 'package:mobile/core/speech/speech_service.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/study/exercise_widgets.dart';
import 'package:mobile/main.dart';
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

  /// Mostra o texto reconhecido e o botão de microfone para falar a resposta.
  @override
  Widget build(BuildContext context) {
    final answer = controller.text.trim();
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [LuminColors.violet, LuminColors.magenta]),
              boxShadow: [
                BoxShadow(
                  color: LuminColors.magenta.withValues(alpha: listening ? 0.6 : 0.25),
                  blurRadius: listening ? 36 : 18,
                  spreadRadius: listening ? 6 : 0,
                ),
              ],
            ),
            child: Icon(
              listening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 42,
              semanticLabel: listening ? tr('Parar gravação') : tr('Falar resposta'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          listening ? tr('Ouvindo...') : tr('Toque no microfone e fale'),
          style: const TextStyle(color: LuminColors.muted, fontSize: 13),
        ),
        if (answer.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            answer,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ],
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
  String? correctAnswer;
  String blockAnswer = '';
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

  bool get isDone => totalExercises > 0 && currentIndex >= totalExercises;

  ExerciseKind get kind => exercise == null ? ExerciseKind.text : exerciseKind(exercise!);

  /// Resposta atual conforme o formato: bloco ou frase montada, texto digitado ou fala reconhecida.
  String get currentAnswer => kind == ExerciseKind.choice || kind == ExerciseKind.sentence
      ? blockAnswer.trim()
      : answerController.text.trim();

  /// Procura no aparelho o reconhecimento de voz do idioma do exercício.
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

  /// Carrega a voz escolhida nas configurações para a leitura dos enunciados.
  Future<void> loadSettings() async {
    final response = await luminApi.settings();
    if (!mounted) return;
    final value = response.map['voice'];
    if (response.ok && value is String) setState(() => voice = value);
  }

  /// Busca o progresso da sessão e o exercício atual, limpando a resposta e o feedback anteriores.
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
      lastCorrect = null;
      correctAnswer = null;
      blockAnswer = '';
      answerController.clear();
      if (current.ok) {
        exercise = current.map;
        if (kind == ExerciseKind.speaking) speakPrompt();
      } else {
        exercise = null;
        if (!isDone) error = current.error;
      }
    });
  }

  /// Lê o enunciado em voz alta no idioma de estudo.
  void speakPrompt() {
    final prompt = exercise?['prompt'];
    if (prompt is String && prompt.isNotEmpty) {
      SpeechService.instance.speak(prompt.replaceAll(RegExp(r'_{3,}'), '...'), voice: voice);
    }
  }

  /// Liga ou desliga o microfone, preenchendo a resposta com o que for reconhecido.
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
          error = tr('Não foi possível reconhecer sua fala.');
        });
      },
    );

    if (!mounted) return;
    if (!available) {
      setState(() {
        listening = false;
        error = tr('O reconhecimento de voz não está disponível neste aparelho.');
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
        setState(() => answerController.text = result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  /// Envia a resposta e mostra o feedback com a resposta certa, sem avançar até o usuário continuar.
  Future<void> answer() async {
    final id = exercise?['id'];
    if (id is! int || currentAnswer.isEmpty) return;
    if (listening) {
      await speechRecognizer.stop();
      listening = false;
    }
    setState(() {
      sending = true;
      error = null;
    });
    final response = await luminApi.answerExercise(widget.sessionId, id, currentAnswer);
    if (!mounted) return;
    setState(() {
      sending = false;
      if (!response.ok) {
        error = response.error;
        return;
      }
      lastCorrect = response.map['correct'] == true;
      final expected = response.map['correctAnswer'];
      correctAnswer = expected is String ? expected : null;
    });
  }

  /// Finaliza a sessão para registrar o progresso e volta para a tela anterior.
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

  /// Mostra progresso, enunciado, a área de resposta do formato do exercício e o feedback.
  @override
  Widget build(BuildContext context) {
    final current = exercise;
    final answered = lastCorrect != null;
    final progress = totalExercises == 0 ? 0.0 : (currentIndex + (answered ? 1 : 0)) / totalExercises;

    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isDone && !sending ? finish : () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: tr('Voltar'),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress.clamp(0, 1)),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: LuminColors.panelLight,
                      valueColor: const AlwaysStoppedAnimation(LuminColors.magenta),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                totalExercises == 0 ? '' : '${(currentIndex + 1).clamp(1, totalExercises)}/$totalExercises',
                style: const TextStyle(color: LuminColors.muted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (current == null) ...[
            const SizedBox(height: 40),
            Center(
              child: Icon(
                isDone ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                size: 72,
                color: LuminColors.magenta,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDone ? tr('Sessão concluída. Toque em finalizar para salvar seu progresso.') : error ?? tr('Sessão encerrada.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: LuminColors.muted),
            ),
            const SizedBox(height: 28),
            LuminButton(
              label: sending ? tr('Salvando...') : tr('Finalizar sessão'),
              onPressed: sending ? () {} : finish,
            ),
          ] else ...[
            _TypeLabel(exercise: current),
            const SizedBox(height: 10),
            Text(
              '${current['instruction'] ?? ''}',
              style: const TextStyle(color: LuminColors.muted),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: '${current['subType']}' == 'FILL_IN'
                      ? FillInPrompt(
                          prompt: '${current['prompt'] ?? ''}',
                          filled: blockAnswer.isEmpty ? null : blockAnswer,
                        )
                      : Text(
                          '${current['prompt'] ?? ''}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.4),
                        ),
                ),
                if ('${current['subType']}' != 'TRANSLATE')
                  IconButton(
                    onPressed: speakPrompt,
                    tooltip: tr('Ouvir pronúncia'),
                    icon: const Icon(Icons.volume_up_rounded, color: LuminColors.magenta),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            AbsorbPointer(
              absorbing: answered || sending,
              child: _AnswerArea(
                key: ValueKey(current['id']),
                exercise: current,
                kind: kind,
                selected: blockAnswer,
                controller: answerController,
                listening: listening,
                onBlocks: (value) => setState(() => blockAnswer = value),
                onToggleMic: toggleSpeechInput,
                onTyped: () => setState(() {}),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: LuminColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: 28),
            if (answered)
              AnswerFeedback(correct: lastCorrect!, correctAnswer: correctAnswer, onContinue: load)
            else
              LuminButton(
                label: sending ? tr('Corrigindo...') : tr('Verificar'),
                onPressed: sending || currentAnswer.isEmpty ? () {} : answer,
              ),
          ],
        ],
      ),
    );
  }
}

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.exercise});

  final Map<String, dynamic> exercise;

  /// Mostra o tipo do exercício com ícone, para o usuário saber como responder.
  @override
  Widget build(BuildContext context) {
    final (label, icon) = exerciseLabel(exercise);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LuminColors.violet.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LuminColors.cyan),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    super.key,
    required this.exercise,
    required this.kind,
    required this.selected,
    required this.controller,
    required this.listening,
    required this.onBlocks,
    required this.onToggleMic,
    required this.onTyped,
  });

  final Map<String, dynamic> exercise;
  final ExerciseKind kind;
  final String selected;
  final TextEditingController controller;
  final bool listening;
  final ValueChanged<String> onBlocks;
  final VoidCallback onToggleMic;
  final VoidCallback onTyped;

  /// Escolhe a área de resposta pelo formato: blocos, montador de frase, microfone ou campo de texto.
  @override
  Widget build(BuildContext context) {
    final options = (exercise['options'] as List? ?? const []).map((o) => '$o').toList();
    return switch (kind) {
      ExerciseKind.choice => ChoiceAnswer(options: options, selected: selected.isEmpty ? null : selected, onSelect: onBlocks),
      ExerciseKind.sentence => SentenceBuilder(blocks: options, onChanged: onBlocks),
      ExerciseKind.speaking => Center(
          child: SpeakingAnswerInput(controller: controller, listening: listening, onTap: onToggleMic),
        ),
      ExerciseKind.text => LuminField(label: tr('Sua resposta'), controller: controller, onChanged: (_) => onTyped()),
    };
  }
}
