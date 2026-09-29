import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/camera/camera_screen.dart';
import 'package:mobile/features/explore/explore_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/languages/languages_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  late final List<Widget?> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(onOpenProfile: () => selectPage(4)),
      null,
      null,
      null,
      null,
    ];
  }

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
      pages[index] ??= createPage(index);
    });
  }

  Widget? createPage(int index) {
    return switch (index) {
      1 => const ExploreScreen(),
      3 => const LanguagesScreen(),
      4 => const ProfileScreen(),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedIndex == 2
          ? const CameraScreen()
          : IndexedStack(
              index: selectedIndex,
              children: [
                for (final page in pages) page ?? const SizedBox.shrink(),
              ],
            ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(color: Color(0xFF08020F)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavigationIcon(
              icon: Icons.home,
              label: 'Início',
              selected: selectedIndex == 0,
              onTap: () => selectPage(0),
            ),
            NavigationIcon(
              icon: Icons.search,
              label: 'Explorar',
              selected: selectedIndex == 1,
              onTap: () => selectPage(1),
            ),
            NavigationIcon(
              icon: Icons.add,
              label: 'Câmera',
              selected: selectedIndex == 2,
              onTap: () => selectPage(2),
              highlighted: true,
            ),
            NavigationIcon(
              icon: Icons.article,
              label: 'Idiomas',
              selected: selectedIndex == 3,
              onTap: () => selectPage(3),
            ),
            NavigationIcon(
              icon: Icons.person,
              label: 'Perfil',
              selected: selectedIndex == 4,
              onTap: () => selectPage(4),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationIcon extends StatelessWidget {
  const NavigationIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? LuminColors.magenta : LuminColors.text;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: highlighted ? 42 : 36,
          height: highlighted ? 34 : 36,
          decoration: highlighted
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LuminColors.violet, LuminColors.magenta],
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Icon(
            icon,
            color: highlighted ? LuminColors.text : color,
            size: highlighted ? 26 : 24,
          ),
        ),
      ),
    );
  }
}
