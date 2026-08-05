import 'dart:convert';

import 'package:flutter/services.dart';

class ObjectTranslationDictionary {
  const ObjectTranslationDictionary._();

  static const translationsPath =
      'assets/models/lumin_object_translations.json';
  static Map<String, String>? translations;

  static Future<void> ensureLoaded() async {
    if (translations != null) {
      return;
    }

    final content = await rootBundle.loadString(translationsPath);
    final decodedTranslations = jsonDecode(content) as Map<String, dynamic>;

    translations = decodedTranslations.map(
      (label, translation) => MapEntry(normalize(label), '$translation'),
    );
  }

  static String normalize(String label) {
    return label.trim().toLowerCase().replaceAll('_', ' ');
  }

  static String translate(String label) {
    final normalizedLabel = normalize(label);
    return translations?[normalizedLabel] ??
        formatUnknownLabel(normalizedLabel);
  }

  static String formatUnknownLabel(String label) {
    return label
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
