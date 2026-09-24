import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import '../modules/fazendas/components/farm_picker.dart';
import '../modules/fazendas/state/fazendas_store.dart';
import '../ui/ui.dart';
import 'components/bottom_tab_bar.dart';
import 'components/context_tabs.dart';
import 'components/reveal_menu.dart';
import 'components/shell_header.dart';
import 'module_config.dart';
import 'state/shell_store.dart';
import 'state/prototype_session_store.dart';

/// Layout do Shell (spec §3.1) — espelha `ShellLayout.tsx`: header global fixo +
/// abas de contexto + conteúdo do módulo ativo + dock de módulos flutuante +
/// menu "reveal". Trocar de módulo troca só o conteúdo, o header persiste.
///
/// Com o menu aberto, o app inteiro encolhe (scale+translateX) revelando o
/// `AppRevealMenu` à direita — únicas responsabilidades deste widget que os
/// componentes filhos documentaram como "de quem monta o shell".
/// Módulos cujo conteúdo depende da fazenda ativa — só neles o shell mostra
/// o seletor de fazenda no topo.
const _modulosPorFazenda = {'fazendas', 'armazem'};

class ShellLayout extends ConsumerStatefulWidget {
  const ShellLayout({
    super.key,
    required this.moduleId,
    required this.activeTab,
    required this.child,
    this.hideChrome = false,
    this.compactChrome = false,
  });

  final String moduleId;
  final String activeTab;
  final Widget child;

  /// Quando `true` (rota mais funda que `/modulo/aba`, ex.: uma
  /// funcionalidade ou dashboard específico), o header global e as abas de
  /// contexto somem — quem mostra navegação/título ali é a própria tela
  /// (botão "Voltar", `SubPageHeader`, etc.), e o espaço liberado vai para o
  /// conteúdo da função.
  final bool hideChrome;

  /// Central de um módulo (`/fazendas/grupo/...`): mantém o
  /// contexto da fazenda e o dock global, mas entrega a saudação, o
  /// perfil e as abas para a tela interna ganhar espaço para sua própria
  /// busca e grade de funções.
  final bool compactChrome;

