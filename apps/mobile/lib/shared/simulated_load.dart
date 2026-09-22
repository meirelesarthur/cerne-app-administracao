import 'package:flutter/material.dart';

/// Espelha `useSimulatedLoad` (`src/lib/useSimulatedLoad.ts`) — simula um carregamento
/// assíncrono para demonstrar skeletons nas telas de dado. Sem rede real; só um atraso
/// curto ao montar. Determinístico (sem `Date.now`), como o protótipo.
class SimulatedLoad extends StatefulWidget {
  const SimulatedLoad({
    super.key,
    this.duration = const Duration(milliseconds: 600),
    required this.builder,
  });

  final Duration duration;

  /// `loading` true até o atraso terminar, depois false pelo resto do ciclo de vida.
  final Widget Function(BuildContext context, bool loading) builder;

  @override
  State<SimulatedLoad> createState() => _SimulatedLoadState();
}

class _SimulatedLoadState extends State<SimulatedLoad> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _loading);
}
