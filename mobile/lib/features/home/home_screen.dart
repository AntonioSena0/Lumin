import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/core/models/word_entry.dart';
import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/repositories/lumin_repository.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/explore/explore_screen.dart';
import 'package:mobile/features/translation/word_detail_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_avatar.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';
import 'package:mobile/shared/widgets/language_flag.dart';

const String _font = 'Poppins';

const TextStyle _heading = TextStyle(
  fontFamily: _font,
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenProfile, this.onOpenCamera});

  final VoidCallback? onOpenProfile;

  /// Toque no banner "Traduza o mundo com sua câmera".
  /// O destino é definido por quem usa a tela (ex.: AppShell).
  final VoidCallback? onOpenCamera;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  String? avatarUrl;
  double progress = 0;
  String level = '';
  String xpText = '';
  String languageName = '';
  String languageCode = '';
  String continueTitle = 'Vocabulário';
  String continueSubtitle = 'Comece agora';
  String continueCategory = '';
  int? continueWordId;
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait<Object?>([
      luminApi.me(),
      luminRepository.homeSummary(),
      luminApi.categories(),
    ]);
    if (!mounted) return;
    setState(() {
      final user = (results[0] as ApiResult).map;
      if (user['name'] is String) name = user['name'] as String;
      final avatar = user['avatar'];
      if (avatar is Map && avatar['imgUrl'] is String) {
        avatarUrl = avatar['imgUrl'] as String;
      }

      final homeResult = results[1] as RepositoryResult<HomeSummaryModel>;
      final home = homeResult.data;
      if (home != null) {
        level = home.level;
        progress = home.levelProgress.clamp(0, 1).toDouble();
        xpText = '${home.xp} XP';
        languageName = home.languageName;
        languageCode = home.languageCode;
      }

      final recent = home?.recentWords;
      if (recent != null && recent.isNotEmpty) {
        final entry = recent.first;
        if (entry.translated.isNotEmpty) {
          continueTitle = 'Vocabulário: ${entry.translated}';
        }
        if (entry.original.isNotEmpty) {
          continueSubtitle = 'Praticar ${entry.original}';
        }
        continueCategory = entry.categoryName;
        continueWordId = entry.wordId;
      }

      modules = (results[2] as ApiResult).list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] is int)
          .toList();
    });
  }

  void openProfile() {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!();
    }
  }

  void openModules() {
    if (modules.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeModulesScreen(modules: modules, onSelected: load),
      ),
    );
  }

  void openModule(Map<String, dynamic> module) {
    final id = module['id'];
    if (id is! int) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryWordsScreen(
              categoryId: id,
              title: '${module['name'] ?? ''}',
            ),
          ),
        )
        .then((_) => load());
  }

  Widget continueLeading() {
    if (languageCode.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: LuminColors.magenta,
          shape: BoxShape.circle,
        ),
        child: Icon(moduleIcon(continueCategory), color: Colors.white),
      );
    }
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipOval(child: LanguageFlag(code: languageCode, size: 50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Olá!' : 'Olá, $name!',
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Pronta para traduzir o mundo hoje?',
                      style: TextStyle(
                        fontFamily: _font,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: openProfile,
                child: ProfileAvatar(imgUrl: avatarUrl, name: name),
              ),
            ],
          ),
          const SizedBox(height: 18),
          EvolutionPanel(
            progress: progress,
            level: level,
            xpText: xpText,
            languageName: languageName,
            languageCode: languageCode,
          ),
          const SizedBox(height: 22),
          const Text('Continue aprendendo', style: _heading),
          const SizedBox(height: 10),
          PracticeTile(
            title: continueTitle,
            subtitle: continueSubtitle,
            icon: moduleIcon(continueCategory),
            leading: continueLeading(),
            progress: progress,
            onTap: () {
              if (continueWordId == null) {
                openModules();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordDetailScreen(wordId: continueWordId),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Módulos', style: _heading),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final module in modules)
                GestureDetector(
                  onTap: () => openModule(module),
                  child: ModuleTile(
                    icon: moduleIcon('${module['name'] ?? ''}'),
                    label: '${module['name'] ?? ''}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          CameraBanner(onTap: widget.onOpenCamera),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Avatar do topo: foto do usuário ou círculo branco com silhueta (wireframe).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.imgUrl, this.name = ''});

  final String? imgUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imgUrl != null && imgUrl!.isNotEmpty) {
      return LuminAvatar(imgUrl: imgUrl, name: name, radius: 22);
    }
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 30, color: Color(0xFF0B0620)),
    );
  }
}

class EvolutionPanel extends StatelessWidget {
  const EvolutionPanel({
    super.key,
    this.progress = 0,
    this.level = '',
    this.xpText = '',
    this.languageName = '',
    this.languageCode = '',
    this.goal = 'Conversação em até 3 meses',
  });

