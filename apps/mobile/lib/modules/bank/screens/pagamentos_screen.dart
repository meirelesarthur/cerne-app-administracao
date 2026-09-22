import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'flows/pix_flow.dart';
import 'flows/simple_payment_flow.dart';
import '../../../design/generated/app_layout.dart';

/// Fluxo selecionado no hub de Pagamentos — `pix` ou um [PaymentKind].
enum PagamentosFlow { pix, boleto, transferir, cobrar }

class _Acao {
  const _Acao({
    required this.flow,
    required this.icon,
    required this.label,
    required this.description,
  });

  final PagamentosFlow flow;
  final AppIconData icon;
  final String label;
  final String description;
}

const _acoes = [
  _Acao(
    flow: PagamentosFlow.pix,
    icon: AppIcons.zap,
    label: 'Pix',
    description: 'Envie na hora por chave ou contato',
  ),
  _Acao(
    flow: PagamentosFlow.boleto,
    icon: AppIcons.scanLine,
    label: 'Pagar boleto',
    description: 'Pague contas e boletos por código',
  ),
  _Acao(
    flow: PagamentosFlow.transferir,
    icon: AppIcons.arrowLeftRight,
    label: 'Transferir',
    description: 'TED/entre contas para outro banco',
  ),
  _Acao(
    flow: PagamentosFlow.cobrar,
    icon: AppIcons.handCoins,
    label: 'Cobrar',
    description: 'Gere uma cobrança Pix para receber',
  ),
];

/// Hub de Pagamentos do GB Bank — destino das QuickActions (Pix/Pagar/
/// Transferir/Cobrar). Cada ação entra num fluxo mockado (revisão → sucesso).
/// O Pix é o fluxo de referência, completo; os demais são formulários simples
/// honestos (`SimplePaymentFlow`). Espelha `PagamentosScreen.tsx`.
class PagamentosScreen extends ConsumerStatefulWidget {
  const PagamentosScreen({super.key, this.initialFlow});

  /// Abre direto em um fluxo específico (ex.: deep-link `/bank/pix`).
  final PagamentosFlow? initialFlow;

  @override
  ConsumerState<PagamentosScreen> createState() => _PagamentosScreenState();
}

class _PagamentosScreenState extends ConsumerState<PagamentosScreen> {
  PagamentosFlow? _flow;

  @override
  void initState() {
    super.initState();
    _flow = widget.initialFlow;
  }

  void _exit() => setState(() => _flow = null);

  @override
  Widget build(BuildContext context) {
    if (_flow == PagamentosFlow.pix) return PixFlow(onExit: _exit);
    if (_flow != null) {
      final kind = switch (_flow!) {
        PagamentosFlow.boleto => PaymentKind.boleto,
        PagamentosFlow.transferir => PaymentKind.transferir,
        PagamentosFlow.cobrar => PaymentKind.cobrar,
        PagamentosFlow.pix => throw StateError('unreachable'),
      };
      return SimplePaymentFlow(kind: kind, onExit: _exit);
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(level: AppHeadingLevel.h3, child: Text('Pagamentos')),
        const SizedBox(height: AppSpacing.space1),
        Text(
          'Pix, boletos, transferências e cobranças em um só lugar.',
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        const SizedBox(height: AppSpacing.space5),
        Row(
          children: [
            for (final a in _acoes)
              Expanded(
                child: AppQuickAction(
                  icon: a.icon,
                  label: a.label,
                  onPressed: () => setState(() => _flow = a.flow),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Todas as opções')),
        const SizedBox(height: AppSpacing.space2),
        for (final a in _acoes) ...[
          AppCard(
            interactive: true,
            onTap: () => setState(() => _flow = a.flow),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.accentSubtle,
                  ),
                  child: AppIcon(
                    a.icon,
                    size: AppSize.iconMd,
                    color: semantic.accentDefault,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.md,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        a.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  AppIcons.chevronRight,
                  size: AppSize.iconSmPlus,
                  color: semantic.fgSubtle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
      ],
    );
  }
}
