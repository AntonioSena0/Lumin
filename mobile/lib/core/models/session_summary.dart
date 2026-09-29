class SessionSummary {
  SessionSummary(this.raw);

  final Map<String, dynamic> raw;

  int? get id {
    final value = raw['id'];
    return value is int ? value : null;
  }

  int get currentIndex => asInt(raw['currentIndex']);

  int get totalExercises => asInt(raw['totalExercises']);

  int get score => asInt(raw['score']);

  String get status => '${raw['status'] ?? ''}';

  bool get isFinished => status == 'FINISHED';

  bool get isCompleted => totalExercises > 0 && currentIndex >= totalExercises;

  double get progress {
    if (totalExercises == 0) return 0;
    return (currentIndex / totalExercises).clamp(0, 1).toDouble();
  }

  int? get wordId {
    final value = raw['wordId'];
    return value is int ? value : null;
  }

  String get wordOriginal => '${raw['wordOriginal'] ?? ''}';

  String get wordTranslated => '${raw['wordTranslated'] ?? ''}';

  String get languageName => '${raw['languageName'] ?? ''}';

  String? get createdAt {
    final value = raw['createdAt'];
    return value is String ? value : null;
  }

  String get progressLabel {
    if (isFinished) return 'Finalizada';
    if (isCompleted) return 'Exercícios concluídos';
    if (totalExercises == 0) return 'Sem exercícios';
    return 'Exercício $currentIndex de $totalExercises';
  }

  static int asInt(dynamic value) => value is num ? value.toInt() : 0;

  static List<SessionSummary> fromContent(Map<String, dynamic> page) {
    final content = page['content'];
    if (content is! List) return const [];
    return content.whereType<Map>().map((e) => SessionSummary(Map<String, dynamic>.from(e))).toList();
  }

  static int totalPages(Map<String, dynamic> page) {
    final value = page['totalPages'];
    return value is num ? value.toInt() : 0;
  }

  static bool isLast(Map<String, dynamic> page) {
    final last = page['last'];
    if (last is bool) return last;
    return totalPages(page) == 0;
  }
}
