import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/i18n/i18n.dart';

final _literal = RegExp(r"'((?:[^'\\\n]|\\.)*)'");

String _unescape(String s) => s.replaceAll(r'\n', '\n').replaceAll(r"\'", "'");

Iterable<File> _sources() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && !f.path.contains('i18n'));

void main() {
  tearDown(() => appLanguage.value = 'pt');

  test('tr and t follow the app language', () {
    appLanguage.value = 'pt';
    expect(tr('Salvar'), 'Salvar');
    expect(t('Nível 2', 'Level 2'), 'Nível 2');

    appLanguage.value = 'en';
    expect(tr('Salvar'), 'Save');
    expect(t('Nível 2', 'Level 2'), 'Level 2');
    expect(tr('texto sem tradução'), 'texto sem tradução');
  });

  test('ui language comes from the backend language code', () {
    expect(uiLanguageFor('pt-BR'), 'pt');
    expect(uiLanguageFor('en'), 'en');
  });

  test('applyLanguage uses the language returned by the API', () {
    applyLanguage({'id': 2, 'code': 'en', 'name': 'English'});
    expect(appLanguage.value, 'en');
    expect(appLanguageId, 2);

    applyLanguage({'id': 1, 'code': 'pt-BR'});
    expect(appLanguage.value, 'pt');
    expect(appLanguageId, 1);
  });

  test('applyLanguage ignores invalid payloads', () {
    applyLanguage({'id': 2, 'code': 'en'});
    applyLanguage(null);
    applyLanguage({'message': 'erro'});
    expect(appLanguage.value, 'en');
  });

  test('every tr() call has an English translation', () {
    final call = RegExp(r"\btr\(\s*'((?:[^'\\\n]|\\.)*)'\s*\)");
    final missing = <String>[];
    for (final file in _sources()) {
      for (final m in call.allMatches(file.readAsStringSync())) {
        final key = _unescape(m.group(1)!);
        if (!enStrings.containsKey(key)) missing.add('${file.path}: $key');
      }
    }
    expect(missing, isEmpty);
  });

  test('no translatable text is shown without tr()', () {
    final untranslated = <String>[];
    for (final file in _sources()) {
      if (file.path.endsWith('legal_screen.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final m in _literal.allMatches(line)) {
          final key = _unescape(m.group(1)!);
          if (!enStrings.containsKey(key) || enStrings[key] == key) continue;
          final before = line.substring(0, m.start);
          if (RegExp(r'\b(tr|t)\(\s*$').hasMatch(before)) continue;
          if (RegExp(r'\bt\(.*,\s*$').hasMatch(before)) continue;
          untranslated.add('${file.path}:${i + 1}: $key');
        }
      }
    }
    expect(untranslated, isEmpty);
  });

  test('legal texts are fully translated', () {
    final source = File('lib/legal_screen.dart').readAsStringSync();
    final missing = _literal
        .allMatches(source)
        .map((m) => _unescape(m.group(1)!))
        .where((s) => RegExp(r'[A-Za-zÀ-ÿ]{3}').hasMatch(s) && !s.contains(r'$') && !s.startsWith('package:'))
        .where((s) => !enStrings.containsKey(s))
        .toList();
    expect(missing, isEmpty);
  });
}
