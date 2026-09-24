import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'chip.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';

/// O que aconteceu com o registro — define a cor da faixa e o ícone do selo
/// da tela de resultado. O layout é o mesmo em todas; só a sinalização muda.
enum AppResultKind {
  /// Inclusão concluída (verde, marca de confirmado).
  created,

  /// Alteração salva (azul, lápis).
  updated,

  /// Exclusão feita (vermelho, lixeira).
  deleted,

  /// Salvo no aparelho, esperando internet para enviar (âmbar, nuvem).
  pending,

  /// Deu certo com ressalva que a pessoa precisa ler (âmbar, alerta).
  warning,

  /// Não foi possível concluir (vermelho, xis).
  error,

  /// Informação neutra de fim de fluxo (azul, "i").
  info,
}

/// Tela de resultado dos cadastros e lançamentos: faixa colorida no topo com
/// o selo do resultado, folha branca com borda curva, título, explicação e
/// as ações de saída. [kind] troca cor e ícone; o resto não muda — a pessoa
/// aprende o desenho uma vez e lê o resultado pela cor.
///
/// Entra animada (halo abre, selo cresce com leve quique, texto e botões
/// sobem) e respeita "remover animações" do sistema. A navegação de saída
/// é de quem chama, via [actions] — em geral um `AppButtonVariant.outline`
/// (repetir) acima do CTA (seguir).
class AppSuccessPanel extends StatefulWidget {
  const AppSuccessPanel({
    super.key,
    required this.title,
    this.description,
    this.kind = AppResultKind.created,
    this.icon,
    this.actions,
  });

  final String title;
  final Widget? description;
  final AppResultKind kind;

  /// Troca o ícone padrão do [kind] (raro — o padrão já sinaliza o caso).
  final AppIconData? icon;
  final Widget? actions;

  @override
  State<AppSuccessPanel> createState() => _AppSuccessPanelState();
}

