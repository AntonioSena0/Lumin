import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/camera/camera_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, Bea!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Pronta para traduzir o mundo hoje?',
                      style: TextStyle(color: LuminColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle, size: 38),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const EvolutionPanel(),
          const SizedBox(height: 22),
          const Text(
            'Continue aprendendo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          PracticeTile(
            title: 'Vocabulário: Comidas',
            subtitle: '8 de 20 palavras',
            icon: Icons.restaurant,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WordDetailScreen())),
          ),
          const SizedBox(height: 20),
          const Text(
            'Módulos',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: const [
              ModuleTile(icon: Icons.headphones, label: 'Lições'),
              ModuleTile(icon: Icons.abc, label: 'Gramática'),
              ModuleTile(icon: Icons.library_books, label: 'Vocabulário'),
              ModuleTile(icon: Icons.groups, label: 'Conversação'),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CameraScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LuminColors.violet, LuminColors.magenta],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Traduza o mundo com sua câmera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.photo_camera, size: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EvolutionPanel extends StatelessWidget {
  const EvolutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evolução',
                  style: TextStyle(color: LuminColors.muted, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Conversa em até 3 meses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 66,
            width: 66,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 7,
              backgroundColor: LuminColors.panelLight,
              color: LuminColors.magenta,
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeTile extends StatelessWidget {
  const PracticeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: LuminColors.magenta,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: LuminColors.text),
            ),
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
            const CircleAvatar(
              radius: 18,
              backgroundColor: LuminColors.magenta,
              child: Icon(Icons.play_arrow, color: LuminColors.text),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
