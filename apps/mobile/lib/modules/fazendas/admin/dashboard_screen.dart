import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../shared/simulated_load.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';

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
  });

  final String title;
  final Widget child;

  /// Marca a tela como de acesso restrito (spec §4.6).
  final bool restricted;

  /// Oculta o banner de dados em cache (ex.: telas não cacheáveis offline).
  final bool hideOfflineBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));

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
              : null,
        ),
        Expanded(
          child: AppContentSheet(
            padded: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isOnline && !hideOfflineBanner)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.space2),
                    child: AppBanner(
                      icon: AppIcon(AppIcons.cloudOff, size: AppSize.iconXs),
                      child: Text(
                        'Dados de 01/07 às 08:00 — última sincronização.',
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