class _AppSuccessPanelState extends State<AppSuccessPanel>
    with SingleTickerProviderStateMixin {
  // Medidas do selo (Figma): halo externo, halo interno e cartão branco.
  static const double _haloOuter = 208;
  static const double _haloInner = 152;
  static const double _badge = 104;
  static const double _badgeIcon = 48;

  /// Altura mínima da faixa e profundidade da curva da folha.
  static const double _bandMin = 300;
  static const double _curve = 24;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slower * 2.25,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppChipTone get _tone => switch (widget.kind) {
    AppResultKind.created => AppChipTone.brand,
    AppResultKind.updated || AppResultKind.info => AppChipTone.blue,
    AppResultKind.pending || AppResultKind.warning => AppChipTone.amber,
    AppResultKind.deleted || AppResultKind.error => AppChipTone.red,
  };

  AppIconData get _icon =>
      widget.icon ??
      switch (widget.kind) {
        AppResultKind.created => AppIcons.checkSquare,
        AppResultKind.updated => AppIcons.editSquare,
        AppResultKind.deleted => AppIcons.deleteSquare,
        AppResultKind.pending => AppIcons.cloudSaved,
        AppResultKind.warning => AppIcons.alertSquare,
        AppResultKind.error => AppIcons.cancelSquare,
        AppResultKind.info => AppIcons.infoSquare,
      };

  Animation<double> _interval(double begin, double end, [Curve? curve]) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve ?? AppMotion.easingOut),
      );

  /// Sobe 16 px enquanto aparece.
  Widget _rise(Animation<double> a, Widget child) => AnimatedBuilder(
    animation: a,
    builder: (context, child) => Opacity(
      opacity: a.value.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, AppSpacing.space4 * (1 - a.value)),
        child: child,
      ),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tone = appToneColors(semantic, _tone);

    // Claro: faixa no tom forte, halos brancos translúcidos e cartão branco.
    // Modo GB: faixa no tom translúcido sobre o canvas (um bloco saturado
    // ofuscaria a tela escura), halos no próprio tom e cartão elevado.
    final band = dark ? Color.alphaBlend(tone.bg, semantic.bgCanvas) : tone.fg;
    final haloOuter = dark
        ? tone.fg.withValues(alpha: 0.06)
        : semantic.bgSurface.withValues(alpha: 0.06);
    final haloInner = dark
        ? tone.fg.withValues(alpha: 0.12)
        : semantic.bgSurface.withValues(alpha: 0.10);
    final badge = dark ? semantic.bgRaised : semantic.bgSurface;

    final halo = _interval(0, 0.5);
    final pop = _interval(0.1, 0.6, AppMotion.easingSpring);
    final glyph = _interval(0.35, 0.65);
    final title = _interval(0.4, 0.75);
    final description = _interval(0.5, 0.85);
    final actions = _interval(0.6, 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _bandMin / 0.42;
        final bandHeight = (height * 0.42).clamp(_bandMin, double.infinity);

        return ColoredBox(
          color: semantic.bgSurface,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: bandHeight + _curve,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipPath(
                          clipper: const _BandClipper(_curve),
                          child: ColoredBox(color: band),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: _curve,
                        child: Center(
                          child: ExcludeSemantics(
                            child: _Badge(
                              halo: halo,
                              pop: pop,
                              glyph: glyph,
                              haloOuter: haloOuter,
                              haloInner: haloInner,
                              badge: badge,
                              shadow: semantic.shadowCard,
                              icon: _icon,
                              iconColor: tone.fg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space6,
                    AppSpacing.space6,
                    AppSpacing.space6,
                    AppSpacing.space8,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      children: [
                        _rise(
                          title,
                          Semantics(
                            header: true,
                            liveRegion: true,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: AppTypography.xl3,
                                fontWeight: AppTypography.weightSemibold,
                                height: AppTypography.lineHeightTight,
                                color: semantic.fgHeading,
                              ),
                            ),
                          ),
                        ),
                        if (widget.description != null) ...[
                          const SizedBox(height: AppSpacing.space3),
                          _rise(
                            description,
                            DefaultTextStyle.merge(
                              style: TextStyle(
                                fontSize: AppTypography.lg,
                                height: AppTypography.lineHeightSnug,
                                color: semantic.fgSecondary,
                              ),
                              textAlign: TextAlign.center,
                              child: widget.description!,
                            ),
                          ),
                        ],
                        if (widget.actions != null) ...[
                          const SizedBox(height: AppSpacing.space10),
                          _rise(
                            actions,
                            SizedBox(
                              width: double.infinity,
                              child: widget.actions!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.halo,
    required this.pop,
    required this.glyph,
    required this.haloOuter,
    required this.haloInner,
    required this.badge,
    required this.shadow,
    required this.icon,
    required this.iconColor,
  });

  final Animation<double> halo;
  final Animation<double> pop;
  final Animation<double> glyph;
  final Color haloOuter;
  final Color haloInner;
  final Color badge;
  final List<BoxShadow> shadow;
  final AppIconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([halo, pop, glyph]),
      builder: (context, _) {
        final h = halo.value;
        return SizedBox.square(
          dimension: _AppSuccessPanelState._haloOuter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: h.clamp(0, 1),
                child: Transform.scale(
                  scale: 0.6 + 0.4 * h,
                  child: _square(
                    _AppSuccessPanelState._haloOuter,
                    AppRadius.xl4,
                    haloOuter,
                  ),
                ),
              ),
              Opacity(
                opacity: h.clamp(0, 1),
                child: Transform.scale(
                  scale: 0.7 + 0.3 * h,
                  child: _square(
                    _AppSuccessPanelState._haloInner,
                    AppRadius.xl3,
                    haloInner,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.4 + 0.6 * pop.value,
                child: Container(
                  width: _AppSuccessPanelState._badge,
                  height: _AppSuccessPanelState._badge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badge,
                    borderRadius: BorderRadius.circular(AppRadius.tile),
                    boxShadow: shadow,
                  ),
                  child: Opacity(
                    opacity: glyph.value.clamp(0, 1),
                    child: AppIcon(
                      icon,
                      size: _AppSuccessPanelState._badgeIcon,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _square(double size, double radius, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Faixa do topo com a borda de baixo côncava: a folha branca sobe em arco
/// no centro, como no Figma.
class _BandClipper extends CustomClipper<Path> {
  const _BandClipper(this.curve);

  final double curve;

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..quadraticBezierTo(size.width / 2, size.height - curve * 2, 0, size.height)
    ..close();

  @override
  bool shouldReclip(_BandClipper oldClipper) => oldClipper.curve != curve;
}

Widget _exemplo(AppResultKind kind, String title, String description) =>
    SizedBox(
      height: 760,
      child: AppSuccessPanel(
        kind: kind,
        title: title,
        description: Text(description),
        actions: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              variant: AppButtonVariant.outline,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () {},
              child: const Text('NOVA PESAGEM'),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppButton(
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () {},
              child: const Text('VER TODAS'),
            ),
          ],
        ),
      ),
    );

WidgetbookComponent buildSuccessPanelWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SuccessPanel',
    useCases: [
      WidgetbookUseCase(
        name: 'Inclusão',
        builder: (context) => _exemplo(
          AppResultKind.created,
          'Pesagem registrada!',
          'Tudo certo por aqui. Sua pesagem foi registrada com sucesso e já '
              'está no sistema.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Alteração',
        builder: (context) => _exemplo(
          AppResultKind.updated,
          'Pesagem atualizada!',
          'As mudanças foram salvas. O registro já aparece com os dados novos.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Exclusão',
        builder: (context) => _exemplo(
          AppResultKind.deleted,
          'Pesagem excluída',
          'O registro foi apagado e não aparece mais na lista.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Salvo sem internet',
        builder: (context) => _exemplo(
          AppResultKind.pending,
          'Salvo no celular',
          'Sem internet agora. A pesagem fica guardada e é enviada quando o '
              'sinal voltar.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Aviso',
        builder: (context) => _exemplo(
          AppResultKind.warning,
          'Pesagem registrada, confira',
          'O peso ficou bem acima do esperado para o lote. Confira se não '
              'sobrou um zero.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Erro',
        builder: (context) => _exemplo(
          AppResultKind.error,
          'Não deu para salvar',
          'Algo deu errado ao registrar a pesagem. Tente de novo em alguns '
              'minutos.',
        ),
      ),
      WidgetbookUseCase(
        name: 'Informação',
        builder: (context) => _exemplo(
          AppResultKind.info,
          'Nada para enviar',
          'Todos os lançamentos deste celular já estão no sistema.',
        ),
      ),
    ],
  );
}
