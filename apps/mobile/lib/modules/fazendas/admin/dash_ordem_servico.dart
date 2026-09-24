import 'package:flutter/material.dart';

import '../ordem_servico/screens/ordem_servico_painel.dart';
import '../ordem_servico/screens/os_create_page.dart';
import 'dashboard_screen.dart';

/// Ordem de Serviço (Administrativo) — primeiro ladrilho da aba Consultas,
/// também alcançada pela busca global (`consulta-os`, `existingRoute`). O
/// [OrdemServicoPainel] fica dentro de um [DashboardScreen] com voltar, e o
/// "+" de criar vai na extrema direita da faixa do topo.
class DashOrdemServico extends StatelessWidget {
  const DashOrdemServico({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(
      title: 'Ordem de Serviço',
      action: OsCriarButton(),
      child: OrdemServicoPainel(),
    );
  }
}
