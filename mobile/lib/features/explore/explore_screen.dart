import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Explorar',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          LuminField(label: 'Pesquise palavras ou frases'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas palavras',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Ver tudo',
                style: TextStyle(color: LuminColors.magenta, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WordMiniCard(original: 'Butter', translated: 'Manteiga'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: WordMiniCard(
                  original: 'Mellow',
                  translated: 'Adocicado',
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          Text(
            'Traduzido por outros usuários',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          CategoryRow(
            icon: Icons.home,
            title: 'Cômodos',
            subtitle: '32 traduções',
          ),
          CategoryRow(
            icon: Icons.flight_takeoff,
            title: 'Viagem',
            subtitle: '20 traduções',
          ),
          CategoryRow(
            icon: Icons.checkroom,
            title: 'Roupas',
            subtitle: '40 traduções',
          ),
        ],
      ),
    );
  }
}

class WordMiniCard extends StatelessWidget {
  const WordMiniCard({
    super.key,
    required this.original,
    required this.translated,
  });

  final String original;
  final String translated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALIMENTOS',
            style: TextStyle(
              color: LuminColors.magenta,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(original, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            translated,
            style: const TextStyle(color: LuminColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: LuminColors.magenta,
              child: Icon(Icons.play_arrow, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: LuminColors.magenta),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: LuminColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
