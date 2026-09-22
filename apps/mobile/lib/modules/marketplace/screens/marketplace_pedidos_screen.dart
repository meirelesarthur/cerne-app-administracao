import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../mocks/pedidos.dart';
import 'package:cerne_app/design/generated/app_radius.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

const Map<PedidoStatus, String> _statusLabel = {
  PedidoStatus.entregue: 'Entregue',
  PedidoStatus.emTransporte: 'Em transporte',
  PedidoStatus.processando: 'Processando',
};

const Map<PedidoStatus, AppChipTone> _statusTone = {
  PedidoStatus.entregue: AppChipTone.brand,
  PedidoStatus.emTransporte: AppChipTone.blue,
  PedidoStatus.processando: AppChipTone.amber,
};

const Map<PedidoStatus, AppIconData> _statusIcon = {
  PedidoStatus.entregue: AppIcons.packageCheck,
  PedidoStatus.emTransporte: AppIcons.truck,
  PedidoStatus.processando: AppIcons.clock,
};

/// Lista de pedidos do Marketplace (dados mockados) — item abre detalhe em
/// BottomSheet. Espelha `MarketplacePedidos.tsx`.
class MarketplacePedidosScreen extends StatelessWidget {
  const MarketplacePedidosScreen({super.key});

  void _abrirDetalhe(BuildContext context, Pedido pedido) {
    showAppDetailPage<void>(
      context,
      title: 'Pedido ${pedido.numero}',
      child: _PedidoDetalheBody(pedido: pedido),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubPageHeader(title: 'Pedidos'),
        Expanded(
          child: pedidos.isEmpty
              ? const AppEmptyState(
                  icon: AppIcons.inbox,
                  title: 'Nenhum pedido ainda',
                  description:
                      'Seus pedidos de insumos e máquinas aparecerão aqui assim que você comprar no Marketplace.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  itemCount: pedidos.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(height: AppSpacing.space3),
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    final semantic = Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!;
                    return AppCard(
                      interactive: true,
                      onTap: () => _abrirDetalhe(context, pedido),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Pedido ${pedido.numero}',
                                      style: TextStyle(
                                        fontWeight:
                                            AppTypography.weightSemibold,
                                        color: semantic.fgDefault,
                                      ),
                                    ),
                                    Text(
                                      pedido.data,
                                      style: TextStyle(
                                        fontSize: AppTypography.sm,
                                        color: semantic.fgMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppChip(
                                tone: _statusTone[pedido.status]!,
                                icon: AppIcon(
                                  _statusIcon[pedido.status],
                                  size: AppSize.iconXs,
                                ),
                                child: Text(_statusLabel[pedido.status]!),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            pedido.itens.map((item) => item.nome).join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.md,
                              color: semantic.fgMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            pedido.valor,
                            style: TextStyle(
                              fontSize: AppTypography.xlPlus,
                              fontWeight: AppTypography.weightBold,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PedidoDetalheBody extends StatelessWidget {
  const _PedidoDetalheBody({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Data', style: TextStyle(color: semantic.fgMuted)),
            Text(
              pedido.data,
              style: TextStyle(
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Status', style: TextStyle(color: semantic.fgMuted)),
            AppChip(
              tone: _statusTone[pedido.status]!,
              icon: AppIcon(_statusIcon[pedido.status], size: AppSize.iconXs),
              child: Text(_statusLabel[pedido.status]!),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          decoration: BoxDecoration(
            color: semantic.bgSubtle,
            border: Border.all(color: semantic.borderDefault),
            borderRadius: BorderRadius.circular(AppRadius.lgPlus),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in pedido.itens)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space1,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: semantic.fgDefault),
                        ),
                      ),
                      Text(
                        'x${item.quantidade}',
                        style: TextStyle(color: semantic.fgMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.only(top: AppSpacing.space3),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: semantic.borderDefault)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              Text(
                pedido.valor,
                style: TextStyle(
                  fontSize: AppTypography.xlPlus,
                  fontWeight: AppTypography.weightBold,
                  color: semantic.fgDefault,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
