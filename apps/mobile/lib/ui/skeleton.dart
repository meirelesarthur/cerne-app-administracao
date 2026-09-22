import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Skeleton.tsx` — placeholder de carregamento com efeito "pulse".
/// O React usa `animate-pulse` (Tailwind, ciclo de ~2s); aqui replicamos com
/// um `AnimationController` nativo (pacote `shimmer` não está instalado),
/// usando `AppMotion.slower` (400ms) multiplicado por 3 para aproximar o
/// ciclo, já que não há token de duração de ~1.2s no design system.
enum AppSkeletonRadius { md, lg, xl, xl2, full }

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.rounded = AppSkeletonRadius.lg,
  });

  final double? width;
  final double? height;
  final AppSkeletonRadius rounded;

  double get _radius => switch (rounded) {
    AppSkeletonRadius.md => AppRadius.md,
    AppSkeletonRadius.lg => AppRadius.lg,
    AppSkeletonRadius.xl => AppRadius.xl,
    AppSkeletonRadius.xl2 => AppRadius.xl2,
    AppSkeletonRadius.full => AppRadius.full,
  };

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.slower * 3,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 1,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: semantic.borderStrong,
            borderRadius: BorderRadius.circular(widget._radius),
          ),
        ),
      ),
    );
  }
}

/// Skeleton pré-montado no formato de um card do padrão global: mesma
/// superfície, mesmo raio [AppRadius.tile] e mesma sombra `AppShadows.tile` do
/// card que ele substitui enquanto os dados chegam — se o esqueleto tivesse
/// geometria própria, a tela saltaria ao trocar de estado.
///
/// Os respiros são distribuídos com `spaceBetween` em vez de `SizedBox` fixo:
/// o esqueleto entra em células de grade com proporção fixa, e uma altura
/// intrínseca somada estourava a célula por alguns pixels.
class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: semantic.bgRaised,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        boxShadow: AppShadows.tile,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppSkeleton(width: AppSpacing.space8, height: AppSpacing.space8),
          FractionallySizedBox(
            widthFactor: 2 / 3,
            child: AppSkeleton(height: AppSpacing.space3),
          ),
          FractionallySizedBox(
            widthFactor: 1 / 2,
            child: AppSkeleton(height: AppSpacing.space6),
          ),
          AppSkeleton(height: AppSpacing.space8),
        ],
      ),
    );
  }
}

WidgetbookComponent buildSkeletonWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Skeleton',
    useCases: [
      WidgetbookUseCase(
        name: 'Formas',
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 200, height: 16),
              SizedBox(height: AppSpacing.space2),
              AppSkeleton(
                width: 120,
                height: 16,
                rounded: AppSkeletonRadius.full,
              ),
              SizedBox(height: AppSpacing.space2),
              AppSkeleton(
                width: 48,
                height: 48,
                rounded: AppSkeletonRadius.xl2,
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'CardSkeleton',
        builder: (context) =>
            const Center(child: SizedBox(width: 260, child: AppCardSkeleton())),
      ),
    ],
  );
}
