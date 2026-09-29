import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class SettingsLanguageScreen extends StatefulWidget {
  const SettingsLanguageScreen({super.key});

  @override
  State<SettingsLanguageScreen> createState() => _SettingsLanguageScreenState();
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  List<Map<String, dynamic>> languages = [];
  int? selectedId;
  int? previousId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([luminApi.languages(), luminApi.settings()]);
    if (!mounted) return;
    setState(() {
      languages = results[0].list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final appLanguage = results[1].map['appLanguage'];
      if (appLanguage is Map && appLanguage['id'] is int) {
        selectedId = appLanguage['id'] as int;
        previousId = selectedId;
      }
    });
  }

  Future<void> select(int id) async {
    setState(() {
      previousId = selectedId;
      selectedId = id;
    });
    final response = await luminApi.updateSettings({'appLanguage': id});
    if (!mounted) return;
    if (!response.ok) {
      setState(() => selectedId = previousId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Idioma do app'),
          const SizedBox(height: 16),
          for (final lang in languages)
            if (lang['id'] is int)
              PreferenceOption(
                title: '${lang['name'] ?? ''}',
                description: '${lang['code'] ?? ''}',
                selected: lang['id'] == selectedId,
                onTap: () => select(lang['id'] as int),
              ),
        ],
      ),
    );
  }
}

class PreferenceOption extends StatelessWidget {
  const PreferenceOption({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? LuminColors.panelLight : LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? LuminColors.magenta : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: LuminColors.muted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? LuminColors.magenta : LuminColors.muted,
          ),
        ],
      ),
      ),
    );
  }
}
