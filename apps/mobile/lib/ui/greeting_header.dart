import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'avatar.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Cabeçalho de saudação do padrão global — o `Header` das duas homes do
/// Figma (`54349:2372` na Operação, `54333:370` no Administrativo).
///
/// Anatomia medida: avatar de 48 px com as iniciais em 18 px Medium, saudação
/// de 14 px Medium abafada, nome de 20 px SemiBold, e à direita uma bolha
/// branca de 44 px (raio 22, sombra `AppShadows.bubble`) com o sino de 28 px.
/// O ponto de não-lida é um círculo verde de 8 px na quina superior direita.
///
/// É o **único** bloco que os dois arquétipos de home compartilham — a esteira
/// do padrão global fixa isso como regra (§4): o que é comum sobe para o
/// cabeçalho, o resto fica no arquétipo. Por isso ele vive no catálogo e não
/// dentro do shell.
class AppGreetingHeader extends StatelessWidget {
  const AppGreetingHeader({
    super.key,
    required this.greeting,
    required this.name,
    this.initials,
    this.subtitle,
    this.hasUnread = false,
    this.onNotifications,
    this.notificationsLabel = 'Notificações',
    this.onProfile,
    this.beforeNotifications,
    this.trailing,
  });

  /// "Boa tarde," — a saudação por período do dia.
  final String greeting;
  final String name;

  /// Iniciais do avatar. Nulo deriva de [name] (regra do `AppAvatar`).
  final String? initials;

  /// Linha de contexto sob o nome — no app, o ambiente da sessão. Não existe na
  /// referência: o Figma pressupõe um único ambiente, e o GB CERNE tem dois
  /// perfis com permissões distintas. Extensão registrada.
  final String? subtitle;

  /// Pinta o ponto de não-lida sobre a bolha do sino.
  final bool hasUnread;
  final VoidCallback? onNotifications;
  final String notificationsLabel;
  final VoidCallback? onProfile;

  /// Ação global exibida imediatamente antes do sino. O shell usa esse slot
  /// para a troca rápida entre Light e GB Mode nas duas homes.
  final Widget? beforeNotifications;

  /// Bolhas extras à direita do sino (menu, modo consulta). Também extensão:
  /// o Figma só tem o sino, mas o shell do app tem ações globais próprias.
  final Widget? trailing;

  /// Aresta da bolha de notificação no Figma.
  static const double _bubbleSize = AppSize.control;

  /// Diâmetro do ponto de não-lida (54300:14591).
  static const double _dotSize = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAvatar(name: name, initials: initials, size: AppAvatarSize.lg),
        const SizedBox(width: AppSpacing.space2),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightMedium,
                  height: AppTypography.lineHeightHeading,
                  color: semantic.fgMuted,
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.accentDefault,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final bell = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _bubbleSize,
          height: _bubbleSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: semantic.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.bubble,
          ),
          child: AppIcon(
            AppIcons.bell,
            size: AppSize.iconXl,
            color: semantic.fgDefault,
          ),
        ),
        if (hasUnread)
          Positioned(
            top: AppSpacing.space1,
            right: AppSpacing.space1,
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: semantic.accentDefault,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );

    return Row(
      children: [
        Expanded(
          child: onProfile == null
              ? identity
              : AppPressable(
                  semanticLabel: name,
                  onPressed: onProfile,
                  minTouchTarget: false,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: identity,
                ),
        ),
        const SizedBox(width: AppSpacing.space2),
        if (beforeNotifications != null) ...[
          beforeNotifications!,
          const SizedBox(width: AppSpacing.space2),
        ],
        AppPressable(
          semanticLabel: hasUnread
              ? '$notificationsLabel, há novas'
              : notificationsLabel,
          onPressed: onNotifications,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: bell,
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.space2),
          trailing!,
        ],
      ],
    );
  }
}

WidgetbookComponent buildGreetingHeaderWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'GreetingHeader',
    useCases: [
      WidgetbookUseCase(
        name: 'Com não-lidas',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppGreetingHeader(
            greeting: 'Boa tarde,',
            name: 'Silvio Ventura',
            hasUnread: true,
            onNotifications: () {},
            onProfile: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem não-lidas',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppGreetingHeader(
            greeting: 'Bom dia,',
            name: 'Maria Aparecida de Souza',
            subtitle: 'Ambiente Operação',
            onNotifications: () {},
          ),
        ),
      ),
    ],
  );
}
