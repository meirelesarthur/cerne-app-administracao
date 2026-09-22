import 'package:flutter/material.dart';

import '../design/generated/app_motion.dart';

/// Espelha a animação `animate-rise` (CSS) usada em quase toda tela de módulo do
/// protótipo — fade + leve subida de baixo para cima, com atraso escalonado por
/// seção (`stagger(i) = i * t.animation.stagger`). Respeita
/// `MediaQuery.disableAnimations`.
class RiseIn extends StatefulWidget {
  const RiseIn({super.key, this.index = 0, required this.child});

  /// Índice da seção na tela — usado para escalonar o atraso de entrada.
  final int index;
  final Widget child;

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.base);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
      return;
    }
    Future.delayed(AppMotion.stagger * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easingOut,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
