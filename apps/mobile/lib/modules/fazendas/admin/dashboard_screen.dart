import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../shared/simulated_load.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';

/// Scaffold comum dos dashboards administrativos de Fazendas (spec §7.1):
/// cabeçalho, chip de "Acesso restrito", banner de dados em cache quando
/// offline e skeleton de carregamento simulado. Compartilhado pelos 7
/// dashboards de `admin/` (Lei 2 — fonte única).
///
/// **Tela sem referência direta no Figma.** Recebe o arquétipo mais próximo —
/// `administrativo-home` sem as abas: barra superior sobre o canvas, folha de
/// conteúdo arredondada e os blocos do painel dentro dela. Nenhuma linguagem
/// visual nova: o que muda em relação a um cadastro é o conteúdo, não a
/// moldura.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.title,
    required this.child,
    this.restricted = false,
    this.hideOfflineBanner = false,
    this.action,
  });

  final String title;
  final Widget child;

  /// Marca a tela como de acesso restrito (spec §4.6).
  final bool restricted;

  /// Oculta o banner de dados em cache (ex.: telas não cacheáveis offline).
  final bool hideOfflineBanner;

  /// Ação à direita da faixa do topo (ex.: o "+" de criar). O selo de acesso
  /// restrito ([restricted]) tem precedência sobre ela.
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));
    final fazenda = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm.name),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubPageHeader(
          title: title,
          action: restricted
              ? const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.space1),
                  child: AppChip(
                    tone: AppChipTone.amber,
                    icon: AppIcon(AppIcons.shieldAlert, size: AppSize.iconXs),
                    child: Text('Acesso restrito'),
                  ),
                )
              : action,
        ),
        Expanded(
          child: AppContentSheet(
            padded: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // De qual fazenda são estes números: nas telas fundas o
                // seletor global de fazenda não aparece.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space4,
                    AppSpacing.space3,
                    AppSpacing.space4,
                    0,
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        AppIcons.mapPin,
                        size: AppSize.iconSm,
                        color: Theme.of(
                          context,
                        ).extension<AppSemanticColors>()!.fgMuted,
                      ),
                      const SizedBox(width: AppSpacing.space1),
                      Expanded(
                        child: Text(
                          fazenda,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isOnline && !hideOfflineBanner)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.space2),
                    child: AppBanner(
                      icon: AppIcon(AppIcons.cloudOff, size: AppSize.iconXs),
                      child: Text(
                        'Sem conexão: os números são os da última '
                        'atualização e podem estar desatualizados.',
                      ),
                    ),
                  ),
                Expanded(
                  child: SimulatedLoad(
                    builder: (context, loading) => loading
                        ? GridView.count(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.space2,
                            crossAxisSpacing: AppSpacing.space2,
                            childAspectRatio: 1.3,
                            children: const [
                              AppCardSkeleton(),
                              AppCardSkeleton(),
                              AppCardSkeleton(),
                              AppCardSkeleton(),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.space4),
                            child: child,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