  @override
  ConsumerState<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends ConsumerState<ShellLayout> {
  /// Header global colapsado (ver plano de UX): rolar a tela do módulo para
  /// baixo esconde avatar/saudação/nome (`AppShellHeader.collapsed`), deixando
  /// só as bolhas de ação — libera ~74px de tela durante a tarefa. Nas rotas
  /// completas, as abas de contexto continuam visíveis (só o bloco de
  /// identidade colapsa).
  bool _headerCollapsed = false;

  @override
  void didUpdateWidget(covariant ShellLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nova tela/aba: volta a mostrar a identidade completa em vez de manter o
    // header colapsado de onde a pessoa rolou na tela anterior.
    if (oldWidget.moduleId != widget.moduleId ||
        oldWidget.activeTab != widget.activeTab ||
        oldWidget.compactChrome != widget.compactChrome) {
      _headerCollapsed = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    // Ignora rolagens horizontais (carrosséis dentro da tela) — só a rolagem
    // vertical do conteúdo principal decide o colapso do header.
    if (metrics.axis != Axis.vertical) return false;
    final shouldCollapse = metrics.pixels > 24;
    if (shouldCollapse != _headerCollapsed) {
      setState(() => _headerCollapsed = shouldCollapse);
    }
    return false;
  }

  void _go(BuildContext context, WidgetRef ref, String route) {
    ref.read(shellStoreProvider.notifier).closeMenu();
    context.go(route);
  }

  void _push(BuildContext context, WidgetRef ref, String route) {
    ref.read(shellStoreProvider.notifier).closeMenu();
    context.push(route);
  }

  void _openSearch(BuildContext context, WidgetRef ref) =>
      _push(context, ref, '/busca');

  /// Corpo do módulo: faixa de offline (quando aplicável) e a tela em si.
  /// Ocupa toda a altura disponível; a navbar é desenhada por cima na Stack.
  Widget _content(ShellState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Column(
        children: [
          if (!state.isOnline)
            const AppBanner(
              tone: AppBannerTone.offline,
              icon: AppIcon(AppIcons.cloudOff, size: AppSize.iconXs),
              child: Text(
                'Você está offline — os lançamentos serão sincronizados quando a conexão voltar.',
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleId = widget.moduleId;
    final activeTab = widget.activeTab;
    final hideChrome = widget.hideChrome;
    final compactChrome = widget.compactChrome;
    final module = getModule(moduleId) ?? getModule('fazendas')!;
    final state = ref.watch(shellStoreProvider);
    final profile = ref.watch(prototypeSessionProvider).profile;
    final activeFarm = ref.watch(fazendasStoreProvider).activeFarm;
    final menuOpen = state.menuOpen;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final showGlobalContext = !hideChrome && profile != null;
    // O seletor de fazenda só aparece onde a fazenda muda o conteúdo. No
    // Início, Bank, Crédito e Market ele era ruído: trocar de fazenda
    // ali não mudava nada na tela.
    final showFarmSelector =
        showGlobalContext && _modulosPorFazenda.contains(moduleId);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: menuOpen
                  ? AppComponentColors.revealMenuBg
                  : semantic.bgCanvas,
            ),
          ),
          // menu revelado — fica atrás do app encolhido, à direita.
          Positioned.fill(
            child: AppRevealMenu(
              module: module,
              activeRoute: GoRouterState.of(context).uri.toString(),
              onNavigate: (route) => _go(context, ref, route),
              onPush: (route) => _push(context, ref, route),
            ),
          ),
          // o app inteiro — encolhe como cartão quando o menu abre.
          LayoutBuilder(
            builder: (context, constraints) {
              final shiftX =
                  constraints.maxWidth *
                  (AppComponentMetrics.revealMenuAppShiftX / 100);
              final scale = AppComponentMetrics.revealMenuAppScale;

              return AnimatedContainer(
                duration: reduceMotion ? Duration.zero : AppMotion.slow,
                curve: AppMotion.easingSpring,
                transform: menuOpen
                    ? (Matrix4.identity()
                        ..translateByDouble(shiftX, 0, 0, 1)
                        ..scaleByDouble(scale, scale, scale, 1))
                    : Matrix4.identity(),
                transformAlignment: Alignment.centerLeft,
                clipBehavior: menuOpen ? Clip.antiAlias : Clip.none,
                decoration: menuOpen
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl3),
                        boxShadow: semantic.shadowModal,
                      )
                    : null,
                child: _ShrunkAppTapToClose(
                  menuOpen: menuOpen,
                  onClose: () =>
                      ref.read(shellStoreProvider.notifier).closeMenu(),
                  child: ColoredBox(
                    color: semantic.bgCanvas,
                    child: Stack(
                      children: [
                        SafeArea(
                          bottom: false,
                          // Rotas fundas mantêm o topo sobre o canvas: nos
                          // frames de cadastro do Figma a barra superior fica
                          // *acima* da folha, e é a própria tela que abre a
                          // folha logo abaixo dela. Nas rotas rasas o shell
                          // abre a folha aqui, com o cabeçalho e as abas
                          // dentro — como nas duas homes da referência.
                          child: hideChrome
                              ? _content(state)
                              : AppContentSheet(
                                  padded: false,
                                  header: showFarmSelector
                                      ? AppFarmSelector(
                                          farmName: activeFarm.name,
                                          onTap: () =>
                                              openFarmPicker(context, ref),
                                        )
                                      : null,
                                  child: Column(
                                    children: [
                                      if (!compactChrome)
                                        AnimatedSize(
                                          duration: reduceMotion
                                              ? Duration.zero
                                              : AppMotion.base,
                                          curve: AppMotion.easingOut,
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            children: [
                                              AppShellHeader(
                                                collapsed: _headerCollapsed,
                                                showMenu: false,
                                                showProfileSubtitle: false,
                                                onOpenProfile: () => _push(
                                                  context,
                                                  ref,
                                                  '/perfil',
                                                ),
                                                onOpenNotifications: () =>
                                                    _push(
                                                      context,
                                                      ref,
                                                      '/notificacoes',
                                                    ),
                                                child: showGlobalContext
                                                    ? AppSearchField(
                                                        onTap: () =>
                                                            _openSearch(
                                                              context,
                                                              ref,
                                                            ),
                                                      )
                                                    : null,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppSpacing.space4,
                                                    ),
                                                child: AppContextTabs(
                                                  module: module,
                                                  profile: profile,
                                                  activePath: activeTab,
                                                  onTabSelected: (path) => _go(
                                                    context,
                                                    ref,
                                                    path.isEmpty
                                                        ? '/${module.id}'
                                                        : '/${module.id}/$path',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Expanded(child: _content(state)),
                                    ],
                                  ),
                                ),
                        ),
                        if (!hideChrome)
                          Positioned(
                            left: AppComponentMetrics.tabbarInset,
                            right: AppComponentMetrics.tabbarInset,
                            // Soma o respiro inferior à safe-area real do aparelho;
                            // o hexágono ativo também ocupa a altura elevada da barra.
                            bottom:
                                AppComponentMetrics.tabbarInset +
                                MediaQuery.of(context).padding.bottom,
                            child: Center(
                              child: AppBottomTabBar(
                                activeId: module.id,
                                onModuleSelected: (id) => _go(
                                  context,
                                  ref,
                                  moduleHomeRoute(getModule(id)!, profile),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Com o menu aberto, tocar em área vazia do app encolhido fecha o menu —
/// espelha o botão-overlay invisível do React (`absolute inset-0` ATRÁS do
/// conteúdo). Envolver o conteúdo inteiro (em vez de um overlay separado por
/// cima de tudo) é necessário no Flutter: um overlay `Positioned.fill`
/// desenhado por cima bloquearia também os toques no `AppRevealMenu` ao lado,
/// já que ambos ocupam a Stack inteira. Botões internos (header, tabs, dock)
/// continuam recebendo seus próprios toques normalmente — a arena de gestos
/// do Flutter prioriza o `AppPressable` mais interno.
class _ShrunkAppTapToClose extends StatelessWidget {
  const _ShrunkAppTapToClose({
    required this.menuOpen,
    required this.onClose,
    required this.child,
  });

  final bool menuOpen;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!menuOpen) return child;
    return AppPressable(
      semanticLabel: 'Fechar menu',
      onPressed: onClose,
      minTouchTarget: false,
      showVisualFeedback: false,
      child: child,
    );
  }
}
