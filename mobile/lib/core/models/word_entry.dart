class WordEntry {
  WordEntry(this.raw);

  final Map<String, dynamic> raw;

  int? get id {
    final value = raw['wordId'] ?? raw['id'];
    return value is int ? value : null;
  }

  String get original => '${raw['original'] ?? ''}';

  String get translated => '${raw['translated'] ?? ''}';

  String get description => '${raw['description'] ?? ''}';

  String get categoryName {
    final flat = raw['categoryName'];
    if (flat is String && flat.isNotEmpty) return flat;
    final category = raw['category'];
    if (category is Map && category['name'] is String) return '${category['name']}';
    return '';
  }

  bool get isSaved => raw['isSaved'] == true;

  int get correctAnswers {
    final value = raw['correctAnswers'];
    return value is num ? value.toInt() : 0;
  }

  int get incorrectAnswers {
    final value = raw['incorrectAnswers'];
    return value is num ? value.toInt() : 0;
  }

  double? get accuracy {
    final value = raw['accuracy'];
    return value is num ? value.toDouble() : null;
  }

  String get level => '${raw['level'] ?? ''}';

  static List<WordEntry> fromContent(Map<String, dynamic> page) {
    final content = page['content'];
    if (content is! List) return const [];
    return content
        .whereType<Map>()
        .map((e) => WordEntry(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// Converte uma palavra do catálogo da comunidade para o formato de palavra do usuário, marcada como ainda não salva.
Map<String, dynamic> userWordFromCatalog(Map<String, dynamic> word) {
  final category = word['category'];
  final from = word['fromLanguage'];
  final to = word['toLanguage'];
  return {
    ...word,
    'wordId': word['id'],
    'categoryId': category is Map ? category['id'] : null,
    'categoryName': category is Map ? category['name'] : null,
    'fromLanguageCode': from is Map ? from['code'] : null,
    'toLanguageCode': to is Map ? to['code'] : null,
    'isSaved': false,
    'correctAnswers': 0,
    'incorrectAnswers': 0,
  };
}