  final double progress;
  final String level;
  final String xpText;
  final String languageName;
  final String languageCode;
  final String goal;

  @override
  Widget build(BuildContext context) {
    final summary = [
      if (languageName.isNotEmpty) languageName,
      level.isEmpty ? 'Comece seu nivelamento' : 'Nível $level',
      if (xpText.isNotEmpty) xpText,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seu Objetivo',
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFD0CCE0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  goal,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (languageName.isNotEmpty) ...[
                      LanguageFlag(code: languageCode, size: 14),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        summary,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: LuminColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GradientRing(progress: progress),
        ],
      ),
    );
  }
}

/// Anel de progresso com degradê azul → magenta e porcentagem no centro.
class GradientRing extends StatelessWidget {
  const GradientRing({super.key, required this.progress, this.size = 78});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0, 1).toDouble();
    return Semantics(
      label: 'Progresso ${(value * 100).round()} por cento',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size(size, size), painter: _RingPainter(value)),
            ExcludeSemantics(
              child: Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontFamily: _font,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFF2A2538),
    );

    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          colors: [
            Color(0xFF4D7CFF),
            Color(0xFF8A3DFF),
            Color(0xFFFF4FD8),
            Color(0xFF4D7CFF),
          ],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class PracticeTile extends StatelessWidget {
  const PracticeTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.leading,
    this.progress,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  /// Elemento à esquerda (ex.: bandeira do idioma). Se nulo, usa [icon].
  final Widget? leading;

  /// Valor de 0 a 1 da barra de progresso. Se nulo, a barra não aparece.
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lead = leading ??
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: LuminColors.magenta,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon ?? Icons.translate, color: LuminColors.text),
        );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: LuminColors.panel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            lead,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: const Color(0xFF3A3A47),
                        color: const Color(0xFF6B14D6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF4D7CFF), Color(0xFFD10FD3)],
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner "Traduza o mundo com sua câmera".
class CameraBanner extends StatelessWidget {
  const CameraBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Traduza o mundo com sua câmera. Aponte, traduza, aprenda na hora.',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF4A0BC6), Color(0xFF8A1FDB), Color(0xFFD10FD3)],
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Traduza o mundo\ncom sua câmera',
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Aponte, Traduza,\nAprenda na hora.',
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ExcludeSemantics(child: CameraIllustration()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Câmera estilizada desenhada em código. Para usar uma imagem pronta,
/// troque o conteúdo por Image.asset(...).
class CameraIllustration extends StatelessWidget {
  const CameraIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // detalhes no topo
          Positioned(
            left: 12,
            top: 0,
            child: Container(
              width: 30,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFB27BE8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 2,
            child: Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE24BD2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // corpo
          Positioned(
            left: 0,
            right: 0,
            top: 8,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(color: const Color(0xFFEFE8E2)),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(color: const Color(0xFF3A3850)),
                  ),
                ],
              ),
            ),
          ),
          // lente
          Positioned(
            left: 30,
            top: 14,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2840),
                border: Border.all(color: const Color(0xFFD9D4DC), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0x55000000), blurRadius: 6),
                ],
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [
                        Color(0xFF7A4BE0),
                        Color(0xFF2A1670),
                        Color(0xFF0E0828),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: const Alignment(-0.4, -0.4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0x99FFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ícones das categorias
// ---------------------------------------------------------------------------

/// Minúsculas e sem acentos ("Saúde" -> "saude", "Lição" -> "licao").
String _normalize(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

/// Regras: palavras-chave -> ícone. A ordem importa (mais específico primeiro).
/// Chave normal = palavra exata (aceita plural com "s"/"es").
/// Chave terminada em "*" = prefixo da palavra (ex.: 'vocab*' -> vocabulário).
const List<(List<String>, IconData)> _iconRules = [
  // Módulos do wireframe
  (['licao', 'licoes', 'lesson', 'aula'], Icons.play_lesson),
  (['gramatica', 'grammar'], Icons.abc),
  (['vocab*'], Icons.menu_book),
  (['convers*', 'chat', 'dialogo'], Icons.people),
  // Categorias
  (['comida', 'food', 'aliment*', 'refeicao', 'restaurante', 'cozinha'], Icons.restaurant),
  (['bebida', 'drink', 'cafe'], Icons.local_cafe),
  (['fruta', 'fruit', 'legume', 'vegetal', 'verdura'], Icons.eco),
  (['animal', 'animais', 'pet', 'bicho'], Icons.pets),
  (['casa', 'house', 'home', 'lar', 'moradia'], Icons.home),
  (['roupa', 'cloth*', 'vestuario', 'moda', 'fashion'], Icons.checkroom),
  (['tecnolog*', 'tech', 'computador', 'internet'], Icons.devices),
  (['natureza', 'nature', 'ambiente'], Icons.park),
  (['clima', 'weather'], Icons.wb_sunny),
  (['viagem', 'viagens', 'travel', 'turismo', 'aeroporto'], Icons.flight_takeoff),
  (['transporte', 'transport', 'carro', 'veiculo'], Icons.directions_car),
  (['hotel', 'hospedagem'], Icons.hotel),
  (['cidade', 'city', 'lugar', 'place'], Icons.location_city),
  (['compra', 'shopping', 'loja', 'mercado', 'store'], Icons.shopping_cart),
  (['dinheiro', 'money', 'financ*', 'banco'], Icons.attach_money),
  (['estudo', 'educa*', 'escola', 'school', 'study'], Icons.school),
  (['arte', 'art', 'cultura', 'culture'], Icons.palette_outlined),
  (['musica', 'music', 'som'], Icons.music_note),
  (['filme', 'movie', 'cinema', 'serie'], Icons.movie),
  (['jogo', 'game'], Icons.sports_esports),
  (['esporte', 'sport', 'fitness', 'academia'], Icons.sports_soccer),
  (['saude', 'health', 'medicina', 'hospital'], Icons.health_and_safety_outlined),
  (['corpo', 'body'], Icons.accessibility_new),
  (['familia', 'family', 'parente'], Icons.family_restroom),
  (['sentimento', 'emocao', 'feeling', 'emotion'], Icons.favorite_border),
  (['cumprimento', 'saudacao', 'greeting'], Icons.waving_hand),
  (['numero', 'number'], Icons.numbers),
  (['cor', 'color'], Icons.color_lens_outlined),
  (['trabalho', 'work', 'profissao', 'emprego', 'job', 'carreira'], Icons.work_outline),
];

bool _wordMatches(String word, String key) {
  if (key.endsWith('*')) {
    return word.startsWith(key.substring(0, key.length - 1));
  }
  return word == key || word == '${key}s' || word == '${key}es';
}

IconData moduleIcon(String name) {
  final words = _normalize(name)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return Icons.translate;

  for (final (keys, icon) in _iconRules) {
    for (final w in words) {
      for (final k in keys) {
        if (_wordMatches(w, k)) return icon;
      }
    }
  }
  return Icons.category_outlined;
}

class HomeModulesScreen extends StatefulWidget {
  const HomeModulesScreen({
    super.key,
    required this.modules,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> modules;
  final Future<void> Function() onSelected;

  @override
  State<HomeModulesScreen> createState() => _HomeModulesScreenState();
}

class _HomeModulesScreenState extends State<HomeModulesScreen> {
  List<WordEntry> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final response = await luminApi.words(page: 0, size: 40);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) items = WordEntry.fromContent(response.map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Módulos'),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            for (final module in widget.modules)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CategoryRow(
                  icon: moduleIcon('${module['name'] ?? ''}'),
                  title: '${module['name'] ?? ''}',
                  subtitle: '${module['description'] ?? ''}',
                  onTap: () => openCategory(module),
                ),
              ),
          const SizedBox(height: 20),
          const Text(
            'Suas palavras',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ModuleWordRow(
                entry: item,
                onOpen: () => openWord(item),
                onSaved: load,
              ),
            ),
        ],
      ),
    );
  }

  void openCategory(Map<String, dynamic> module) {
    final id = module['id'];
    if (id is! int) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryWordsScreen(
              categoryId: id,
              title: '${module['name'] ?? ''}',
            ),
          ),
        )
        .then((_) => widget.onSelected());
  }

  void openWord(WordEntry entry) {
    final id = entry.id;
    if (id == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WordDetailScreen(wordId: id)))
        .then((_) => widget.onSelected());
  }
}

class ModuleWordRow extends StatelessWidget {
  const ModuleWordRow({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onSaved,
  });

  final WordEntry entry;
  final VoidCallback onOpen;
  final Future<void> Function() onSaved;

  @override
  Widget build(BuildContext context) {
    final saved = entry.isSaved;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuminColors.panel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.original,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    entry.translated,
                    style: const TextStyle(
                      color: LuminColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => toggle(context),
            icon: Icon(
              saved ? Icons.star : Icons.star_border,
              color: LuminColors.magenta,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggle(BuildContext context) async {
    final id = entry.id;
    if (id == null) return;
    if (entry.isSaved) {
      await luminApi.unsaveWord(id);
    } else {
      final categoryId = entry.raw['categoryId'];
      if (categoryId is! int) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta palavra ainda não tem categoria.'),
          ),
        );
        return;
      }
      await luminApi.saveWord(
        original: entry.original,
        translated: entry.translated,
        categoryId: categoryId,
      );
    }
    await onSaved();
  }
}