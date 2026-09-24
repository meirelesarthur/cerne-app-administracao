import 'package:flutter/material.dart';

import '../generated/app_colors.dart';
import '../generated/app_shadows.dart';

/// Cores e sombras semânticas (light | gbMode), equivalente às CSS vars
/// trocadas via `data-theme` no protótipo React (`src/styles/tokens.css`).
///
/// Consumir via `Theme.of(context).extension<AppSemanticColors>()!`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.fgDefault,
    required this.fgHeading,
    required this.fgSection,
    required this.fgMuted,
    required this.fgSecondary,
    required this.fgSubtle,
    required this.fgQuiet,
    required this.fgPlaceholder,
    required this.fgInverse,
    required this.bgCanvas,
    required this.bgSheet,
    required this.bgSurface,
    required this.bgSubtle,
    required this.bgRaised,
    required this.bgTrack,
    required this.bgKpi,
    required this.fieldOnSurface,
    required this.fieldOnCanvas,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSubtle,
    required this.borderTint,
    required this.accentDefault,
    required this.accentHover,
    required this.accentSubtle,
    required this.accentContrast,
    required this.inkBg,
    required this.inkFg,
    required this.inkMuted,
    required this.inkSubtle,
    required this.inkBubble,
    required this.inkLine,
    required this.heroFrom,
    required this.heroTo,
    required this.heroFg,
    required this.heroFgMuted,
    required this.heroFgSubtle,
    required this.heroOverlay,
    required this.heroLine,
    required this.ctaBg,
    required this.ctaHover,
    required this.ctaFg,
    required this.navBg,
    required this.navFg,
    required this.navActive,
    required this.navBorder,
    required this.shadowCard,
    required this.shadowCardHover,
    required this.shadowModal,
    required this.chartSeries,
    required this.chartGrid,
    required this.chartAxis,
    required this.chartTrack,
    required this.chartPositive,
    required this.chartNegative,
    required this.statusSuccessFg,
    required this.statusSuccessBg,
    required this.statusSuccessBorder,
    required this.statusWarningFg,
    required this.statusWarningBg,
    required this.statusWarningBorder,
    required this.statusDangerFg,
    required this.statusDangerBg,
    required this.statusDangerBorder,
    required this.statusInfoFg,
    required this.statusInfoBg,
    required this.statusInfoBorder,
    required this.statusNeutralFg,
    required this.statusNeutralBg,
    required this.statusNeutralBorder,
  });

  final Color fgDefault;
  final Color fgHeading;
  final Color fgSection;
  final Color fgMuted;
  final Color fgSecondary;
  final Color fgSubtle;
  final Color fgQuiet;
  final Color fgPlaceholder;
  final Color fgInverse;
  final Color bgCanvas;
  final Color bgSheet;
  final Color bgSurface;
  final Color bgSubtle;
  final Color bgRaised;
  final Color bgTrack;
  final Color bgKpi;

  /// Preenchimento dos campos de formulário (`AppFieldCapsule`), theme-aware.
  /// `fieldOnSurface` quando o campo está sobre `bgSurface` (folha branca do
  /// cadastro); `fieldOnCanvas`, sobre `bgCanvas`/`bgSheet`. Substituem os
  /// literais `AppColors.neutral100`/`neutral0` que `appInputColors()` usava
  /// antes — fixos, não sobreviviam ao gbMode e deixavam o campo branco puro
  /// sobre o tema escuro.
  final Color fieldOnSurface;
  final Color fieldOnCanvas;

  final Color borderDefault;
  final Color borderStrong;
  final Color borderSubtle;
  final Color borderTint;
  final Color accentDefault;
  final Color accentHover;
  final Color accentSubtle;
  final Color accentContrast;
  final Color inkBg;
  final Color inkFg;
  final Color inkMuted;
  final Color inkSubtle;
  final Color inkBubble;
  final Color inkLine;

  /// Cartão-herói do padrão global (Figma 54300:16089): gradiente diagonal
  /// `heroFrom → heroTo` no ângulo `AppComponentMetrics.heroAngle`, com texto e
  /// caixas de ícone translúcidas por cima. Distinto de `ink*`, que é superfície
  /// escura chapada — o herói é sempre gradiente.
  final Color heroFrom;
  final Color heroTo;
  final Color heroFg;
  final Color heroFgMuted;
  final Color heroFgSubtle;
  final Color heroOverlay;
  final Color heroLine;
  final Color ctaBg;
  final Color ctaHover;
  final Color ctaFg;
  final Color navBg;
  final Color navFg;
  final Color navActive;
  final Color navBorder;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowCardHover;
  final List<BoxShadow> shadowModal;

  /// Paleta categórica de gráfico do tema — o índice da série escolhe a cor.
  /// Substitui a leitura direta de `AppColors.chartSeries`, que é fixa e não
  /// sobrevive ao gbMode.
  final List<Color> chartSeries;
  final Color chartGrid;
  final Color chartAxis;
  final Color chartTrack;
  final Color chartPositive;
  final Color chartNegative;

  /// Pares de status theme-aware (texto · fundo suave · borda) para chips,
  /// tags, banners, erro de formulário e tons de KPI. Cada `*Fg` tem ≥ 4,5:1
  /// sobre o seu `*Bg` e sobre `bgSurface` do mesmo tema.
  final Color statusSuccessFg;
  final Color statusSuccessBg;
  final Color statusSuccessBorder;
  final Color statusWarningFg;
  final Color statusWarningBg;
  final Color statusWarningBorder;
  final Color statusDangerFg;
  final Color statusDangerBg;
  final Color statusDangerBorder;
  final Color statusInfoFg;
  final Color statusInfoBg;
  final Color statusInfoBorder;
  final Color statusNeutralFg;
  final Color statusNeutralBg;
  final Color statusNeutralBorder;

  static const light = AppSemanticColors(
    fgDefault: AppColorsLight.fgDefault,
    fgHeading: AppColorsLight.fgHeading,
    fgSection: AppColorsLight.fgSection,
    fgMuted: AppColorsLight.fgMuted,
    fgSecondary: AppColorsLight.fgSecondary,
    fgSubtle: AppColorsLight.fgSubtle,
    fgQuiet: AppColorsLight.fgQuiet,
    fgPlaceholder: AppColorsLight.fgPlaceholder,
    fgInverse: AppColorsLight.fgInverse,
    bgCanvas: AppColorsLight.bgCanvas,
    bgSheet: AppColorsLight.bgSheet,
    bgSurface: AppColorsLight.bgSurface,
    bgSubtle: AppColorsLight.bgSubtle,
    bgRaised: AppColorsLight.bgRaised,
    bgTrack: AppColorsLight.bgTrack,
    bgKpi: AppColorsLight.bgKpi,
    fieldOnSurface: AppColorsLight.fieldOnSurface,
    fieldOnCanvas: AppColorsLight.fieldOnCanvas,
    borderDefault: AppColorsLight.borderDefault,
    borderStrong: AppColorsLight.borderStrong,
    borderSubtle: AppColorsLight.borderSubtle,
    borderTint: AppColorsLight.borderTint,
    accentDefault: AppColorsLight.accentDefault,
    accentHover: AppColorsLight.accentHover,
    accentSubtle: AppColorsLight.accentSubtle,
    accentContrast: AppColorsLight.accentContrast,
    inkBg: AppColorsLight.inkBg,
    inkFg: AppColorsLight.inkFg,
    inkMuted: AppColorsLight.inkMuted,
    inkSubtle: AppColorsLight.inkSubtle,
    inkBubble: AppColorsLight.inkBubble,
    inkLine: AppColorsLight.inkLine,
    heroFrom: AppColorsLight.heroFrom,
    heroTo: AppColorsLight.heroTo,
    heroFg: AppColorsLight.heroFg,
    heroFgMuted: AppColorsLight.heroFgMuted,
    heroFgSubtle: AppColorsLight.heroFgSubtle,
    heroOverlay: AppColorsLight.heroOverlay,
    heroLine: AppColorsLight.heroLine,
    ctaBg: AppColorsLight.ctaBg,
    ctaHover: AppColorsLight.ctaHover,
    ctaFg: AppColorsLight.ctaFg,
    navBg: AppColorsLight.navBg,
    navFg: AppColorsLight.navFg,
    navActive: AppColorsLight.navActive,
    navBorder: AppColorsLight.navBorder,
    shadowCard: AppShadowsLight.card,
    shadowCardHover: AppShadowsLight.cardHover,
    shadowModal: AppShadowsLight.modal,
    chartSeries: AppColorsLight.chartSeries,
    chartGrid: AppColorsLight.chartGrid,
    chartAxis: AppColorsLight.chartAxis,
    chartTrack: AppColorsLight.chartTrack,
    chartPositive: AppColorsLight.chartPositive,
    chartNegative: AppColorsLight.chartNegative,
    statusSuccessFg: AppColorsLight.statusSuccessFg,
    statusSuccessBg: AppColorsLight.statusSuccessBg,
    statusSuccessBorder: AppColorsLight.statusSuccessBorder,
    statusWarningFg: AppColorsLight.statusWarningFg,
    statusWarningBg: AppColorsLight.statusWarningBg,
    statusWarningBorder: AppColorsLight.statusWarningBorder,
    statusDangerFg: AppColorsLight.statusDangerFg,
    statusDangerBg: AppColorsLight.statusDangerBg,
    statusDangerBorder: AppColorsLight.statusDangerBorder,
    statusInfoFg: AppColorsLight.statusInfoFg,
    statusInfoBg: AppColorsLight.statusInfoBg,
    statusInfoBorder: AppColorsLight.statusInfoBorder,
    statusNeutralFg: AppColorsLight.statusNeutralFg,
    statusNeutralBg: AppColorsLight.statusNeutralBg,
    statusNeutralBorder: AppColorsLight.statusNeutralBorder,
  );

  static const gbMode = AppSemanticColors(
    fgDefault: AppColorsGbMode.fgDefault,
    fgHeading: AppColorsGbMode.fgHeading,
    fgSection: AppColorsGbMode.fgSection,
    fgMuted: AppColorsGbMode.fgMuted,
    fgSecondary: AppColorsGbMode.fgSecondary,
    fgSubtle: AppColorsGbMode.fgSubtle,
    fgQuiet: AppColorsGbMode.fgQuiet,
    fgPlaceholder: AppColorsGbMode.fgPlaceholder,
    fgInverse: AppColorsGbMode.fgInverse,
    bgCanvas: AppColorsGbMode.bgCanvas,
    bgSheet: AppColorsGbMode.bgSheet,
    bgSurface: AppColorsGbMode.bgSurface,
    bgSubtle: AppColorsGbMode.bgSubtle,
    bgRaised: AppColorsGbMode.bgRaised,
    bgTrack: AppColorsGbMode.bgTrack,
    bgKpi: AppColorsGbMode.bgKpi,
    fieldOnSurface: AppColorsGbMode.fieldOnSurface,
    fieldOnCanvas: AppColorsGbMode.fieldOnCanvas,
    borderDefault: AppColorsGbMode.borderDefault,
    borderStrong: AppColorsGbMode.borderStrong,
    borderSubtle: AppColorsGbMode.borderSubtle,
    borderTint: AppColorsGbMode.borderTint,
    accentDefault: AppColorsGbMode.accentDefault,
    accentHover: AppColorsGbMode.accentHover,
    accentSubtle: AppColorsGbMode.accentSubtle,
    accentContrast: AppColorsGbMode.accentContrast,
    inkBg: AppColorsGbMode.inkBg,
    inkFg: AppColorsGbMode.inkFg,
    inkMuted: AppColorsGbMode.inkMuted,
    inkSubtle: AppColorsGbMode.inkSubtle,
    inkBubble: AppColorsGbMode.inkBubble,
    inkLine: AppColorsGbMode.inkLine,
    heroFrom: AppColorsGbMode.heroFrom,
    heroTo: AppColorsGbMode.heroTo,
    heroFg: AppColorsGbMode.heroFg,
    heroFgMuted: AppColorsGbMode.heroFgMuted,
    heroFgSubtle: AppColorsGbMode.heroFgSubtle,
    heroOverlay: AppColorsGbMode.heroOverlay,
    heroLine: AppColorsGbMode.heroLine,
    ctaBg: AppColorsGbMode.ctaBg,
    ctaHover: AppColorsGbMode.ctaHover,
    ctaFg: AppColorsGbMode.ctaFg,
    navBg: AppColorsGbMode.navBg,
    navFg: AppColorsGbMode.navFg,
    navActive: AppColorsGbMode.navActive,
    navBorder: AppColorsGbMode.navBorder,
    shadowCard: AppShadowsGbMode.card,
    shadowCardHover: AppShadowsGbMode.cardHover,
    shadowModal: AppShadowsGbMode.modal,
    chartSeries: AppColorsGbMode.chartSeries,
    chartGrid: AppColorsGbMode.chartGrid,
    chartAxis: AppColorsGbMode.chartAxis,
    chartTrack: AppColorsGbMode.chartTrack,
    chartPositive: AppColorsGbMode.chartPositive,
    chartNegative: AppColorsGbMode.chartNegative,
    statusSuccessFg: AppColorsGbMode.statusSuccessFg,
    statusSuccessBg: AppColorsGbMode.statusSuccessBg,
    statusSuccessBorder: AppColorsGbMode.statusSuccessBorder,
    statusWarningFg: AppColorsGbMode.statusWarningFg,
    statusWarningBg: AppColorsGbMode.statusWarningBg,
    statusWarningBorder: AppColorsGbMode.statusWarningBorder,
    statusDangerFg: AppColorsGbMode.statusDangerFg,
    statusDangerBg: AppColorsGbMode.statusDangerBg,
    statusDangerBorder: AppColorsGbMode.statusDangerBorder,
    statusInfoFg: AppColorsGbMode.statusInfoFg,
    statusInfoBg: AppColorsGbMode.statusInfoBg,
    statusInfoBorder: AppColorsGbMode.statusInfoBorder,
    statusNeutralFg: AppColorsGbMode.statusNeutralFg,
    statusNeutralBg: AppColorsGbMode.statusNeutralBg,
    statusNeutralBorder: AppColorsGbMode.statusNeutralBorder,
  );

  @override
  AppSemanticColors copyWith({
    Color? fgDefault,
    Color? fgHeading,
    Color? fgSection,
    Color? fgMuted,
    Color? fgSecondary,
    Color? fgSubtle,
    Color? fgQuiet,
    Color? fgPlaceholder,
    Color? fgInverse,
    Color? bgCanvas,
    Color? bgSheet,
    Color? bgSurface,
    Color? bgSubtle,
    Color? bgRaised,
    Color? bgTrack,
    Color? bgKpi,
    Color? fieldOnSurface,
    Color? fieldOnCanvas,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderSubtle,
    Color? borderTint,
    Color? accentDefault,
    Color? accentHover,
    Color? accentSubtle,
    Color? accentContrast,
    Color? inkBg,
    Color? inkFg,
    Color? inkMuted,
    Color? inkSubtle,
    Color? inkBubble,
    Color? inkLine,
    Color? heroFrom,
    Color? heroTo,
    Color? heroFg,
    Color? heroFgMuted,
    Color? heroFgSubtle,
    Color? heroOverlay,
    Color? heroLine,
    Color? ctaBg,
    Color? ctaHover,
    Color? ctaFg,
    Color? navBg,
    Color? navFg,
    Color? navActive,
    Color? navBorder,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowCardHover,
    List<BoxShadow>? shadowModal,
    List<Color>? chartSeries,
    Color? chartGrid,
    Color? chartAxis,
    Color? chartTrack,
    Color? chartPositive,
    Color? chartNegative,
    Color? statusSuccessFg,
    Color? statusSuccessBg,
    Color? statusSuccessBorder,
    Color? statusWarningFg,
    Color? statusWarningBg,
    Color? statusWarningBorder,
    Color? statusDangerFg,
    Color? statusDangerBg,
    Color? statusDangerBorder,
    Color? statusInfoFg,
    Color? statusInfoBg,
    Color? statusInfoBorder,
    Color? statusNeutralFg,
    Color? statusNeutralBg,
    Color? statusNeutralBorder,
  }) {
    return AppSemanticColors(
      fgDefault: fgDefault ?? this.fgDefault,
      fgHeading: fgHeading ?? this.fgHeading,
      fgSection: fgSection ?? this.fgSection,
      fgMuted: fgMuted ?? this.fgMuted,
      fgSecondary: fgSecondary ?? this.fgSecondary,
      fgSubtle: fgSubtle ?? this.fgSubtle,
      fgQuiet: fgQuiet ?? this.fgQuiet,
      fgPlaceholder: fgPlaceholder ?? this.fgPlaceholder,
      fgInverse: fgInverse ?? this.fgInverse,
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSheet: bgSheet ?? this.bgSheet,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      bgRaised: bgRaised ?? this.bgRaised,
      bgTrack: bgTrack ?? this.bgTrack,
      bgKpi: bgKpi ?? this.bgKpi,
      fieldOnSurface: fieldOnSurface ?? this.fieldOnSurface,
      fieldOnCanvas: fieldOnCanvas ?? this.fieldOnCanvas,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderTint: borderTint ?? this.borderTint,
      accentDefault: accentDefault ?? this.accentDefault,
      accentHover: accentHover ?? this.accentHover,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      accentContrast: accentContrast ?? this.accentContrast,
      inkBg: inkBg ?? this.inkBg,
      inkFg: inkFg ?? this.inkFg,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      inkBubble: inkBubble ?? this.inkBubble,
      inkLine: inkLine ?? this.inkLine,
      heroFrom: heroFrom ?? this.heroFrom,
      heroTo: heroTo ?? this.heroTo,
      heroFg: heroFg ?? this.heroFg,
      heroFgMuted: heroFgMuted ?? this.heroFgMuted,
      heroFgSubtle: heroFgSubtle ?? this.heroFgSubtle,
      heroOverlay: heroOverlay ?? this.heroOverlay,
      heroLine: heroLine ?? this.heroLine,
      ctaBg: ctaBg ?? this.ctaBg,
      ctaHover: ctaHover ?? this.ctaHover,
      ctaFg: ctaFg ?? this.ctaFg,
      navBg: navBg ?? this.navBg,
      navFg: navFg ?? this.navFg,
      navActive: navActive ?? this.navActive,
      navBorder: navBorder ?? this.navBorder,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowCardHover: shadowCardHover ?? this.shadowCardHover,
      shadowModal: shadowModal ?? this.shadowModal,
      chartSeries: chartSeries ?? this.chartSeries,
      chartGrid: chartGrid ?? this.chartGrid,
      chartAxis: chartAxis ?? this.chartAxis,
      chartTrack: chartTrack ?? this.chartTrack,
      chartPositive: chartPositive ?? this.chartPositive,
      chartNegative: chartNegative ?? this.chartNegative,
      statusSuccessFg: statusSuccessFg ?? this.statusSuccessFg,
      statusSuccessBg: statusSuccessBg ?? this.statusSuccessBg,
      statusSuccessBorder: statusSuccessBorder ?? this.statusSuccessBorder,
      statusWarningFg: statusWarningFg ?? this.statusWarningFg,
      statusWarningBg: statusWarningBg ?? this.statusWarningBg,
      statusWarningBorder: statusWarningBorder ?? this.statusWarningBorder,
      statusDangerFg: statusDangerFg ?? this.statusDangerFg,
      statusDangerBg: statusDangerBg ?? this.statusDangerBg,
      statusDangerBorder: statusDangerBorder ?? this.statusDangerBorder,
      statusInfoFg: statusInfoFg ?? this.statusInfoFg,
      statusInfoBg: statusInfoBg ?? this.statusInfoBg,
      statusInfoBorder: statusInfoBorder ?? this.statusInfoBorder,
      statusNeutralFg: statusNeutralFg ?? this.statusNeutralFg,
      statusNeutralBg: statusNeutralBg ?? this.statusNeutralBg,
      statusNeutralBorder: statusNeutralBorder ?? this.statusNeutralBorder,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      fgDefault: c(fgDefault, other.fgDefault),
      fgHeading: c(fgHeading, other.fgHeading),
      fgSection: c(fgSection, other.fgSection),
      fgMuted: c(fgMuted, other.fgMuted),
      fgSecondary: c(fgSecondary, other.fgSecondary),
      fgSubtle: c(fgSubtle, other.fgSubtle),
      fgQuiet: c(fgQuiet, other.fgQuiet),
      fgPlaceholder: c(fgPlaceholder, other.fgPlaceholder),
      fgInverse: c(fgInverse, other.fgInverse),
      bgCanvas: c(bgCanvas, other.bgCanvas),
      bgSheet: c(bgSheet, other.bgSheet),
      bgSurface: c(bgSurface, other.bgSurface),
      bgSubtle: c(bgSubtle, other.bgSubtle),
      bgRaised: c(bgRaised, other.bgRaised),
      bgTrack: c(bgTrack, other.bgTrack),
      bgKpi: c(bgKpi, other.bgKpi),
      fieldOnSurface: c(fieldOnSurface, other.fieldOnSurface),
      fieldOnCanvas: c(fieldOnCanvas, other.fieldOnCanvas),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderTint: c(borderTint, other.borderTint),
      accentDefault: c(accentDefault, other.accentDefault),
      accentHover: c(accentHover, other.accentHover),
      accentSubtle: c(accentSubtle, other.accentSubtle),
      accentContrast: c(accentContrast, other.accentContrast),
      inkBg: c(inkBg, other.inkBg),
      inkFg: c(inkFg, other.inkFg),
      inkMuted: c(inkMuted, other.inkMuted),
      inkSubtle: c(inkSubtle, other.inkSubtle),
      inkBubble: c(inkBubble, other.inkBubble),
      inkLine: c(inkLine, other.inkLine),
      heroFrom: c(heroFrom, other.heroFrom),
      heroTo: c(heroTo, other.heroTo),
      heroFg: c(heroFg, other.heroFg),
      heroFgMuted: c(heroFgMuted, other.heroFgMuted),
      heroFgSubtle: c(heroFgSubtle, other.heroFgSubtle),
      heroOverlay: c(heroOverlay, other.heroOverlay),
      heroLine: c(heroLine, other.heroLine),
      ctaBg: c(ctaBg, other.ctaBg),
      ctaHover: c(ctaHover, other.ctaHover),
      ctaFg: c(ctaFg, other.ctaFg),
      navBg: c(navBg, other.navBg),
      navFg: c(navFg, other.navFg),
      navActive: c(navActive, other.navActive),
      navBorder: c(navBorder, other.navBorder),
      // Sombras não interpolam bem elemento-a-elemento; troca discreta no ponto médio.
      shadowCard: t < 0.5 ? shadowCard : other.shadowCard,
      shadowCardHover: t < 0.5 ? shadowCardHover : other.shadowCardHover,
      shadowModal: t < 0.5 ? shadowModal : other.shadowModal,
      // A série é uma lista ordenada de tamanho fixo: interpola par a par para
      // a troca de tema não piscar a cor de nenhuma categoria.
      chartSeries: [
        for (var i = 0; i < chartSeries.length; i++)
          i < other.chartSeries.length
              ? c(chartSeries[i], other.chartSeries[i])
              : chartSeries[i],
      ],
      chartGrid: c(chartGrid, other.chartGrid),
      chartAxis: c(chartAxis, other.chartAxis),
      chartTrack: c(chartTrack, other.chartTrack),
      chartPositive: c(chartPositive, other.chartPositive),
      chartNegative: c(chartNegative, other.chartNegative),
      statusSuccessFg: c(statusSuccessFg, other.statusSuccessFg),
      statusSuccessBg: c(statusSuccessBg, other.statusSuccessBg),
      statusSuccessBorder: c(statusSuccessBorder, other.statusSuccessBorder),
      statusWarningFg: c(statusWarningFg, other.statusWarningFg),
      statusWarningBg: c(statusWarningBg, other.statusWarningBg),
      statusWarningBorder: c(statusWarningBorder, other.statusWarningBorder),
      statusDangerFg: c(statusDangerFg, other.statusDangerFg),
      statusDangerBg: c(statusDangerBg, other.statusDangerBg),
      statusDangerBorder: c(statusDangerBorder, other.statusDangerBorder),
      statusInfoFg: c(statusInfoFg, other.statusInfoFg),
      statusInfoBg: c(statusInfoBg, other.statusInfoBg),
      statusInfoBorder: c(statusInfoBorder, other.statusInfoBorder),
      statusNeutralFg: c(statusNeutralFg, other.statusNeutralFg),
      statusNeutralBg: c(statusNeutralBg, other.statusNeutralBg),
      statusNeutralBorder: c(statusNeutralBorder, other.statusNeutralBorder),
    );
  }
}
