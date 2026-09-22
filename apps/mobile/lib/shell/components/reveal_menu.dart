import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_layout.dart';
import '../../design/generated/app_motion.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../design/theme/theme_provider.dart';
import '../../ui/ui.dart';
import '../module_config.dart';
import '../state/prototype_session_store.dart';
import '../state/shell_store.dart';

/// Painel do menu "reveal" global (Nova UI): revelado à direita — espelha
/// `RevealMenu.tsx`. Contextual ao módulo ativo: lista as demais
/// funcionalidades do módulo ([getMenuSections]) + seção de conta.
///
/// Decisões de porte (ver instruções da tarefa):
/// - Este widget é só o painel em si (a parte que desliza). O encolhimento do
///   app-por-trás (`transform`/`scale`) e o posicionamento absoluto
///   `inset-y-0 right-0` são responsabilidade de quem monta o `ShellLayout`
///   (ainda não existe) — ele deve envolver este widget em `Stack` +
///   `Positioned` com a largura definida pelo pai.
/// - "Fecha ao navegar" (o `useEffect` que reage a `location.pathname` no
///   React) não é implementado aqui — é responsabilidade do `ShellLayout`
///   ao trocar de rota.
/// - Fecha em Esc via `Focus`/`KeyEvent` enquanto o menu está aberto.
/// - O ambiente Fazendas vem do perfil da sessão; não existe alternância local.
/// - Como não há `location`/go_router acoplado, o destaque de "item ativo"
///   usa um [activeRoute] opcional (extensão sobre a spec, default `null` =
///   nenhum item destacado) em vez do `location.pathname === item.route` do
///   React.
class AppRevealMenu extends ConsumerStatefulWidget {
  const AppRevealMenu({
    super.key,
    required this.module,
    required this.onNavigate,
    this.activeRoute,
  });

  final ModuleDef module;

  /// Recebe a rota absoluta de destino (ex.: `/perfil`, `/notificacoes`, `/login`).
  final ValueChanged<String> onNavigate;

  /// Rota atual do app, usada só para destacar o item correspondente no menu.
  final String? activeRoute;

  @override
  ConsumerState<AppRevealMenu> createState() => _AppRevealMenuState();
}

