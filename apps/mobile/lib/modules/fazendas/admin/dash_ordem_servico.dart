import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../ordem_servico/screens/ordem_servico_painel.dart';
import '../ordem_servico/screens/os_create_page.dart';
import 'dashboard_screen.dart';

/// Ordem de Serviço (Administrativo) — primeiro ladrilho da aba Consultas,
/// também alcançada pela busca global (`consulta-os`, `existingRoute`). O
/// [OrdemServicoPainel] fica dentro de um [DashboardScreen] com voltar, e o
/// "+ Nova O.S" vai fixo no rodapé, largura total — mais fácil de alcançar
/// com o polegar do que um glifo pequeno na faixa do topo, e o mesmo padrão
/// de CTA fixo já usado nos fluxos de formulário do app.
class DashOrdemServico extends StatelessWidget {
  const DashOrdemServico({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(
      title: 'Ordem de Serviço',
      bottomBar: AppActionBar(
        primaryLabel: '+ Nova O.S',
        onPrimary: () => abrirCriarOs(context),
      ),
      child: const OrdemServicoPainel(),
    );
  }
}
