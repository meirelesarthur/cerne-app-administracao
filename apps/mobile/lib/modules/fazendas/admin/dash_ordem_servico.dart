import 'package:flutter/material.dart';

import '../ordem_servico/screens/ordem_servico_painel.dart';
import 'dashboard_screen.dart';

/// Consulta de Ordem de Serviço (Administrativo) — alcançada pela busca
/// global e pelo catálogo funcional (`consulta-os`, `existingRoute`). Mesmo
/// [OrdemServicoPainel] da aba "OS" (`ordem_servico_tab_screen.dart`), aqui
/// dentro de um [DashboardScreen] com voltar — Lei 2: uma única
/// implementação da lista, só muda a moldura de navegação.
class DashOrdemServico extends StatelessWidget {
  const DashOrdemServico({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(
      title: 'Ordem de Serviço',
      child: OrdemServicoPainel(),
    );
  }
}
