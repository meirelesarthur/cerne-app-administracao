import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_motion.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.image,
    required this.title,
    required this.desc,
  });

  /// Fallback do hero caso o asset falhe ao carregar — ver
  /// `AppIllustrationSlot(fullBleed: true)`.
  final AppIconData icon;
  final String image;
  final String title;
  final String desc;
}

/// Slides do onboarding — hero full-bleed com foto fotorealista em
/// `assets/images/` (ícone fica como fallback se o asset falhar).
///
/// Cinco slides, um por capacidade mais atrativa do superapp (levantamento de
/// 15/09/2026): campo offline-first, painéis de decisão, banco, crédito e
/// marketplace/armazém. Substitui o carrossel anterior de 3 slides, que
/// fundia banco+crédito e marketplace+armazém e não cobria os painéis
/// administrativos.
const _slides = [
  _OnboardingSlide(
    icon: AppIcons.sprout,
    image: 'assets/images/onboard_campo.jpg',
    title: 'Sua fazenda na palma da mão',
    desc:
        'Lance arraçoamento, pesagem e manejo direto do curral — mesmo sem sinal, tudo sincroniza quando a conexão voltar.',
  ),
  _OnboardingSlide(
    icon: AppIcons.layoutDashboard,
    image: 'assets/images/onboard_paineis.jpg',
    title: 'Decisão na tela, não na planilha',
    desc:
        'Resultado, confinamento, suprimentos e ativos consolidados em painéis que viram decisão na hora.',
  ),
  _OnboardingSlide(
    icon: AppIcons.landmark,
    image: 'assets/images/onboard_bank.jpg',
    title: 'Seu banco, dentro da fazenda',
    desc:
        'Conta digital, Pix, pagamentos e cartões do produtor — sem trocar de app para cuidar do financeiro.',
  ),
  _OnboardingSlide(
    icon: AppIcons.handCoins,
    image: 'assets/images/onboard_credito.jpg',
    title: 'Crédito sob medida pra sua safra',
    desc:
        'Simule e contrate crédito pré-aprovado, acompanhe propostas e contratos direto pelo celular.',
  ),
  _OnboardingSlide(
    icon: AppIcons.shoppingBag,
    image: 'assets/images/onboard_marketplace.jpg',
    title: 'Compre, venda e armazene sem sair do app',
    desc:
        'Marketplace de insumos e máquinas integrado ao controle de estoque e logística do armazém.',
  ),
];

/// Onboarding do Shell: carrossel de 5 telas (hero full-bleed + título +
/// descrição), com Pular e Próximo; o último slide convida a começar.
/// Suporta swipe via `PageView`. A imagem encosta nas bordas — inclusive sob
/// a status bar — retangular, sem raio próprio; a folha branca de texto
/// sobrepõe levemente a base da imagem com um arco suave no topo, dentro da
/// área segura. Título limitado a 2 linhas (trunca com reticências) para
/// não quebrar o layout da folha.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _slide = 0;

  bool get _isLast => _slide == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go('/login');

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: AppMotion.medium, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgSurface,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _slide = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Column(
                  // `Clip.none` (padrão do Flex) é o que permite a folha
                  // abaixo pintar por cima da base da imagem — ver o
                  // `Transform.translate` nela.
                  children: [
                    // Full-bleed: encosta no topo real da tela (sob a status
                    // bar), não na área segura — só a folha de texto abaixo
                    // respeita o SafeArea. Retangular: o raio agora é da
                    // folha branca que sobrepõe a base dela, não da imagem.
                    Expanded(
                      flex: 7,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppIllustrationSlot(
                            alt: slide.title,
                            icon: slide.icon,
                            src: slide.image,
                            fullBleed: true,
                          ),
                          const Positioned(
                            top: AppSpacing.space4,
                            left: AppSpacing.space6,
                            child: SafeArea(
                              bottom: false,
                              child: AppBrandLogo(
                                variant: AppBrandLogoVariant.onDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      // `Transform.translate` sobrepõe a folha à base da foto;
                      // o recorte curvo revela a imagem ao longo da divisão.
                      child: Transform.translate(
                        offset: const Offset(0, -AppSpacing.space5),
                        child: ClipPath(
                          clipper: const _OnboardingPanelClipper(),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            color: semantic.bgSurface,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.space6,
                                AppSpacing.space4 + AppSpacing.space5,
                                AppSpacing.space6,
                                AppSpacing.space4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 340,
                                    ),
                                    child: AppHeading(
                                      level: AppHeadingLevel.h1,
                                      // +8px sobre o h1 global, só no hero.
                                      style: const TextStyle(
                                        fontSize: AppTypography.xlPlus2 + 8,
                                      ),
                                      child: Text(
                                        slide.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space2),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 320,
                                    ),
                                    child: Text(
                                      slide.desc,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: semantic.fgMuted,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space6,
                0,
                AppSpacing.space6,
                AppSpacing.space6,
              ),
              // Lado a lado (Pular + Próximo) em todo step intermediário; no
              // último, só "Começar" ocupa a largura toda — não há mais o que
              // pular.
              child: _isLast
                  ? AppButton(
                      width: 345,
                      height: 52,
                      size: AppButtonSize.lg,
                      onPressed: _next,
                      child: const Text('Começar'),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            fullWidth: true,
                            height: 52,
                            size: AppButtonSize.lg,
                            variant: AppButtonVariant.subtle,
                            onPressed: _finish,
                            child: const Text('Pular'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: AppButton(
                            fullWidth: true,
                            height: 52,
                            size: AppButtonSize.lg,
                            onPressed: _next,
                            child: const Text('Próximo'),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A folha branca sobe ao centro e encontra a foto mais abaixo nas laterais,
/// formando a curva côncava suave do onboarding de referência.
class _OnboardingPanelClipper extends CustomClipper<Path> {
  const _OnboardingPanelClipper();

  @override
  Path getClip(Size size) {
    final curveDepth = AppSpacing.space8;
    final path = Path()..moveTo(0, curveDepth);
    path
      ..cubicTo(
        size.width * .18,
        curveDepth,
        size.width * .3,
        0,
        size.width / 2,
        0,
      )
      ..cubicTo(
        size.width * .7,
        0,
        size.width * .82,
        curveDepth,
        size.width,
        curveDepth,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _OnboardingPanelClipper oldClipper) => false;
}
