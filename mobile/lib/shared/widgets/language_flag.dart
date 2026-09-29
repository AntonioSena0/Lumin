import 'package:flutter/material.dart';

class LanguageFlag extends StatelessWidget {
  const LanguageFlag({super.key, required this.code, this.size = 21});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final flag = languageFlagForCode(code);
    if (flag == null) {
      return Icon(Icons.language, size: size, color: Colors.white70);
    }
    return Text(flag, style: TextStyle(fontSize: size, height: 1));
  }
}

String? languageFlagForCode(String code) {
  final normalized = code.trim().toLowerCase();
  const countryByLanguage = {
    'en': 'us',
    'es': 'es',
    'fr': 'fr',
    'de': 'de',
    'it': 'it',
    'ja': 'jp',
    'ko': 'kr',
    'zh': 'cn',
    'ru': 'ru',
  };
  final language = normalized.split(RegExp(r'[-_]')).first;
  final country = normalized.contains('-') || normalized.contains('_')
      ? normalized.split(RegExp(r'[-_]')).last
      : countryByLanguage[language];
  if (country == null || country.length != 2) return null;
  return country
      .toUpperCase()
      .runes
      .map((rune) => String.fromCharCode(rune + 127397))
      .join();
}
