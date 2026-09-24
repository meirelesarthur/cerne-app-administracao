import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Tom de uma notificação: pinta a bolha do ícone e o ponto de não lida.
enum AppNotificationTone { success, info, warning, danger, neutral }

/// Linha de notificação: bolha circular com o ícone sobre um brilho na cor do
/// tom, título, texto de apoio, selo de tempo e, quando não lida, um ponto na
/// mesma cor à direita.
///
/// Superfície [AppSemanticColors.bgRaised] sem borda e raio [AppRadius.tile]
/// — o cartão branco sobre a folha cinza no tema claro e o verde elevado no
/// Modo GB, o mesmo idioma dos cards de OS ([AppStatusCard]).
class AppNotificationTile extends StatelessWidget {
  const AppNotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.tone = AppNotificationTone.neutral,
    this.unread = false,
    this.onTap,
  });

  final AppIconData icon;
  final String title;
  final String message;

  /// Tempo relativo já formatado ("há 5 min", "ontem").
  final String timeLabel;
  final AppNotificationTone tone;
  final bool unread;
  final VoidCallback? onTap;

  static Color toneColor(
    AppSemanticColors semantic,
    AppNotificationTone tone,
  ) => switch (tone) {
    AppNotificationTone.success => semantic.accentDefault,
    AppNotificationTone.info => AppColors.feedbackInfoSolid,
    AppNotificationTone.warning => AppColors.feedbackNotice,
    AppNotificationTone.danger => AppColors.feedbackErrorSolid,
    AppNotificationTone.neutral => semantic.fgMuted,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final color = toneColor(semantic, tone);
    final radius = BorderRadius.circular(AppRadius.tile);

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(color: semantic.bgRaised, borderRadius: radius),
      child: Row(
        children: [
          // Bolha com brilho: o tom entra forte no centro e se dissolve na
          // borda, como a referência — lê o tipo antes do texto.
          Container(
            width: AppSpacing.space12,
            height: AppSpacing.space12,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.32),
                  color.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: AppIcon(icon, size: AppSize.iconMd, color: color),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: unread
                        ? AppTypography.weightBold
                        : AppTypography.weightSemibold,
                    color: semantic.fgHeading,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: semantic.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2,
                    vertical: AppSpacing.half,
                  ),
                  decoration: BoxDecoration(
                    color: semantic.bgTrack,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.weightMedium,
                      color: semantic.fgSubtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          // Mantém a largura mesmo lida, para os textos não "pularem" ao
          // marcar como lida.
          SizedBox(
            width: AppSpacing.space2,
            height: AppSpacing.space2,
            child: unread
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return AppPressable(
      semanticLabel: unread ? '$title, não lida' : title,
      onPressed: onTap,
      borderRadius: radius,
      child: content,
    );
  }
}

WidgetbookComponent buildNotificationTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'NotificationTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons e estado de leitura',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppNotificationTile(
              icon: AppIcons.check,
              title: 'Pesagem registrada',
              message: 'Lote 42 · Fazenda São Pedro',
              timeLabel: 'há 5 min',
              tone: AppNotificationTone.success,
              unread: true,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppNotificationTile(
              icon: AppIcons.fileText,
              title: 'Nova ordem de serviço atribuída',
              message: 'OS #2201 · Reparo de cerca do Talhão 04',
              timeLabel: 'há 1 h',
              tone: AppNotificationTone.info,
              unread: true,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppNotificationTile(
              icon: AppIcons.x,
              title: 'OS cancelada pelo escritório',
              message: 'OS #2160 · Serviço terceirizado',
              timeLabel: 'ontem',
              tone: AppNotificationTone.danger,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppNotificationTile(
              icon: AppIcons.bell,
              title: 'Novidade no aplicativo',
              message: 'Ações rápidas nos cards de OS.',
              timeLabel: 'há 2 dias',
              tone: AppNotificationTone.warning,
              onTap: () {},
            ),
          ],
        ),
      ),
    ],
  );
}
