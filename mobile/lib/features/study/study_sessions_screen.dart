import 'package:flutter/material.dart';
import 'package:mobile/core/models/session_summary.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/study/exercise_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class StudySessionsScreen extends StatefulWidget {
  const StudySessionsScreen({super.key});

  @override
  State<StudySessionsScreen> createState() => _StudySessionsScreenState();
}

class _StudySessionsScreenState extends State<StudySessionsScreen> {
  final scrollController = ScrollController();
  List<SessionSummary> items = [];
  int page = 0;
  int totalPages = 0;
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = false;
  String? error;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
    load(reset: true);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(onScroll)
      ..dispose();
    super.dispose();
  }

  void onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      load(reset: false);
    }
  }
  Future<void> load({required bool reset}) async {
    if (reset) {
      setState(() {
        loading = true;
        error = null;
      });
    } else {
      if (loadingMore || !hasMore) return;
      setState(() => loadingMore = true);
    }

    final targetPage = reset ? 0 : page + 1;
    final response = await luminApi.sessions(page: targetPage, size: 10);
    if (!mounted) return;

    if (!response.ok) {
      setState(() {
        loading = false;
        loadingMore = false;
        error = reset ? response.error : null;
      });
      return;
    }

    final data = response.map;
    final received = SessionSummary.fromContent(data);
    final last = SessionSummary.isLast(data);

    setState(() {
      loading = false;
      loadingMore = false;
      error = null;
      page = targetPage;
      if (reset) {
        items = received;
      } else {
        final known = items.map((e) => e.id).toSet();
        items = [...items, ...received.where((e) => !known.contains(e.id))];
      }
      totalPages = SessionSummary.totalPages(data);
      hasMore = !last && received.isNotEmpty;
    });
  }

  Future<void> refresh() => load(reset: true);

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: 'Minhas sessões'),
          const SizedBox(height: 6),
          Text(
            totalPages > 0 ? '$totalPages página(s) de histórico' : 'Histórico de prática',
            style: const TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            ErrorState(message: error!, onRetry: refresh)
          else if (items.isEmpty)
            const EmptySessionsState()
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    for (final session in items)
                      SessionCard(
                        session: session,
                        onOpenWord: () => openWord(session),
                        onOpenSession: () => openSession(session),
                      ),
                    if (loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!loadingMore && !hasMore && items.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text(
                            'Você chegou ao fim do histórico',
                            style: TextStyle(color: LuminColors.muted, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void openWord(SessionSummary session) {
    final wordId = session.wordId;
    if (wordId == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: wordId)))
        .then((_) => refresh());
  }

  Future<void> openSession(SessionSummary session) async {
    final id = session.id;
    if (id == null) return;

    if (session.isFinished || session.isCompleted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SessionFinishedScreen(session: session)),
      );
      return;
    }

    final response = await luminApi.session(id);
    if (!mounted) return;
    if (!response.ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExerciseScreen(sessionId: id)),
    );
    if (mounted) refresh();
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onOpenWord,
    required this.onOpenSession,
  });

  final SessionSummary session;
  final VoidCallback onOpenWord;
  final VoidCallback onOpenSession;

  @override
  Widget build(BuildContext context) {
    final finished = session.isFinished || session.isCompleted;
    final canResume = session.wordId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: finished ? Colors.transparent : LuminColors.magenta.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenWord,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.wordTranslated.isEmpty ? 'Sessão de estudo' : session.wordTranslated,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      if (session.wordOriginal.isNotEmpty)
                        Text(
                          session.wordOriginal,
                          style: const TextStyle(color: LuminColors.muted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
              StatusTag(finished: finished),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: session.progress,
                    minHeight: 7,
                    backgroundColor: LuminColors.panelLight,
                    color: finished ? Colors.greenAccent : LuminColors.magenta,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(session.progress * 100).round()}%',
                style: const TextStyle(color: LuminColors.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${session.progressLabel} · ${session.score} acertos'
                  '${session.languageName.isEmpty ? '' : ' · ${session.languageName}'}',
                  style: const TextStyle(color: LuminColors.muted, fontSize: 11),
                ),
              ),
              if (canResume || session.id != null)
                TextButton(
                  onPressed: onOpenSession,
                  child: Text(finished ? 'Ver resultado' : 'Continuar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.finished});

  final bool finished;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: (finished ? Colors.greenAccent : LuminColors.magenta).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        finished ? 'Concluída' : 'Em andamento',
        style: TextStyle(
          color: finished ? Colors.greenAccent : LuminColors.magenta,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class EmptySessionsState extends StatelessWidget {
  const EmptySessionsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, color: LuminColors.muted, size: 40),
            SizedBox(height: 14),
            Text(
              'Você ainda não tem sessões de estudo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LuminColors.muted, fontSize: 12),
            ),
            SizedBox(height: 6),
            Text(
              'Abra uma palavra e toque em praticar para criar a primeira.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LuminColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Tentar de novo')),
          ],
        ),
      ),
    );
  }
}

class SessionFinishedScreen extends StatelessWidget {
  const SessionFinishedScreen({super.key, required this.session});

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: 'Resultado da sessão'),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LuminColors.violet, LuminColors.magenta],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.wordTranslated.isEmpty ? 'Sessão concluída' : session.wordTranslated,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                if (session.wordOriginal.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.wordOriginal,
                    style: const TextStyle(fontSize: 14, color: LuminColors.text),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '${session.score} de ${session.totalExercises} acertos',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DetailRow(label: 'Progresso', value: '${(session.progress * 100).round()}%'),
          DetailRow(label: 'Acertos', value: '${session.score}'),
          DetailRow(label: 'Exercícios', value: '${session.totalExercises}'),
          if (session.languageName.isNotEmpty)
            DetailRow(label: 'Idioma', value: session.languageName),
          DetailRow(label: 'Situação', value: session.status),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: LuminColors.panel, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(color: LuminColors.muted)),
        ],
      ),
    );
  }
}
