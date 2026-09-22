import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';
import '../../../design/generated/app_layout.dart';

/// Banner de status de sincronização (spec §6.9) — espelha `SyncBanner.tsx`:
/// mostra a contagem de lançamentos pendentes. Online → permite "Sincronizar
/// agora" (esvazia a fila). Offline → aguarda conexão.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));
    final queue = ref.watch(fazendasStoreProvider.select((s) => s.syncQueue));

    if (queue.isEmpty) return const SizedBox.shrink();

    final label =
        '${queue.length} lançamento${queue.length > 1 ? 's' : ''} aguardando sincronização';

    return AppBanner(
      tone: AppBannerTone.warning,
      icon: AppIcon(
        isOnline ? AppIcons.refreshCw : AppIcons.cloudOff,
        size: AppSize.iconXs,
      ),
      action: isOnline
          ? AppButton(
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.sm,
              onPressed: () =>
                  ref.read(fazendasStoreProvider.notifier).clearSync(),
              child: const Text('Sincronizar'),
            )
          : null,
      child: Text(label),
    );
  }
}
