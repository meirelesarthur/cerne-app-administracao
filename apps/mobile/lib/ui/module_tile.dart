import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Layouts possíveis do ladrilho: compacto para a entrada do app e expandido
/// para a central interna de um módulo.
enum AppModuleTileLayout { home, module }

/// Ladrilho do lançador de módulos — o bloco de repetição do padrão global
/// (Figma `54300-2458`, frames `operacao-home` e `modulo-confinamento`).
///
/// Anatomia medida no Figma: 116 px de altura, raio [AppRadius.tile] (20),
/// `px 12 / py 16`, ícone de 32 px **ancorado no topo-esquerda** e rótulo de
/// 14 px **ancorado na base-esquerda**. A largura vem da grade, não do widget.
///
/// Por que não é uma variante de `AppBentoTile`: o bento ancora o ícone numa
/// bolha preenchida e centraliza o conjunto; aqui o ícone é nu. As duas
/// anatomias deste widget compartilham o mesmo fundo, raio e interação, por
/// isso [AppModuleTileLayout] explicita a diferença sem duplicar o ladrilho.
///
/// Na variante [AppModuleTileLayout.module], [description] fica na base do
/// card e o ícone vai para o canto inferior direito, como no frame
/// `modulo-confinamento`.

class AppModuleTile extends StatelessWidget {
  const AppModuleTile({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.layout = AppModuleTileLayout.home,
    this.onTap,
  });

  /// Ícone do módulo — entrada de `AppIcons`, preferencialmente um apelido de
  /// domínio (`AppIcons.confinamento`, `AppIcons.pecuaria`…).
  final AppIconData icon;

  /// Nome do módulo. Quebra em até duas linhas, como "Ordem de Serviço" e
  /// "Sincronizar aplicativo" no Figma.
  final String label;

  /// Resumo curto da funcionalidade. Presente na grade de um módulo, ausente
  /// na home.
  final String? description;
  final AppModuleTileLayout layout;

  final VoidCallback? onTap;

  /// Altura do Figma. Fixa de propósito: a grade da home alinha ladrilhos de
  /// rótulos com 1 e 2 linhas, e altura por conteúdo desalinharia as fileiras.
  static const double height = 116;

  /// Altura do card de função dentro de um módulo (`modulo-confinamento`).
  static const double moduleHeight = 168;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final titleWidget = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: layout == AppModuleTileLayout.module
            ? AppTypography.xl
            : AppTypography.md,
        fontWeight: layout == AppModuleTileLayout.module
            ? AppTypography.weightSemibold
            : AppTypography.weightMedium,
        height: AppTypography.lineHeightTight,
        color: semantic.fgDefault,
      ),
    );

    final descriptionWidget = description == null
        ? null
        : Text(
            description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.sm,
              height: AppTypography.lineHeightTight,
              color: semantic.fgSecondary,
            ),
          );

    final content = layout == AppModuleTileLayout.module
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (descriptionWidget != null)
                    Expanded(child: descriptionWidget),
                  if (descriptionWidget != null)
                    const SizedBox(width: AppSpacing.space2),
                  AppIcon(
                    icon,
                    size: AppSize.iconXxl,
                    color: semantic.fgSecondary,
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIcon(
                icon,
                size: AppSize.iconXxl,
                color: semantic.fgSecondary,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget,
                  if (descriptionWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.space1),
                      child: descriptionWidget,
                    ),
                ],
              ),
            ],
          );

    return AppPressable(
      semanticLabel: label,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        height: layout == AppModuleTileLayout.module ? moduleHeight : height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space4,
        ),
        // Cinza do Figma sobre a folha de conteúdo. A divergência registrada na
        // esteira (§6-E, "ladrilho `bgSurface` sobre o canvas") caiu quando
        // `AppContentSheet` trouxe a camada que faltava: com a folha `bgSheet`
        // por baixo, `bgSubtle` volta a se destacar como na referência, sem
        // depender só da sombra.
        decoration: BoxDecoration(
          color: semantic.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.tile),
          boxShadow: AppShadows.row,
        ),
        // Neutro, não verde: na referência o ladrilho não usa a cor da
        // marca — o destaque vem do rótulo, e o ícone é um traço fino
        // escuro (medido em 54349:2639).
        child: content,
      ),
    );
  }
}

/// Grade de ladrilhos do padrão global: duas colunas e `gap 8`. Por padrão, o
/// último item ocupa a largura inteira quando a contagem é ímpar — exatamente
/// o que o Figma faz com "Sincronizar aplicativo". Centrais internas podem
/// desligar [lastTileFullWidth] para deixar o último card na primeira coluna.
///
/// A grade existe como componente porque a regra do item largo é do padrão,
/// não da tela: repeti-la em cada home reintroduziria a divergência que a
/// esteira fechou.
class AppModuleTileGrid extends StatelessWidget {
  const AppModuleTileGrid({
    super.key,
    required this.tiles,
    this.lastTileFullWidth = true,
  });

  final List<AppModuleTile> tiles;

  /// Na home, o último item ímpar é um atalho largo. Na central interna, a
  /// referência deixa o último card na primeira coluna, com a segunda vazia.
  final bool lastTileFullWidth;

  /// `gap 8` do Figma.
  static const double gap = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < tiles.length; i += 2) {
      final isLast = i == tiles.length - 1;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));
      rows.add(
        isLast && lastTileFullWidth
            ? SizedBox(width: double.infinity, child: tiles[i])
            : isLast
            ? Row(
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: gap),
                  const Expanded(child: SizedBox()),
                ],
              )
            // Sem `stretch`: o ladrilho já tem altura fixa, e `stretch` num
            // `Row` dentro de uma coluna de altura não limitada (o `ListView`
            // da home) pede altura infinita e quebra o layout.
            : Row(
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: gap),
                  Expanded(child: tiles[i + 1]),
                ],
              ),
      );
    }

    // `min`: a grade é um bloco dentro da rolagem da home, não a própria tela.
    // Com o padrão (`max`) ela ocuparia toda a altura disponível e empurraria o
    // que vem depois para fora.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

WidgetbookComponent buildModuleTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ModuleTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Grade da home de Operação',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SingleChildScrollView(
            child: AppModuleTileGrid(
              tiles: [
                AppModuleTile(
                  icon: AppIcons.confinamento,
                  label: 'Confinamento',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.pecuaria,
                  label: 'Pecuária',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.agricultura,
                  label: 'Agricultura',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.ordemServico,
                  label: 'Ordem de Serviço',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.sincronizar,
                  label: 'Sincronizar aplicativo',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Grade de um módulo (com resumo)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SingleChildScrollView(
            child: AppModuleTileGrid(
              lastTileFullWidth: false,
              tiles: [
                AppModuleTile(
                  icon: AppIcons.warehouse,
                  label: 'Meus Currais',
                  description: 'Ações realizadas nos currais',
                  layout: AppModuleTileLayout.module,
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.misturador,
                  label: 'Produzir Batelada',
                  description: 'Registrar produção física',
                  layout: AppModuleTileLayout.module,
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.wheat,
                  label: 'Trato Diário',
                  description: 'Registrar produção das dietas',
                  layout: AppModuleTileLayout.module,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
