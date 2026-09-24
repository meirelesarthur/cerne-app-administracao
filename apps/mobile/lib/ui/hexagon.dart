import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Contorno de um hexágono de ponta para cima, com cantos arredondados,
/// inscrito em [size]. Fonte única do formato — [AppHexagon] desenha com ele
/// e quem precisar recortar ou medir o mesmo hexágono usa esta função.
Path appHexagonPath(Size size, {double cornerRadius = AppRadius.sm}) {
  final center = size.center(Offset.zero);
  final radius = math.min(size.width, size.height) / 2;
  final points = [
    for (var i = 0; i < 6; i++)
      center + Offset.fromDirection(-math.pi / 2 + i * math.pi / 3, radius),
  ];
  final path = Path();
  for (var i = 0; i < 6; i++) {
    final previous = points[(i + 5) % 6];
    final current = points[i];
    final next = points[(i + 1) % 6];
    final toPrevious = previous - current;
    final toNext = next - current;
    final start = current + toPrevious / toPrevious.distance * cornerRadius;
    final end = current + toNext / toNext.distance * cornerRadius;
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
  }
  return path..close();
}

/// Caixa hexagonal (ponta para cima) com um conteúdo centralizado — o
/// destaque flutuante do item ativo na barra de navegação.
///
/// `color` preenche; `borderColor` contorna (os dois podem coexistir).
/// `shadows` usa as sombras do tema (ex.: [AppSemanticColors.shadowModal]).
/// `rotation` gira só a forma, nunca o conteúdo — o ícone continua de pé
/// enquanto o hexágono "rola".
class AppHexagon extends StatelessWidget {
  const AppHexagon({
    super.key,
    this.size = AppComponentMetrics.tabbarHexSize,
    this.color,
    this.borderColor,
    this.borderWidth = 1.5,
    this.shadows = const [],
    this.rotation = 0,
    this.child,
  });

  final double size;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;

  /// Em radianos.
  final double rotation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _HexagonPainter(
          color: color,
          borderColor: borderColor,
          borderWidth: borderWidth,
          shadows: shadows,
          rotation: rotation,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.shadows,
    required this.rotation,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // O traço fica por dentro da caixa: sem o recuo, metade dele vazaria.
    final inset = borderColor == null ? 0.0 : borderWidth / 2;
    final path = appHexagonPath(
      Size(size.width - inset * 2, size.height - inset * 2),
    ).shift(Offset(inset, inset));
    final rotated = path.transform(
      (Matrix4.identity()
            ..translateByDouble(center.dx, center.dy, 0, 1)
            ..rotateZ(rotation)
            ..translateByDouble(-center.dx, -center.dy, 0, 1))
          .storage,
    );

    for (final shadow in shadows) {
      canvas.drawPath(
        rotated.shift(shadow.offset),
        Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
      );
    }
    if (color case final fill?) {
      canvas.drawPath(rotated, Paint()..color = fill);
    }
    if (borderColor case final stroke?) {
      canvas.drawPath(
        rotated,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeJoin = StrokeJoin.round
          ..color = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_HexagonPainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.shadows != shadows ||
      old.rotation != rotation;
}

WidgetbookComponent buildHexagonWidgetbookComponent() {
  Widget stage(Widget child) => ColoredBox(
    color: AppColors.neutral0,
    child: Center(child: child),
  );

  return WidgetbookComponent(
    name: 'Hexagon',
    useCases: [
      WidgetbookUseCase(
        name: 'Preenchido (item ativo)',
        builder: (context) {
          final semantic = Theme.of(context).extension<AppSemanticColors>()!;
          return stage(
            AppHexagon(
              color: semantic.ctaBg,
              shadows: semantic.shadowModal,
              child: AppIcon(
                AppIcons.pecuaria,
                size: AppSize.iconMd,
                color: semantic.ctaFg,
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Contorno',
        builder: (context) {
          final semantic = Theme.of(context).extension<AppSemanticColors>()!;
          return stage(
            AppHexagon(
              borderColor: semantic.ctaBg,
              child: AppIcon(
                AppIcons.home,
                size: AppSize.iconMd,
                color: semantic.ctaBg,
              ),
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Rotação',
        builder: (context) {
          final semantic = Theme.of(context).extension<AppSemanticColors>()!;
          return stage(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final turn in [0.0, 15.0, 30.0]) ...[
                  AppHexagon(
                    color: semantic.accentSubtle,
                    rotation: turn * math.pi / 180,
                    child: AppIcon(
                      AppIcons.home,
                      size: AppSize.iconMd,
                      color: semantic.accentDefault,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                ],
              ],
            ),
          );
        },
      ),
    ],
  );
}
