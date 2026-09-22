import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../components/sub_page_header.dart';
import '../module_config.dart';
import '../state/shell_store.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

const Map<String, AppIconData> _moduleIcon = {
  'fazendas': AppIcons.sprout,
  'credito': AppIcons.handCoins,
  'bank': AppIcons.landmark,
};

/// Notificações agregadas de todos os módulos (spec §3.1) — espelha `Notificacoes.tsx`.
class NotificacoesPage extends ConsumerWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final notifications = ref.watch(shellStoreProvider).notifications;
    final hasUnread = notifications.any((n) => !n.read);

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            SubPageHeader(
              title: 'Notificações',
              action: hasUnread
                  ? AppButton(
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () =>
                          ref.read(shellStoreProvider.notifier).markAllRead(),
                      child: const Text('Marcar lidas'),
                    )
                  : null,
            ),
            Expanded(
              child: AppContentSheet(
                padded: false,
                child: notifications.isEmpty
                    ? const Center(
                        child: AppEmptyState(
                          icon: AppIcons.bellOff,
                          title: 'Sem notificações',
                          description: 'Você está em dia.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.space4),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.space2),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          final icon =
                              _moduleIcon[n.moduleId] ?? AppIcons.sprout;
                          final destination =
                              getModule(n.moduleId)?.homeRoute ?? '/inicio';

                          return AppCard(
                            interactive: true,
                            onTap: () => context.go(destination),
                            padded: false,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.space3),
                              decoration: !n.read
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.xl3,
                                      ),
                                      border: Border.all(
                                        color: semantic.accentDefault
                                            .withValues(alpha: 0.6),
                                      ),
                                    )
                                  : null,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: AppSpacing.space10,
                                    height: AppSpacing.space10,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: semantic.accentSubtle,
                                      shape: BoxShape.circle,
                                    ),
                                    child: AppIcon(
                                      icon,
                                      size: AppSize.iconMd,
                                      color: semantic.accentDefault,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.space3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: AppTypography
                                                      .weightSemibold,
                                                  color: semantic.fgDefault,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.space2,
                                            ),
                                            Text(
                                              n.time,
                                              style: TextStyle(
                                                fontSize: AppTypography.xs,
                                                color: semantic.fgSubtle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          n.detail,
                                          style: TextStyle(
                                            color: semantic.fgMuted,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.space1,
                                        ),
                                        AppChip(child: Text(n.moduleId)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
