import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'action_bar.dart';
import 'app_icon.dart';
import 'content_sheet.dart';
import 'review_list.dart';
import 'step_progress.dart';
import 'top_bar.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// A faixa de contexto do topo das telas fundas: [AppLayout.headerH] (64) de
/// altura, sobre o canvas, com o [AppTopBar] centralizado dentro dela.
///
/// É essa faixa — e não a folha de conteúdo abaixo — que define a distância de
/// 64 px entre o topo da área segura e o início do card branco. Só cabe aqui o
/// nome da funcionalidade, o voltar e a ação/opções à direita: qualquer outra
/// coisa (régua de etapas, resumo, filtro) pertence ao interior da folha.
///
/// Fonte única da faixa (Lei 2): `SubPageHeader`, do shell, delega para cá, e o
/// [AppPageScaffold] a monta por dentro. Antes cada esqueleto de fluxo repetia
/// o `SizedBox` + `Padding` + `AppTopBar` à mão, e o valor de 64 px era garantia
/// de um arquivo só.
class AppPageHeaderBand extends StatelessWidget {
  const AppPageHeaderBand({
    super.key,
    required this.title,
    this.onBack,
    this.backLabel = 'Voltar',
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final String backLabel;

  /// Ação de overflow à direita do título.
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Conteúdo livre à direita, quando a ação não cabe num glifo.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.headerH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Center(
          child: AppTopBar(
            title: title,
            onBack: onBack,
            backLabel: backLabel,
            actionIcon: actionIcon,
            actionLabel: actionLabel,
            onAction: onAction,
            trailing: action,
          ),
        ),
      ),
    );
  }
}

/// O arquétipo de **tela funda** do padrão global, em uma peça: faixa de 64 px
/// sobre o canvas, folha **branca** ([AppSemanticColors.bgSurface]) sangrando
/// nas laterais e descendo até o fim da tela com raio 20 só nas quinas de
/// cima, e rodapé de ação fixo opcional.
///
/// A folha é a superfície branca, não um cartão dentro dela. Antes o branco
/// que se via no cadastro era um `AppCard` interno — com margem lateral
/// própria, raio nos quatro cantos e fim antes da base da tela — sobre uma
/// folha `bgSheet` (#F0F0F0) opticamente idêntica ao canvas (#F0F0F2), o que
/// fazia o raio de 20 desaparecer e o branco parar no meio da tela. Agora o
/// branco é a folha: encosta nas duas laterais, desce até a borda inferior e
/// o raio de cima aparece contra o cinza do canvas.
///
/// Vale para *todo* cadastro — administrativo e operacional — e também para as
/// visualizações de registro, que deixaram de ser folha inferior e passaram a
/// abrir aqui (ver [showAppDetailPage]): a tela cheia tem espaço para o dado
/// inteiro, sem os 15% de viewport que o modelo de deck reservava ao barrier.
///
/// [totalSteps] desenha a régua de etapas **dentro** da folha, acima do corpo —
/// nunca na faixa do topo. Essa era a divergência mais visível entre as telas:
/// alguns fluxos colocavam o progresso acima do card branco, e a régua lia como
/// parte do cromo de navegação em vez de parte do formulário.
///
/// Substitui a estrutura que `FlowShell` (Fazendas), `BankFlowShell` (Bank) e
/// `MappedFeatureScreen` mantinham triplicada. Enquanto eram três cópias, uma
/// correção de espaçamento pegava um módulo e deixava os outros dois para trás
/// — exatamente o que a Lei 2 existe para impedir.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backLabel = 'Voltar',
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.headerAction,
    this.totalSteps,
    this.currentStep = 0,
    this.actionBar,
    this.scrollable = true,
    this.bodyPadding,
    this.sheetColor,
  });

  final String title;

  /// Corpo da folha.
  final Widget child;

  final VoidCallback? onBack;
  final String backLabel;

  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Conteúdo livre à direita da faixa, quando a ação não cabe num glifo.
  final Widget? headerAction;

  /// Quantidade de etapas do fluxo. Presente, desenha a régua no topo da folha.
  final int? totalSteps;
  final int currentStep;

  /// Rodapé fixo — normalmente um [AppActionBar]. Fica dentro da folha, colado
  /// na base, e não rola com o corpo.
  final Widget? actionBar;

  /// Envolve [child] num `SingleChildScrollView`. Desligue quando o corpo já é
  /// rolável por conta própria (um `ListView`, por exemplo) ou quando ele deve
  /// preencher a folha sem rolar.
  final bool scrollable;

  /// Recuo do corpo. Padrão: os 16 px laterais do padrão global. Passe
  /// `EdgeInsets.zero` para conteúdo que precisa sangrar.
  final EdgeInsetsGeometry? bodyPadding;

  /// Superfície da folha. Padrão branco — só passe outra cor numa tela funda
  /// cujo corpo seja uma listagem de cartões, onde o cinza da folha é o que
  /// separa um cartão do outro.
  final Color? sheetColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final padding = bodyPadding ?? const EdgeInsets.all(AppSpacing.space4);

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      // `bottom: false`: a folha precisa alcançar a borda inferior física da
      // tela para o padrão fechar — quem respeita o inset de baixo é o
      // [AppActionBar], por dentro dela.
      body: SafeArea(
        bottom: false,
        child: AppPageBody(
          title: title,
          onBack: onBack,
          backLabel: backLabel,
          actionIcon: actionIcon,
          actionLabel: actionLabel,
          onAction: onAction,
          headerAction: headerAction,
          totalSteps: totalSteps,
          currentStep: currentStep,
          actionBar: actionBar,
          scrollable: scrollable,
          bodyPadding: padding,
          sheetColor: sheetColor,
          child: child,
        ),
      ),
    );
  }
}

