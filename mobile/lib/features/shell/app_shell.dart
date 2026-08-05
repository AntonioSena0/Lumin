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

  final pages = const [
    HomeScreen(),
    ExploreScreen(),
    CameraScreen(),
    LanguagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(color: Color(0xFF08020F)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavigationIcon(
              icon: Icons.home,
              selected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            NavigationIcon(
              icon: Icons.search,
              selected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),
            NavigationIcon(
              icon: Icons.add,
              selected: selectedIndex == 2,
              onTap: () => setState(() => selectedIndex = 2),
              highlighted: true,
            ),
            NavigationIcon(
              icon: Icons.article,
              selected: selectedIndex == 3,
              onTap: () => setState(() => selectedIndex = 3),
            ),
            NavigationIcon(
              icon: Icons.person,
              selected: selectedIndex == 4,
              onTap: () => setState(() => selectedIndex = 4),
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
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? LuminColors.magenta : LuminColors.text;
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
