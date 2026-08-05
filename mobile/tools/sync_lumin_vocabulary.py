import csv
import json
from pathlib import Path


root_path = Path(__file__).resolve().parents[1]
vocabulary_path = root_path / "assets" / "models" / "lumin_object_vocabulary.csv"
classes_path = root_path / "assets" / "models" / "lumin_yoloe_classes.txt"
dictionary_path = (
    root_path / "lib" / "features" / "camera" / "object_translation_dictionary.dart"
)
translations_path = (
    root_path / "assets" / "models" / "lumin_object_translations.json"
)

rows = []
seen_labels = set()

with vocabulary_path.open("r", encoding="utf-8", newline="") as file:
    reader = csv.DictReader(file)

    for row in reader:
        label = row["label"].strip().lower().replace("_", " ")
        translation = row["translation"].strip()

        if not label or not translation or label in seen_labels:
            continue

        seen_labels.add(label)
        rows.append((label, translation))

rows.sort(key=lambda item: item[0])
classes_path.write_text(
    "".join(f"{label}\n" for label, _ in rows),
    encoding="utf-8",
)
translations_path.write_text(
    json.dumps(dict(rows), ensure_ascii=False, separators=(",", ":")),
    encoding="utf-8",
)

dictionary_path.write_text(
    """import 'dart:convert';

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
    return translations?[normalizedLabel] ?? formatUnknownLabel(normalizedLabel);
  }

  static String formatUnknownLabel(String label) {
    return label
        .split(RegExp(r'\\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
""",
    encoding="utf-8",
)

print(len(rows))
