import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import 'button.dart';

/// Abre a [AppSplashScreen] por cima de tudo e devolve quando ela termina
/// (ou a pessoa toca para pular). Quem chama decide o que vem depois — no
/// login, é abrir a sessão e ir para o Início.
Future<void> showAppSplash(BuildContext context, {String? tagline}) {
  final done = Completer<void>();
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, _, _) => AppSplashScreen(
        tagline: tagline ?? AppSplashScreen.defaultTagline,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      ),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
  return done.future;
}

/// Splash pós-login, espelho da `SplashScreen` do CERNE desktop: sobre o
/// verde profundo, a pilha de gomos do "C" em abertura dá a volta largando
/// um gomo por parada, o C encolhe até a posição final, e o nome entra com o
/// espaçamento fechando — cercado por três anéis orbitais com partículas.
///
/// Versão de campo: dura ~3,8 s (o desktop leva 4,8), toque em qualquer
/// lugar pula e "remover animações" mostra só o quadro final. Uma única
/// animação dirige tudo — nada repete para sempre.
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({
    super.key,
    required this.onDone,
    this.tagline = defaultTagline,
  });

  static const defaultTagline = 'Operação de campo';

  final VoidCallback onDone;
  final String tagline;

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  /// Linha do tempo total, em segundos — as fases abaixo são frações dela.
  static const double _total = 3.8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slower * (_total / 0.4),
  )..addStatusListener(_onStatus);

  bool _finished = false;
  Timer? _reducedTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.value > 0 || _finished) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      // Sem animação: quadro final parado por um instante e segue.
      _controller.value = _Timeline.reducedMotionFrame / _total;
      _reducedTimer = Timer(AppMotion.slower * 2, _finish);
    } else {
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _reducedTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `Material` transparente: aberta numa rota própria (showAppSplash), a
    // splash não tem Scaffold por baixo e o Flutter sublinhava os textos
    // com o aviso amarelo de "texto sem Material".
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        label: 'Carregando CERNE',
        liveRegion: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => _SplashFrame(
              t: _controller.value * _total,
              tagline: widget.tagline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fases da coreografia (segundos), iguais às do desktop, com a saída
/// antecipada para caber em 3,8 s.
abstract final class _Timeline {
  static const double markFade = 0.35;
  static const double dealDelay = 0.25;
  static const double hopCycle = 0.18;
  static const double hopDuration = 0.13;
  static const double shrinkStart = 1.95;
  static const double shrinkDuration = 0.7;
  static const double nameStart = 2.55;
  static const double nameDuration = 0.55;
  static const double tagStart = 2.95;
  static const double tagDuration = 0.45;
  static const double outStart = 3.5;
  static const double outDuration = 0.3;

  /// Quadro mostrado com "remover animações": tudo montado, antes da saída.
  static const double reducedMotionFrame = 3.45;
}

double _progress(double t, double start, double duration, [Curve? curve]) {
  final raw = ((t - start) / duration).clamp(0.0, 1.0);
  return (curve ?? AppMotion.easingOut).transform(raw);
}

class _SplashFrame extends StatelessWidget {
  const _SplashFrame({required this.t, required this.tagline});

  final double t;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final fadeIn = _progress(t, 0, _Timeline.markFade);
    final fadeOut = 1 - _progress(t, _Timeline.outStart, _Timeline.outDuration);
    final shrink = _progress(
      t,
      _Timeline.shrinkStart,
      _Timeline.shrinkDuration,
      AppMotion.easingOut,
    );
    final name = _progress(t, _Timeline.nameStart, _Timeline.nameDuration);
    final tag = _progress(t, _Timeline.tagStart, _Timeline.tagDuration);

    // O C nasce 3,3× maior e deslocado para baixo, e encolhe até o lugar.
    final markScale = 3.3 - 2.3 * shrink;
    final markOffset = 62 * (1 - shrink);

    final nameSize = AppTypography.xl4 * 1.25;

    return Opacity(
      opacity: fadeOut.clamp(0.0, 1.0),
      child: ColoredBox(
        color: AppComponentColors.splashBg,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Brilho ambiental.
            IgnorePointer(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brand600.withValues(alpha: 0.18),
                      AppColors.brand600.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            for (final ring in _rings) _OrbitRing(ring: ring, t: t),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: fadeIn,
                  child: Transform.translate(
                    offset: Offset(0, markOffset),
                    child: Transform.scale(
                      scale: markScale,
                      child: CustomPaint(
                        size: const Size.square(AppComponentMetrics.splashMark),
                        painter: _MarkPainter(t: t),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space7),
                Opacity(
                  opacity: name,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - name)),
                    child: Transform.scale(
                      scale: 0.96 + 0.04 * name,
                      child: Text(
                        'CERNE',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: nameSize,
                          fontWeight: AppTypography.weightExtrabold,
                          height: 1,
                          color: AppColors.neutral0,
                          // Fecha de 0,35em para 0,22em enquanto entra.
                          letterSpacing: nameSize * (0.35 - 0.13 * name),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.twoHalf),
                Opacity(
                  opacity: tag,
                  child: Transform.translate(
                    offset: Offset(0, AppSpacing.space2 * (1 - tag)),
                    child: Text(
                      tagline.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.sm,
                        fontWeight: AppTypography.weightMedium,
                        color: AppColors.brand400,
                        letterSpacing: AppTypography.sm * 0.14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Anel orbital: contorno fino na cor da marca girando no próprio ritmo, com
/// duas partículas que brilham. Direções alternadas dão o efeito de anéis
/// de Saturno.
class _Ring {
  const _Ring({
    required this.size,
    required this.border,
    required this.period,
    required this.clockwise,
    required this.dots,
  });

  final double size;
  final double border;
  final double period;
  final bool clockwise;
  final List<({double angle, double size, Color color, double glow})> dots;
}

const _rings = <_Ring>[
  _Ring(
    size: 440,
    border: 0.08,
    period: 22,
    clockwise: true,
    dots: [
      (angle: 28, size: 5, color: AppColors.brand400, glow: 7),
      (angle: 168, size: 3, color: AppColors.brand300, glow: 5),
    ],
  ),
  _Ring(
    size: 320,
    border: 0.14,
    period: 15,
    clockwise: false,
    dots: [
      (angle: 72, size: 6, color: AppColors.brand400, glow: 9),
      (angle: 244, size: 4, color: AppColors.brand500, glow: 6),
    ],
  ),
  _Ring(
    size: 220,
    border: 0.1,
    period: 9,
    clockwise: true,
    dots: [
      (angle: 115, size: 5, color: AppColors.brand300, glow: 8),
      (angle: 300, size: 3, color: AppColors.brand400, glow: 5),
    ],
  ),
];

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.ring, required this.t});

  final _Ring ring;
  final double t;

  @override
  Widget build(BuildContext context) {
    final turns = (t / ring.period) * (ring.clockwise ? 1 : -1);
    return IgnorePointer(
      child: Transform.rotate(
        angle: turns * 2 * math.pi,
        child: SizedBox.square(
          dimension: ring.size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand600.withValues(alpha: ring.border),
                    ),
                  ),
                ),
              ),
              for (final dot in ring.dots)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: dot.angle * math.pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: Offset(0, -dot.size / 2),
                        child: CustomPaint(
                          size: Size.square(dot.size),
                          painter: _DotPainter(
                            color: dot.color,
                            glow: dot.glow,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Partícula do anel: ponto sólido com halo desfocado da mesma cor.
class _DotPainter extends CustomPainter {
  const _DotPainter({required this.color, required this.glow});

  final Color color;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, glow / 2),
      )
      ..drawCircle(center, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glow != glow;
}

/// O "C" em abertura da marca (mesma geometria de `logo-min-white.svg`):
/// 10 gomos entre os raios 46 e 92 de um viewBox 240, com a boca virada para
/// a direita, na rampa brand 300→500. Durante a distribuição, o gomo i ainda
/// está `(9 − i) − s` slots adiante, onde `s` é quanto a pilha já andou.
class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.t});

  final double t;

  static const double _slot = 29.2; // (360 − boca) / 10 gomos
  static const double _outerStart = 37.43;
  static const double _outerSweep = 22.34;
  static const double _innerStart = 40.87;
  static const double _innerSweep = 15.46;

  static double _rad(double deg) => deg * math.pi / 180;

  /// Slots que a pilha já percorreu (0 → 9), com a parada entre saltos.
  double get _travelled {
    final dealT = t - _Timeline.dealDelay;
    if (dealT <= 0) return 0;
    final hop = (dealT / _Timeline.hopCycle).floor();
    if (hop >= 9) return 9;
    final within = ((dealT - hop * _Timeline.hopCycle) / _Timeline.hopDuration)
        .clamp(0.0, 1.0);
    return hop + AppMotion.easingOut.transform(within);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 240);
    const center = Offset(120, 120);
    final outer = Rect.fromCircle(center: center, radius: 92);
    final inner = Rect.fromCircle(center: center, radius: 46);
    final travelled = _travelled;

    for (var i = 0; i < 10; i++) {
      final color = Color.lerp(AppColors.brand300, AppColors.brand500, i / 9)!;
      final remaining = math.max(0.0, (9 - i) - travelled);
      final base = i * _slot + remaining * _slot;

      final a0 = _rad(_outerStart + base);
      final b0 = _rad(_innerStart + base);
      final path = Path()
        ..arcTo(outer, a0, _rad(_outerSweep), true)
        ..arcTo(inner, b0 + _rad(_innerSweep), -_rad(_innerSweep), false)
        ..close();

      canvas
        ..drawPath(path, Paint()..color = color)
        ..drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..strokeJoin = StrokeJoin.round,
        );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.t != t;
}

WidgetbookComponent buildSplashScreenWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SplashScreen',
    useCases: [
      WidgetbookUseCase(
        name: 'Pós-login',
        builder: (context) => const _SplashReplay(),
      ),
    ],
  );
}

/// Caso do Widgetbook: toca a abertura e oferece repetir no fim.
class _SplashReplay extends StatefulWidget {
  const _SplashReplay();

  @override
  State<_SplashReplay> createState() => _SplashReplayState();
}

class _SplashReplayState extends State<_SplashReplay> {
  int _run = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 760,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppSplashScreen(
              key: ValueKey(_run),
              onDone: () => setState(() => _done = true),
            ),
          ),
          if (_done)
            Positioned(
              left: AppSpacing.space6,
              right: AppSpacing.space6,
              bottom: AppSpacing.space8,
              child: AppButton(
                variant: AppButtonVariant.outline,
                onPressed: () => setState(() {
                  _done = false;
                  _run++;
                }),
                child: const Text('Repetir'),
              ),
            ),
        ],
      ),
    );
  }
}
