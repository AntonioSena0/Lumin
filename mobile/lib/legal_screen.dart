import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

enum LegalSection { terms, privacy }

/// Termos de Uso e Política de Privacidade do Lumin.
/// [initialSection] define onde o documento abre (Termos ou Política).
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key, this.initialSection = LegalSection.terms});

  final LegalSection initialSection;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final _termsKey = GlobalKey();
  final _privacyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialSection == LegalSection.privacy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _privacyKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, duration: Duration.zero);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: LuminColors.text,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Termos de Uso e Política de Privacidade',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Última atualização: 06 de outubro de 2026 · Versão 1.0',
                      style: TextStyle(color: LuminColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Este documento apresenta as condições de uso e as práticas de privacidade previstas para o aplicativo Lumin.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    _PartTitle('TERMOS DE USO', key: _termsKey),
                    ..._buildSections(_termsSections),
                    const SizedBox(height: 20),
                    _PartTitle('POLÍTICA DE PRIVACIDADE', key: _privacyKey),
                    const Text(
                      'Esta Política descreve, em linguagem objetiva, os dados que poderão ser tratados pela Lumin, as finalidades desse tratamento, as medidas de proteção e os direitos dos titulares.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    ..._buildSections(_privacySections),
                    const SizedBox(height: 20),
                    ..._buildSections(_referenceSections),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(List<_Section> sections) {
    return [
      for (final s in sections) ...[
        const SizedBox(height: 18),
        Text(
          s.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: LuminColors.text,
          ),
        ),
        const SizedBox(height: 6),
        for (final b in s.blocks) _BlockView(b),
      ],
    ];
  }
}

class _PartTitle extends StatelessWidget {
  const _PartTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: _LegalColors.violet,
        ),
      ),
    );
  }
}

class _LegalColors {
  static const Color violet = Color(0xFFB03CF0);
}

class _BlockView extends StatelessWidget {
  const _BlockView(this.block);

  final _Block block;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, height: 1.5);
    final text = Text.rich(
      TextSpan(
        children: [
          if (block.lead != null)
            TextSpan(
              text: '${block.lead} ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          TextSpan(text: block.text),
        ],
      ),
      style: style,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: block.bullet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 6, right: 8),
                  child: Text('•', style: style),
                ),
                Expanded(child: text),
              ],
            )
          : text,
    );
  }
}

class _Section {
  const _Section(this.title, this.blocks);

  final String title;
  final List<_Block> blocks;
}

class _Block {
  const _Block(this.text, {this.lead, this.bullet = false});

  final String text;
  final String? lead;
  final bool bullet;
}