/// O mesmo arquétipo sem `Scaffold` nem `SafeArea`, para telas que já estão
/// dentro de um deles — as funcionalidades mapeadas de Fazendas montam a
/// jornada dentro da moldura do shell, que já resolveu a área segura.
///
/// Existe para que essas telas herdem a faixa de 64 px, o raio da folha e a
/// posição da régua da mesma fonte que [AppPageScaffold], em vez de recompor a
/// coluna à mão e divergir na primeira correção.
class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backLabel = 'Voltar',
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.headerAction,
    this.totalSteps,
    this.currentStep = 0,
    this.actionBar,
    this.scrollable = true,
    this.bodyPadding,
    this.sheetColor,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final String backLabel;
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? headerAction;
  final int? totalSteps;
  final int currentStep;
  final Widget? actionBar;
  final bool scrollable;
  final EdgeInsetsGeometry? bodyPadding;
  final Color? sheetColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final padding = bodyPadding ?? const EdgeInsets.all(AppSpacing.space4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeaderBand(
          title: title,
          onBack: onBack,
          backLabel: backLabel,
          actionIcon: actionIcon,
          actionLabel: actionLabel,
          onAction: onAction,
          action: headerAction,
        ),
        Expanded(
          child: AppContentSheet(
            padded: false,
            color: sheetColor ?? semantic.bgSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (totalSteps != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space5,
                      AppSpacing.space4,
                      0,
                    ),
                    child: AppStepProgress(
                      total: totalSteps!,
                      current: currentStep,
                    ),
                  ),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(padding: padding, child: child)
                      : Padding(padding: padding, child: child),
                ),
                ?actionBar,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Abre uma **visualização** em tela cheia: o mesmo arquétipo dos cadastros,
/// empurrado como rota.
///
/// Substitui `showAppBottomSheet` no detalhamento de registro (transação,
/// movimentação de armazém, contrato, pedido, atividade, curral…). A folha
/// inferior servia bem para escolher uma opção, mas detalhar um registro nela
/// custava caro: teto de 85% da viewport, corpo rolando num container curto e
/// nenhum lugar para o título viver a não ser dentro do próprio conteúdo. Em
/// tela cheia o dado usa a altura inteira e o retorno é o voltar padrão, o
/// mesmo gesto de qualquer outra tela funda.
///
/// Pickers e formulários curtos continuam em `showAppBottomSheet` — ali a folha
/// é a escolha certa: sobrepor sem sair do contexto é o ponto.
Future<T?> showAppDetailPage<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  AppIconData? actionIcon,
  String? actionLabel,
  VoidCallback? onAction,
  Widget? actionBar,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    MaterialPageRoute<T>(
      builder: (routeContext) => AppPageScaffold(
        title: title,
        onBack: () => Navigator.of(routeContext).maybePop(),
        actionIcon: actionIcon,
        actionLabel: actionLabel,
        onAction: onAction,
        actionBar: actionBar,
        child: child,
      ),
    ),
  );
}

WidgetbookComponent buildPageScaffoldWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'PageScaffold',
    useCases: [
      WidgetbookUseCase(
        name: 'Cadastro (rodapé fixo)',
        builder: (context) => AppPageScaffold(
          title: 'Novo animal',
          onBack: () {},
          actionIcon: AppIcons.moreVertical,
          actionLabel: 'Mais opções',
          onAction: () {},
          actionBar: AppActionBar(
            primaryLabel: 'Salvar registro',
            primaryIcon: AppIcons.saveAll,
            onPrimary: () {},
          ),
          child: const AppReviewList(
            items: [
              AppReviewItem(label: 'Categoria', value: 'Novilha'),
              AppReviewItem(label: 'Raça', value: 'Nelore'),
              AppReviewItem(label: 'Peso (kg)', value: '412'),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Cadastro em etapas',
        builder: (context) => AppPageScaffold(
          title: 'Nova pesagem',
          onBack: () {},
          totalSteps: 4,
          currentStep: 2,
          actionBar: AppActionBar(
            primaryLabel: 'Continuar',
            primaryIcon: AppIcons.arrowRight,
            onPrimary: () {},
          ),
          child: const Text(
            'A régua de etapas fica dentro da folha branca, acima do corpo do '
            'formulário — nunca na faixa do topo.',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Visualização em tela cheia',
        builder: (context) => const AppPageScaffold(
          title: 'Detalhe da movimentação',
          child: AppReviewList(
            items: [
              AppReviewItem(label: 'Produto', value: 'Milho grão'),
              AppReviewItem(label: 'Quantidade', value: '18,4 t'),
              AppReviewItem(label: 'Unidade', value: 'Armazém Central'),
              AppReviewItem(label: 'Responsável', value: 'Equipe de campo'),
            ],
          ),
        ),
      ),
    ],
  );
}
