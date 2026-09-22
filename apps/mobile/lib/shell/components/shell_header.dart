import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_motion.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/theme_provider.dart';
import '../../ui/ui.dart';
import '../state/shell_store.dart';
import '../state/prototype_session_store.dart';

/// Header global do Shell: o cabeçalho de saudação do padrão global
/// (`AppGreetingHeader`) mais as bolhas de ação que só existem no app.
/// Persiste ao trocar de módulo.
///
/// O bloco de identidade — avatar, saudação, nome e sino — deixou de ser
/// desenhado aqui: é o único bloco que as duas homes do Figma compartilham
/// (§4 da esteira do padrão global) e por isso mora no catálogo. O que sobrou
/// neste widget é o que a referência não tem: o menu "reveal", o modo consulta
/// e o rótulo do ambiente da sessão.
///
/// Decisão de porte: as rotas `/perfil` e `/notificacoes` ainda não existem no
/// `go_router` (isso é F3.1, feito por outro processo depois). Por isso este
/// widget recebe [onOpenProfile]/[onOpenNotifications] como callbacks opcionais
/// em vez de navegar direto — quem monta o header no `ShellLayout` conecta ao
/// router quando as rotas existirem.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o header aceita
/// [collapsed] — quando a tela é rolada para baixo, quem monta o `ShellLayout`
/// coloca este widget no modo compacto (só as bolhas de ação, ~48px) e some
/// com avatar/saudação/nome. Antes o bloco de identidade ficava fixo o tempo
/// todo (~122px), competindo por espaço com o conteúdo da tela em toda
/// rolagem — útil só na entrada da tela, não durante a tarefa.
class AppShellHeader extends ConsumerWidget {
  const AppShellHeader({
    super.key,
    this.onConsultMode,
    this.consultActive = false,
    this.onOpenProfile,
    this.onOpenNotifications,
    this.collapsed = false,
    this.showMenu = true,
    this.showProfileSubtitle = true,
    this.child,
  });

  /// Callback do ícone "olho" (modo consulta) — contextual ao módulo ativo
  /// (spec §3.3/§6.1). Quando nulo, o botão não é exibido — equivalente a
  /// `onConsultMode &&` no React.
  final VoidCallback? onConsultMode;
  final bool consultActive;

  /// Navegação para `/perfil` — ver nota de decisão acima.
  final VoidCallback? onOpenProfile;

  /// Navegação para `/notificacoes` — ver nota de decisão acima.
  final VoidCallback? onOpenNotifications;

  /// Modo compacto (ver nota de classe acima): esconde avatar/saudação/nome e
  /// o slot [child], mantendo só as bolhas de ação à direita.
  final bool collapsed;

  /// O menu operacional vive na barra inferior; nesse modo o cabeçalho mantém
  /// apenas o sino no extremo direito, como na referência da entrada de campo.
  final bool showMenu;

  /// A referência da entrada operacional não repete o ambiente sob o nome do
  /// usuário: a fazenda já governa o app na faixa superior.
  final bool showProfileSubtitle;

  /// Slot de contexto do módulo ativo — equivalente ao `children` do React;
  /// aqui é um único `child` porque só há um consumidor real historicamente
  /// (a pílula de crédito, que saiu do header global — ver plano de UX).
  /// Omitido no modo [collapsed].
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shellStoreProvider);
    final profile = ref.watch(prototypeSessionProvider).profile;
    final user = state.user;
    final unread = state.unreadCount;
    final menuOpen = state.menuOpen;
    final themeVariant = ref.watch(themeVariantProvider);
    final isGbMode = themeVariant == AppThemeVariant.gbMode;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Determinístico no protótipo (sem Date.now/relógio real) — a entrada de
    // operação segue a referência e fixa o período da tarde.
    const hour = 14;
    const greeting = hour < 12
        ? 'Bom dia'
        : (hour < 18 ? 'Boa tarde' : 'Boa noite');

    final actionWidgets = <Widget>[
      if (onConsultMode != null) ...[
        _headerBubble(
          icon: const AppIcon(AppIcons.eye, size: AppSize.iconMd),
          label: consultActive ? 'Sair do modo consulta' : 'Modo consulta',
          active: consultActive,
          onPressed: onConsultMode,
        ),
        const SizedBox(width: AppSpacing.space2),
      ],
      if (showMenu)
        _headerBubble(
          icon: const AppIcon(AppIcons.menu, size: AppSize.iconMd),
          label: 'Mais',
          active: menuOpen,
          onPressed: () => ref.read(shellStoreProvider.notifier).openMenu(),
        ),
    ];
    final actions = actionWidgets.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: actionWidgets);

    final content = collapsed
        ? Padding(
            key: const ValueKey('collapsed'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [?actions],
            ),
          )
        : Padding(
            key: const ValueKey('expanded'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppGreetingHeader(
                  greeting: '$greeting,',
                  name: user.name,
                  initials: user.initials,
                  subtitle: !showProfileSubtitle || profile == null
                      ? null
                      : 'Ambiente ${profile.label}',
                  hasUnread: unread > 0,
                  onNotifications: onOpenNotifications,
                  onProfile: onOpenProfile,
                  // Sem bolha: a referência do Figma mostra a troca de tema
                  // como ícone solto ao lado do sino (que tem bolha própria),
                  // não como uma segunda bolha igual — variante `ghost` do
                  // `AppIconButton` (fundo transparente, sem sombra).
                  beforeNotifications: AppIconButton(
                    icon: AppIcon(
                      isGbMode ? AppIcons.sun : AppIcons.moon,
                      size: AppSize.iconMd,
                    ),
                    label: isGbMode ? 'Ativar modo claro' : 'Ativar GB Mode',
                    size: AppIconButtonSize.lg,
                    onPressed: () =>
                        ref.read(themeVariantProvider.notifier).toggle(),
                  ),
                  trailing: actions,
                ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: child!,
                    ),
                  ),
              ],
            ),
          );

    // Sem `ColoredBox` próprio: o header agora fica dentro da folha de conteúdo
    // (`AppContentSheet`), como no Figma, e pintar o canvas aqui abriria um
    // retângulo cinza dentro dela.
    return AnimatedSize(
      duration: reduceMotion ? Duration.zero : AppMotion.base,
      curve: AppMotion.easingOut,
      alignment: Alignment.topCenter,
      child: content,
    );
  }

  /// Bolha do header com estado "ativo" (modo consulta ligado / menu aberto).
  /// No React o estado ativo usa `bg-ink text-ink-fg` sólido; o catálogo
  /// `AppIconButton` não tem essa variante exata (só `ghost`/`solid`/`onDark`,
  /// onde `onDark` usa `inkBubble` semitransparente). Usamos `onDark` como a
  /// aproximação mais próxima disponível sem editar `icon_button.dart`
  /// (fora do escopo desta tarefa) — desvio documentado.
  Widget _headerBubble({
    required Widget icon,
    required String label,
    required bool active,
    required VoidCallback? onPressed,
  }) {
    return AppIconButton(
      icon: icon,
      label: label,
      size: AppIconButtonSize.lg,
      variant: active
          ? AppIconButtonVariant.onDark
          : AppIconButtonVariant.solid,
      onPressed: onPressed,
    );
  }
}