const List<_Section> _termsSections = [
  _Section('1. Objeto e finalidade', [
    _Block(
      'A Lumin é uma aplicação destinada ao aprendizado de idiomas por meio de tecnologias de reconhecimento de objetos e textos, câmera, tradução e recursos de revisão de vocabulário. O aplicativo busca aproximar o aprendizado de situações do cotidiano, permitindo que o usuário identifique conteúdos por meio da câmera, consulte traduções e organize palavras para posterior estudo.',
    ),
    _Block(
      'A Lumin é uma ferramenta de apoio educacional e não substitui professores, cursos, tradutores profissionais ou serviços especializados.',
    ),
  ]),
  _Section('2. Funcionalidades', [
    _Block('utilização da câmera para identificação de objetos e textos;', bullet: true),
    _Block('tradução de palavras e expressões para o idioma selecionado;', bullet: true),
    _Block('consulta de traduções em tempo real;', bullet: true),
    _Block('salvamento de palavras e traduções;', bullet: true),
    _Block('consulta do histórico de traduções;', bullet: true),
    _Block('organização de palavras salvas em categorias ou coleções;', bullet: true),
    _Block('consulta de pronúncia, significados e exemplos, quando disponíveis;', bullet: true),
    _Block('acompanhamento do progresso de aprendizagem;', bullet: true),
    _Block('prática e revisão de palavras previamente salvas.', bullet: true),
  ]),
  _Section('3. Cadastro e conta', [
    _Block(
      'Algumas funcionalidades poderão exigir a criação de uma conta. O usuário deverá fornecer informações verdadeiras, completas e atualizadas e será responsável pela proteção de suas credenciais de acesso.',
    ),
  ]),
  _Section('4. Uso da câmera', [
    _Block(
      'A Lumin poderá solicitar acesso à câmera do dispositivo para executar as funcionalidades de reconhecimento e tradução. O acesso dependerá da autorização concedida pelo usuário no sistema operacional. A recusa ou retirada da permissão poderá impedir o funcionamento das funcionalidades relacionadas à câmera.',
    ),
    _Block(
      'O tratamento e o armazenamento das imagens dependerão da implementação técnica adotada. A versão definitiva deste documento deverá refletir exatamente se as imagens são processadas localmente, enviadas a servidores, armazenadas ou encaminhadas a fornecedores.',
    ),
  ]),
  _Section('5. Traduções e recursos automatizados', [
    _Block(
      'A Lumin poderá utilizar reconhecimento de imagem, processamento de linguagem e recursos de inteligência artificial. Resultados automatizados podem apresentar imprecisões, especialmente em razão de contexto, qualidade da imagem, idioma ou ambiguidade. As traduções devem ser consideradas ferramentas de apoio ao aprendizado.',
    ),
    _Block(
      'A Lumin não garante que uma tradução seja adequada para finalidades médicas, jurídicas, profissionais, acadêmicas ou outras situações de alta relevância.',
    ),
  ]),
  _Section('6. Conteúdo salvo pelo usuário', [
    _Block(
      'O usuário poderá salvar palavras, traduções, favoritos, categorias e outros conteúdos relacionados ao seu processo de aprendizagem. Essas informações poderão ser utilizadas para apresentar histórico, revisão, coleções e indicadores de progresso.',
    ),
  ]),
  _Section('7. Condutas proibidas', [
    _Block('utilizar o aplicativo para fins ilícitos;', bullet: true),
    _Block('tentar acessar contas, sistemas ou informações de terceiros sem autorização;', bullet: true),
    _Block('comprometer ou testar indevidamente a segurança do aplicativo;', bullet: true),
    _Block('introduzir vírus, códigos maliciosos ou mecanismos destinados a causar danos;', bullet: true),
    _Block('sobrecarregar ou explorar indevidamente os serviços;', bullet: true),
    _Block('utilizar o aplicativo de maneira incompatível com estes Termos ou com a legislação aplicável.', bullet: true),
  ]),
  _Section('8. Propriedade intelectual', [
    _Block(
      'A marca Lumin, seu nome, logotipo, identidade visual, interface, elementos gráficos, código, textos e demais materiais desenvolvidos para o aplicativo são protegidos pela legislação aplicável. O uso do aplicativo não transfere ao usuário direitos de propriedade sobre esses elementos.',
    ),
  ]),
  _Section('9. Disponibilidade', [
    _Block(
      'A Lumin buscará manter seus serviços disponíveis, mas poderão ocorrer interrupções por manutenção, atualizações, falhas técnicas, indisponibilidade de serviços de terceiros, problemas de conexão ou situações de força maior.',
    ),
  ]),
  _Section('10. Alterações dos Termos', [
    _Block(
      'Os Termos poderão ser atualizados em razão de alterações legais, técnicas ou funcionais. Alterações relevantes deverão ser comunicadas por meios adequados.',
    ),
  ]),
  _Section('11. Encerramento da conta', [
    _Block(
      'O usuário poderá solicitar o encerramento de sua conta conforme os recursos disponibilizados. A exclusão não impede a conservação de informações quando houver obrigação legal ou outra hipótese autorizada pela legislação.',
    ),
  ]),
  _Section('12. Legislação aplicável', [
    _Block(
      'Estes Termos deverão observar a legislação brasileira aplicável, incluindo a Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais), a Lei nº 12.965/2014 (Marco Civil da Internet) e a legislação de proteção e defesa do consumidor.',
    ),
  ]),
];

