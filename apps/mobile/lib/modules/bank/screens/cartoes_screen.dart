import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/bank_card_visual.dart';
import '../../../design/generated/app_layout.dart';

enum _Sheet { segundaVia, ajustarLimite }

const Map<_Sheet, ({String title, String body})> _sheetMeta = {
  _Sheet.segundaVia: (
    title: 'Segunda via do cartão',
    body:
        'A solicitação de segunda via (novo plástico ou virtual) será processada no GB Bank web. Este fluxo será detalhado em uma próxima fase.',
  ),
  _Sheet.ajustarLimite: (
    title: 'Ajustar limite',
    body:
        'O pedido de aumento/redução de limite passa por análise de crédito. Este fluxo será detalhado em uma próxima fase.',
  ),
};

/// Gestão do cartão corporativo GB — cartão visual, limite e ações (bloqueio,
/// segunda via, limite). Espelha `CartoesScreen.tsx`.
class CartoesScreen extends ConsumerStatefulWidget {
  const CartoesScreen({super.key});

  @override
  ConsumerState<CartoesScreen> createState() => _CartoesScreenState();
}

class _CartoesScreenState extends ConsumerState<CartoesScreen> {
  bool _blocked = false;

  Future<void> _openSheet(_Sheet sheet) {
    final meta = _sheetMeta[sheet]!;
    return showAppBottomSheet<void>(
      context,
      title: meta.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppChip(
            tone: AppChipTone.amber,
            icon: AppIcon(AppIcons.construction, size: AppSize.iconXs),
            child: Text('Em desenvolvimento'),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            meta.body,
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: Theme.of(context).extension<AppSemanticColors>()!.fgMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppButton(
            fullWidth: true,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(level: AppHeadingLevel.h3, child: Text('Cartões')),
        const SizedBox(height: AppSpacing.space5),

        // Cartão visual + limite.
        AppCard(
          padded: false,
          child: Column(
            children: [
              Opacity(
                opacity: _blocked ? 0.6 : 1,
                child: const BankCardVisual(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Limite disponível',
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgMuted,
                          ),
                        ),
                        Text(
                          '${balanceHidden ? '••••' : Cartao.limiteDisponivel} / ${balanceHidden ? '••••' : Cartao.limiteTotal}',
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppProgressBar(
                      value: Cartao.usoPct.toDouble(),
                      colorByOccupancy: true,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      '${balanceHidden ? '••••' : Cartao.limiteUsado} usados de ${balanceHidden ? '••••' : Cartao.limiteTotal}',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: semantic.fgSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_blocked) ...[
          const SizedBox(height: AppSpacing.space5),
          const AppBanner(
            tone: AppBannerTone.warning,
            icon: AppIcon(AppIcons.lock, size: AppSize.iconXs),
            child: Text(
              'Cartão bloqueado temporariamente. Compras e saques estão suspensos até você reativar.',
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space5),

        // Bloqueio temporário.
        AppCard(
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
                  _blocked ? AppIcons.lock : AppIcons.shieldCheck,
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
                      'Bloquear temporariamente',
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Text(
                      'Suspende o cartão sem cancelá-lo. Reative a qualquer momento.',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppToggleSwitch(
                checked: _blocked,
                onChanged: (v) => setState(() => _blocked = v),
                label: _blocked
                    ? 'Reativar cartão'
                    : 'Bloquear cartão temporariamente',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),

        // Ações do cartão.
        const AppSectionTitle(child: Text('Ações do cartão')),
        const SizedBox(height: AppSpacing.space2),
        AppCard(
          padded: false,
          child: Column(
            children: [
              AppMenuItem(
                icon: AppIcons.refreshCw,
                label: 'Segunda via',
                description: 'Solicitar novo cartão físico ou virtual',
                onTap: () => _openSheet(_Sheet.segundaVia),
              ),
              AppMenuItem(
                icon: AppIcons.slidersHorizontal,
                label: 'Ajustar limite',
                description: 'Pedir aumento ou redução do limite',
                onTap: () => _openSheet(_Sheet.ajustarLimite),
              ),
              AppMenuItem(
                icon: AppIcons.slidersHorizontal,
                label: 'Ver limites e faixas',
                description: 'Crédito, Pix e saque',
                onTap: () => context.go('/bank/limites'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
