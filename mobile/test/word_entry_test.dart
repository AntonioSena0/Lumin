import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/models/word_entry.dart';

void main() {
  test('catalog word becomes an unsaved user word for the detail screen', () {
    final word = userWordFromCatalog({
      'id': 7,
      'original': 'teclado',
      'translated': 'keyboard',
      'description': 'Dispositivo para digitar.',
      'category': {'id': 3, 'name': 'Tecnologia'},
      'fromLanguage': {'id': 1, 'code': 'pt-BR'},
      'toLanguage': {'id': 2, 'code': 'en'},
    });

    expect(word['wordId'], 7);
    expect(word['categoryId'], 3);
    expect(word['categoryName'], 'Tecnologia');
    expect(word['isSaved'], isFalse);
    expect(word['correctAnswers'], 0);
    expect(word['fromLanguageCode'], 'pt-BR');
    expect(word['toLanguageCode'], 'en');
  });

  test('catalog entries expose id and category name', () {
    final entries = WordEntry.fromContent({
      'content': [
        {'id': 7, 'original': 'teclado', 'translated': 'keyboard', 'category': {'id': 3, 'name': 'Tecnologia'}},
      ],
    });

    expect(entries.single.id, 7);
    expect(entries.single.categoryName, 'Tecnologia');
  });
}
