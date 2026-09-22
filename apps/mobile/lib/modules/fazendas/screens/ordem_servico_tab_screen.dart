import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../ordem_servico/screens/ordem_servico_painel.dart';

/// Raiz da aba "OS" da Administração — lista direto as demandas da fazenda
/// ativa (`OrdemServicoPainel`), sem a camada intermediária de tiles que
/// [ResponsibilityWorkspace] usa para as demais abas. Mesmo padrão de raiz de
/// aba das outras (sem `AppFarmSelector`/busca locais — o shell já resolve
/// isso globalmente — e sem seta de voltar, diferente do dashboard
/// alcançado pela busca global, `DashOrdemServico`).
class OrdemServicoTabScreen extends StatelessWidget {
  const OrdemServicoTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: const [
        AppSectionTitle(child: Text('OS')),
        SizedBox(height: AppSpacing.space2),
        OrdemServicoPainel(),
      ],
    );
  }
}
