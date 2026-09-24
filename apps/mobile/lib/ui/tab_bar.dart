import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'hexagon.dart';
import 'pressable.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um destino selecionável da [AppTabBar].
class AppTabBarItem {
  const AppTabBarItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final AppIconData icon;
}

/// Navbar só de ícones com o item ativo **flutuando**: o ícone sobe numa
/// caixa hexagonal verde ([AppHexagon]), a barra ganha uma ondulação sob ele
/// e o nome aparece embaixo, na cor de destaque.
///
/// Ao trocar de aba, um único hexágono desliza até a nova posição girando —
/// hexágono "rolando" — e a ondulação vai junto; os ícones por onde ele
/// passa sobem e descem no caminho. Com animações reduzidas no sistema a
/// troca é imediata.
///
/// `activeId` que não bate com nenhum destino recolhe o destaque: a ondulação
/// se fecha e o hexágono afunda.
///
/// Não se posiciona sozinha: quem usa a coloca na base da tela (a altura
/// total inclui os [AppComponentMetrics.tabbarLift] px que o hexágono sobe).
class AppTabBar extends StatefulWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.activeId,
    required this.onSelected,
  });

  final List<AppTabBarItem> items;
  final String activeId;
  final ValueChanged<AppTabBarItem> onSelected;

  /// Altura total: barra + o que o hexágono ativo sobe acima dela.
  static const double totalHeight =
      AppComponentMetrics.tabbarLift + AppComponentMetrics.tabbarHeight;

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  /// Última aba ativa: quando o destaque recolhe, ele afunda onde estava em
  /// vez de voltar para a primeira aba.
  int _lastIndex = 0;

  int get _activeIndex =>
      widget.items.indexWhere((item) => item.id == widget.activeId);

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex;
    if (active >= 0) _lastIndex = active;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = reduceMotion ? Duration.zero : AppMotion.slow;

    return Semantics(
      container: true,
      label: 'Navegação principal',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          // Só filhos posicionados: sem tamanho explícito a Stack encolheria
          // a zero dentro de um `Center`.
          return SizedBox(
            width: width,
            height: AppTabBar.totalHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: active >= 0 ? 1 : 0),
              duration: duration,
              curve: AppMotion.easingOut,
              builder: (context, presence, _) => TweenAnimationBuilder<double>(
                tween: Tween(end: _lastIndex.toDouble()),
                duration: duration,
                curve: AppMotion.easingInOut,
                builder: (context, position, _) => _TabBarFrame(
                  items: widget.items,
                  width: width,
                  position: position,
                  presence: presence,
                  activeIndex: active,
                  reduceMotion: reduceMotion,
                  onSelected: widget.onSelected,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Um quadro da navbar: tudo é função de `position` (índice fracionário por
/// onde o hexágono passa) e `presence` (0 recolhido, 1 à mostra).
class _TabBarFrame extends StatelessWidget {
  const _TabBarFrame({
    required this.items,
    required this.width,
    required this.position,
    required this.presence,
    required this.activeIndex,
    required this.reduceMotion,
    required this.onSelected,
  });

  final List<AppTabBarItem> items;
  final double width;
  final double position;
  final double presence;
  final int activeIndex;
  final bool reduceMotion;
  final ValueChanged<AppTabBarItem> onSelected;

  static const _barTop = AppComponentMetrics.tabbarLift;
  static const _barHeight = AppComponentMetrics.tabbarHeight;
  static const _hex = AppComponentMetrics.tabbarHexSize;
  static const _padding = AppSpacing.space2;

  /// Centro vertical do ícone em repouso (meio da barra) e flutuando (o
  /// hexágono encosta no topo do componente).
  static const _restY = _barTop + _barHeight / 2;
  static const _liftY = _hex / 2;

  /// O nome fica no fundo da barra, abaixo da ondulação.
  static const _labelY =
      _barTop +
      AppComponentMetrics.tabbarNotchDepth +
      (_barHeight - AppComponentMetrics.tabbarNotchDepth) / 2;

  double get _slot => (width - _padding * 2) / items.length;
  double _centerX(double index) => _padding + _slot * (index + 0.5);

  /// Quanto o item `i` está "ativo" neste quadro: 1 com o hexágono em cima
  /// dele, caindo a 0 a uma posição de distância.
  double _activation(int i) =>
      presence * (1 - (position - i).abs()).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final hexX = _centerX(position);
    final hexY = lerpDouble(_restY, _liftY, presence)!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _NotchedBarPainter(
              notchX: hexX,
              depth: AppComponentMetrics.tabbarNotchDepth * presence,
              color: semantic.navBg,
              borderColor: semantic.navBorder,
              shadows: semantic.shadowModal,
            ),
          ),
        ),
        // Hexágono ativo: um só, que desliza e gira uma volta completa por
        // aba percorrida — a 60° (um sexto de volta) a forma cai de novo
        // num ângulo simétrico do hexágono e o giro fica invisível; a volta
        // inteira é o que faz ler como uma roda rolando de verdade, e ainda
        // assim chega de pé (0° ≡ 360°) em cada posição.
        if (presence > 0)
          Positioned(
            left: hexX - _hex / 2,
            top: hexY - _hex / 2,
            child: Opacity(
              opacity: presence,
              child: Transform.scale(
                scale: lerpDouble(0.6, 1, presence)!,
                child: AppHexagon(
                  color: semantic.ctaBg,
                  shadows: semantic.shadowModal,
                  rotation: reduceMotion ? 0 : position * 2 * math.pi,
                ),
              ),
            ),
          ),
        for (var i = 0; i < items.length; i++) ...[
          _icon(semantic, items[i], i),
          _label(semantic, items[i], i),
          _hitArea(items[i], i),
        ],
      ],
    );
  }

  Widget _icon(AppSemanticColors semantic, AppTabBarItem item, int i) {
    final a = _activation(i);
    // Maior parado (era iconMd/20) e cresce mais um tanto sobre o hexágono
    // ativo, em vez do zoom sutil de 8% de antes.
    final size = lerpDouble(AppSize.iconLg, AppSize.iconXl, a)!;
    return Positioned(
      left: _centerX(i.toDouble()) - size / 2,
      top: lerpDouble(_restY, _liftY, a)! - size / 2,
      child: IgnorePointer(
        child: AppIcon(
          item.icon,
          size: size,
          color: Color.lerp(semantic.navFg, semantic.ctaFg, a),
        ),
      ),
    );
  }

  Widget _label(AppSemanticColors semantic, AppTabBarItem item, int i) {
    // Só aparece na chegada: de passagem o nome não pisca.
    final opacity = ((_activation(i) - 0.5) * 2).clamp(0.0, 1.0);
    if (opacity == 0) return const SizedBox.shrink();
    return Positioned(
      left: _centerX(i.toDouble()) - _slot / 2,
      width: _slot,
      top: _labelY - AppTypography.sm + (1 - opacity) * AppSpacing.space1,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Text(
            item.label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              height: AppTypography.lineHeightTight,
              color: semantic.accentDefault,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hitArea(AppTabBarItem item, int i) {
    final active = i == activeIndex;
    // Só a aba ativa ocupa a faixa acima da barra (onde está o hexágono); as
    // outras não roubam toques do conteúdo que passa por trás.
    final top = active ? 0.0 : _barTop;
    return Positioned(
      left: _centerX(i.toDouble()) - _slot / 2,
      width: _slot,
      top: top,
      height: AppTabBar.totalHeight - top,
      child: Tooltip(
        message: item.label,
        child: AppPressable(
          semanticLabel: item.label,
          selected: active,
          minTouchTarget: false,
          // O retorno do toque é o hexágono andando; o realce retangular do
          // InkWell brigaria com a ondulação.
          showVisualFeedback: false,
          onPressed: () => onSelected(item),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Barra de cantos arredondados com uma ondulação (vale suave) aberta no
/// topo em `notchX`. A ondulação é subtraída do retângulo, então perto das
/// pontas ela "come" o canto em vez de sair da barra.
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter({
    required this.notchX,
    required this.depth,
    required this.color,
    required this.borderColor,
    required this.shadows,
  });

  final double notchX;
  final double depth;
  final Color color;
  final Color borderColor;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    const top = AppComponentMetrics.tabbarLift;
    final bar = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, top, size.width, AppComponentMetrics.tabbarHeight),
          const Radius.circular(AppRadius.surface),
        ),
      );

    var shape = bar;
    if (depth > 0.5) {
      const half = AppComponentMetrics.tabbarNotchWidth / 2;
      // Tangente horizontal nas bordas e no fundo: a barra "afunda" sem
      // quina, como tecido esticado sob o hexágono.
      final x = notchX;
      final notch = Path()
        ..moveTo(x - half, top - half)
        ..lineTo(x - half, top)
        ..cubicTo(
          x - half * 0.45,
          top,
          x - half * 0.55,
          top + depth,
          x,
          top + depth,
        )
        ..cubicTo(
          x + half * 0.55,
          top + depth,
          x + half * 0.45,
          top,
          x + half,
          top,
        )
        ..lineTo(x + half, top - half)
        ..close();
      shape = Path.combine(PathOperation.difference, bar, notch);
    }

    for (final shadow in shadows) {
      canvas.drawPath(
        shape.shift(shadow.offset),
        Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
      );
    }
    canvas.drawPath(shape, Paint()..color = color);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.notchX != notchX ||
      old.depth != depth ||
      old.color != color ||
      old.borderColor != borderColor ||
      old.shadows != shadows;
}

WidgetbookComponent buildTabBarWidgetbookComponent() {
  const items = [
    AppTabBarItem(id: 'inicio', label: 'Início', icon: AppIcons.home),
    AppTabBarItem(id: 'fazendas', label: 'Fazendas', icon: AppIcons.sprout),
    AppTabBarItem(id: 'bank', label: 'Bank', icon: AppIcons.landmark),
    AppTabBarItem(id: 'menu', label: 'Menu', icon: AppIcons.menu),
  ];

  Widget stage(Widget child) => ColoredBox(
    color: AppColors.neutral100,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppComponentMetrics.tabbarInset),
        child: SizedBox(width: 375, child: child),
      ),
    ),
  );

  return WidgetbookComponent(
    name: 'TabBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo (toque nas abas)',
        builder: (context) {
          var active = 'inicio';
          return stage(
            StatefulBuilder(
              builder: (context, setState) => AppTabBar(
                items: items,
                activeId: active,
                onSelected: (item) => setState(() {
                  active = item.id;
                }),
              ),
            ),
          );
        },
      ),
      for (final item in items)
        WidgetbookUseCase(
          name: 'Ativa: ${item.label}',
          builder: (context) => stage(
            AppTabBar(items: items, activeId: item.id, onSelected: (_) {}),
          ),
        ),
      WidgetbookUseCase(
        name: 'Sem aba ativa',
        builder: (context) =>
            stage(AppTabBar(items: items, activeId: '', onSelected: (_) {})),
      ),
    ],
  );
}
