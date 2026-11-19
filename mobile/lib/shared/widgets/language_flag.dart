import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import 'package:mobile/core/i18n/i18n.dart';

class LanguageFlag extends StatelessWidget {
  const LanguageFlag({super.key, required this.code, this.size = 21});

  final String code;
  final double size;

  /// Mostra a bandeira servida pela API ou o emoji do país quando a imagem não carrega.
  @override
  Widget build(BuildContext context) {
    final country = languageCountryForCode(code);
    if (country == null) {
      return Icon(Icons.language, size: size, color: Colors.white70);
    }
    final emoji = Text(
      country
          .toUpperCase()
          .runes
          .map((rune) => String.fromCharCode(rune + 127397))
          .join(),
      style: TextStyle(fontSize: size, height: 1),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.network(
        resolveAssetUrl('/images/flags/$country.png'),
        width: size * 4 / 3,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: t('Bandeira ${country.toUpperCase()}', 'Flag ${country.toUpperCase()}'),
        errorBuilder: (_, _, _) => emoji,
      ),
    );
  }
}

/// Converte o código do idioma (pt-BR, en) no código do país da bandeira.
String? languageCountryForCode(String code) {
  final normalized = code.trim().toLowerCase();
  const countryByLanguage = {
    'en': 'us',
    'pt': 'br',
    'es': 'es',
    'fr': 'fr',
    'de': 'de',
    'it': 'it',
    'ja': 'jp',
    'ko': 'kr',
    'zh': 'cn',
    'ru': 'ru',
  };
  final parts = normalized.split(RegExp(r'[-_]'));
  final country = parts.length > 1 ? parts.last : countryByLanguage[parts.first];
  if (country == null || country.length != 2) return null;
  return country;
}