class _AppRevealMenuState extends ConsumerState<AppRevealMenu> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'AppRevealMenu');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final menuOpen = ref.read(shellStoreProvider).menuOpen;
    if (menuOpen &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(shellStoreProvider.notifier).closeMenu();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final state = ref.watch(shellStoreProvider);
    final themeVariant = ref.watch(themeVariantProvider);
    final menuOpen = state.menuOpen;
    final profile = ref.watch(prototypeSessionProvider).profile;

    if (menuOpen && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: Semantics(
        container: true,
        label: 'Menu do módulo ${widget.module.label}',
        hidden: !menuOpen,
        child: AnimatedSlide(
          duration: AppMotion.slow,
          curve: AppMotion.easingSpring,
          offset: menuOpen ? Offset.zero : const Offset(0.06, 0),
          child: AnimatedOpacity(
            duration: AppMotion.slow,
            curve: AppMotion.easingSpring,
            opacity: menuOpen ? 1 : 0,
            child: IgnorePointer(
              ignoring: !menuOpen,
              child: FractionallySizedBox(
                widthFactor: AppComponentMetrics.revealMenuMenuWidth / 100,
                alignment: Alignment.centerRight,
                child: Material(
                  color: AppComponentColors.revealMenuBg,
                  child: SafeArea(
                    child: menuOpen
                        ? _MenuContent(
                            module: widget.module,
                            state: state,
                            profile: profile,
                            themeVariant: themeVariant,
                            activeRoute: widget.activeRoute,
                            semantic: semantic,
                            onNavigate: widget.onNavigate,
                            onToggleTheme: () => ref
                                .read(themeVariantProvider.notifier)
                                .toggle(),
                            onToggleOnline: () => ref
                                .read(shellStoreProvider.notifier)
                                .toggleOnline(),
                            onLogout: () {
                              ref
                                  .read(prototypeSessionProvider.notifier)
                                  .logout();
                              widget.onNavigate('/login');
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({
    required this.module,
    required this.state,
    required this.profile,
    required this.themeVariant,
    required this.activeRoute,
    required this.semantic,
    required this.onNavigate,
    required this.onToggleTheme,
    required this.onToggleOnline,
    required this.onLogout,
  });

  final ModuleDef module;
  final ShellState state;
  final UserAccessProfile? profile;
  final AppThemeVariant themeVariant;
  final String? activeRoute;
  final AppSemanticColors semantic;
  final ValueChanged<String> onNavigate;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleOnline;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = state.user;
    final unread = state.unreadCount;
    final isOnline = state.isOnline;
    final isGbMode = themeVariant == AppThemeVariant.gbMode;
    final roleLabel = profile?.roleLabel ?? 'Sessão não iniciada';
    final sections = getMenuSections(module, profile: profile);

    var idx = 0;
    int next() => idx++;

    final children = <Widget>[
      // identidade do usuário
      _stagger(
        next(),
        AppPressable(
          semanticLabel: 'Abrir perfil de ${user.name}',
          onPressed: () => onNavigate('/perfil'),
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space2),
            child: Row(
              children: [
                AppAvatar(
                  name: user.name,
                  initials: user.initials,
                  size: AppAvatarSize.lg,
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.lg,
                          fontWeight: AppTypography.weightBold,
                          color: semantic.inkFg,
                        ),
                      ),
                      Text(
                        '$roleLabel · GB CERNE',
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: semantic.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  AppIcons.chevronRight,
                  size: AppSize.iconSmPlus,
                  color: semantic.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.space3),

      // contexto do módulo ativo
      _stagger(
        next(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
          child: Row(
            children: [
              Container(
                height: AppSpacing.space7,
                width: AppSpacing.space7,
                decoration: BoxDecoration(
                  color: semantic.inkBubble,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  module.icon,
                  size: AppSize.iconXs,
                  color: semantic.inkFg,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                module.label,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.inkFg,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.space2),

      // funcionalidades do módulo atual
      for (final section in sections) ...[
        _stagger(
          next(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space3,
              AppSpacing.space2,
              AppSpacing.space3,
              AppSpacing.space1,
            ),
            child: Text(
              section.title.toUpperCase(),
              style: TextStyle(
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.weightSemibold,
                letterSpacing: 0.4,
                color: semantic.inkSubtle,
              ),
            ),
          ),
        ),
        for (final item in section.items) ...[
          _stagger(
            next(),
            AppMenuItem(
              variant: AppMenuItemVariant.onDark,
              icon: item.icon,
              label: item.label,
              active: activeRoute == item.route,
              onTap: () => onNavigate(item.route),
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
        ],
      ],

      _stagger(
        next(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
          height: 1,
          color: semantic.inkLine,
        ),
      ),

      // conta e preferências
      _stagger(
        next(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space3,
            0,
            AppSpacing.space3,
            AppSpacing.space1,
          ),
          child: Text(
            'CONTA',
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              letterSpacing: 0.4,
              color: semantic.inkSubtle,
            ),
          ),
        ),
      ),
      _stagger(
        next(),
        AppMenuItem(
          variant: AppMenuItemVariant.onDark,
          icon: AppIcons.bell,
          label: 'Notificações',
          trailing: unread > 0 ? AppBadge(child: Text('$unread')) : null,
          onTap: () => onNavigate('/notificacoes'),
        ),
      ),
      const SizedBox(height: AppSpacing.space1),
      _stagger(
        next(),
        AppMenuItem(
          variant: AppMenuItemVariant.onDark,
          icon: AppIcons.settings,
          label: 'Configurações',
          onTap: () => onNavigate('/perfil'),
        ),
      ),
      const SizedBox(height: AppSpacing.space1),
      _stagger(
        next(),
        AppMenuItem(
          variant: AppMenuItemVariant.onDark,
          icon: AppIcons.moon,
          label: 'Modo GB',
          description: 'Tema escuro para campo e baixa luz',
          trailing: Text(
            isGbMode ? 'Ativo' : 'Inativo',
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.inkMuted,
            ),
          ),
          onTap: onToggleTheme,
        ),
      ),
      const SizedBox(height: AppSpacing.space1),
      _stagger(
        next(),
        AppMenuItem(
          variant: AppMenuItemVariant.onDark,
          icon: isOnline ? AppIcons.wifi : AppIcons.wifiOff,
          label: 'Conexão',
          description: 'Simula a sincronização em campo sem sinal',
          trailing: Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.inkMuted,
            ),
          ),
          onTap: onToggleOnline,
        ),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const ValueKey('reveal-menu-scroll'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space6,
            ),
            children: children,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space6,
          ),
          child: _stagger(
            next(),
            AppMenuItem(
              variant: AppMenuItemVariant.onDark,
              tone: AppMenuItemTone.danger,
              icon: AppIcons.logOut,
              label: 'Sair',
              onTap: onLogout,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stagger(int index, Widget child) =>
      _StaggerItem(index: index, child: child);
}

/// Entrada escalonada dos itens do menu (motion tokenizado): fade + slide sutil
/// com atraso proporcional ao índice. Respeita
/// `MediaQuery.of(context).disableAnimations` (pula a animação nesse caso).
class _StaggerItem extends StatefulWidget {
  const _StaggerItem({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.base);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
      return;
    }

    final delay = AppMotion.revealMenuItemStagger * widget.index;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easingOut,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