const List<_Section> _privacySections = [
  _Section('1. Identificação do controlador', [
    _Block('[NOME DA EQUIPE/EMPRESA]', lead: 'Controlador:'),
    _Block('[E-MAIL DE CONTATO]', lead: 'E-mail:'),
    _Block('[NOME OU CONTATO, SE APLICÁVEL]', lead: 'Encarregado:'),
    _Block(
      'Os campos acima deverão ser preenchidos com os dados oficiais responsáveis pelo aplicativo antes de sua publicação.',
    ),
  ]),
  _Section('2. Dados que poderão ser tratados', [
    _Block(
      'nome, e-mail e informações necessárias à autenticação.',
      lead: 'Dados de cadastro:',
    ),
    _Block(
      'palavras pesquisadas ou traduzidas, traduções salvas, favoritos, histórico, categorias, progresso e idiomas utilizados.',
      lead: 'Dados de aprendizagem:',
    ),
    _Block(
      'informações necessárias ao funcionamento, segurança e diagnóstico, como versão do aplicativo, sistema operacional, informações do dispositivo e registros técnicos de erros, quando aplicável.',
      lead: 'Dados técnicos:',
    ),
    _Block(
      'poderão ser tratados quando o usuário utilizar a funcionalidade de tradução por câmera. O tratamento efetivo deverá corresponder à arquitetura final do aplicativo.',
      lead: 'Dados de câmera e imagens:',
    ),
  ]),
  _Section('3. Finalidades do tratamento', [
    _Block('criar, autenticar e manter a conta do usuário;', bullet: true),
    _Block('executar traduções e recursos de reconhecimento solicitados pelo usuário;', bullet: true),
    _Block('armazenar e apresentar palavras, traduções e histórico, quando solicitado;', bullet: true),
    _Block('personalizar a experiência de aprendizagem;', bullet: true),
    _Block('acompanhar indicadores de progresso;', bullet: true),
    _Block('proteger o aplicativo contra acessos indevidos e abusos;', bullet: true),
    _Block('diagnosticar falhas e melhorar o funcionamento do serviço.', bullet: true),
  ]),
  _Section('4. Bases legais', [
    _Block(
      'O tratamento de dados pessoais deverá estar apoiado em uma das hipóteses legais previstas na LGPD, conforme a finalidade específica. Entre as hipóteses legalmente previstas estão o consentimento, o cumprimento de obrigação legal ou regulatória, a execução de contrato e o legítimo interesse, quando aplicável e observados os direitos do titular.',
    ),
    _Block(
      'Quando o tratamento depender de consentimento, este deverá ser específico, informado e passível de revogação nos termos da legislação.',
    ),
  ]),
  _Section('5. Câmera e imagens', [
    _Block(
      'A câmera é utilizada para possibilitar a identificação e tradução de objetos ou textos. O aplicativo deverá solicitar a permissão correspondente ao sistema operacional e utilizar o acesso para a finalidade informada.',
    ),
    _Block(
      'A declaração sobre armazenamento ou processamento local das imagens somente deverá ser incluída na versão definitiva se refletir a implementação real. Caso imagens sejam enviadas a servidores ou terceiros, a política deverá informar essa operação, sua finalidade, retenção e os respectivos fornecedores.',
    ),
  ]),
  _Section('6. Compartilhamento de dados', [
    _Block(
      'A Lumin não deverá comercializar dados pessoais dos usuários. O compartilhamento poderá ocorrer quando necessário à prestação de determinada funcionalidade, à operação de fornecedores contratados, ao cumprimento de obrigação legal ou ao exercício regular de direitos, sempre observadas as bases legais e os princípios aplicáveis.',
    ),
  ]),
  _Section('7. Segurança', [
    _Block(
      'A Lumin deverá adotar medidas técnicas e administrativas compatíveis com os riscos do tratamento, buscando proteger os dados contra acessos não autorizados, perda, destruição, alteração, divulgação indevida e outras formas de tratamento inadequado ou ilícito.',
    ),
  ]),
  _Section('8. Direitos dos titulares', [
    _Block(
      'Nos termos da LGPD, o titular poderá, conforme aplicável, solicitar confirmação da existência de tratamento, acesso, correção, anonimização, bloqueio ou eliminação de dados em hipóteses previstas, informações sobre compartilhamento, portabilidade, revogação do consentimento e outros direitos estabelecidos em lei.',
    ),
  ]),
  _Section('9. Solicitação de direitos', [
    _Block(
      'Solicitações relacionadas aos dados pessoais poderão ser encaminhadas para [E-MAIL DE PRIVACIDADE]. Poderão ser solicitadas informações adicionais para confirmar a identidade do titular e proteger os dados contra acesso por terceiros.',
    ),
  ]),
  _Section('10. Exclusão e retenção', [
    _Block(
      'Os dados deverão ser mantidos pelo período necessário para cumprir as finalidades informadas, respeitadas obrigações legais e demais hipóteses de conservação previstas na legislação. Quando aplicável, o usuário poderá solicitar a exclusão de sua conta e dos dados tratados com base em consentimento, observadas as exceções legais.',
    ),
  ]),
  _Section('11. Crianças e adolescentes', [
    _Block(
      'Caso a Lumin seja disponibilizada a crianças ou adolescentes, o tratamento deverá observar o melhor interesse desse público e as exigências específicas previstas na LGPD e na legislação aplicável.',
    ),
  ]),
  _Section('12. Transferência internacional', [
    _Block(
      'Caso fornecedores utilizados pela Lumin armazenem ou processem dados fora do Brasil, a operação deverá observar as regras aplicáveis à transferência internacional de dados previstas na LGPD.',
    ),
  ]),
  _Section('13. Alterações da Política', [
    _Block(
      'Esta Política poderá ser atualizada para refletir mudanças no aplicativo, na infraestrutura, nos fornecedores, nas finalidades de tratamento ou na legislação. A data da última atualização será indicada no início do documento.',
    ),
  ]),
  _Section('14. Contato', [
    _Block('Lumin'),
    _Block('[E-MAIL]', lead: 'E-mail:'),
    _Block('[NOME OU CONTATO]', lead: 'Responsável/Encarregado:'),
    _Block('[SITE, SE HOUVER]', lead: 'Site:'),
  ]),
];

const List<_Section> _referenceSections = [
  _Section('Referências legais e institucionais', [
    _Block(
      'Lei nº 13.709/2018 — Lei Geral de Proteção de Dados Pessoais (LGPD), texto oficial compilado da Presidência da República.',
      bullet: true,
    ),
    _Block(
      'Lei nº 13.709/2018 — disposições sobre direitos dos titulares, bases legais, segurança e demais regras de proteção de dados.',
      bullet: true,
    ),
    _Block(
      'Autoridade Nacional de Proteção de Dados (ANPD) — orientações sobre direitos dos titulares e exercício de direitos.',
      bullet: true,
    ),
  ]),
];