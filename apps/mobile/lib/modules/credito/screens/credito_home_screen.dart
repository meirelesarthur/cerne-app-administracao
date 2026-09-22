import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_motion.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../credito_status.dart';
import '../mocks/credito_mocks.dart';
import '../../../design/generated/app_layout.dart';

/// Ícone por linha de crédito — espelha `LINHA_ICONS` de `CreditoHome.tsx`.
final Map<String, AppIconData> _linhaIcons = {
  'custeio-safra': AppIcons.sprout,
  'investimento-maquinas': AppIcons.tractor,
  'cpr-financeira': AppIcons.fileText,
  'consorcio-agro': AppIcons.users,
};

/// Home do módulo Crédito: oferta pré-aprovada em destaque, simulador rápido
/// (valor × prazo → parcela estimada), linhas de crédito disponíveis e as
/// propostas mais recentes do produtor. Espelha `CreditoHome.tsx`.
class CreditoHomeScreen extends StatefulWidget {
  const CreditoHomeScreen({super.key, this.scrollToSimulador = false});

  /// Quando true (rota /credito/simular), rola automaticamente até o
  /// simulador ao montar — equivalente à prop `scrollToSimulador` do React.
  final bool scrollToSimulador;

  @override
  State<CreditoHomeScreen> createState() => _CreditoHomeScreenState();
}

class _CreditoHomeScreenState extends State<CreditoHomeScreen> {
  final GlobalKey _simuladorKey = GlobalKey();

  String _valorSelecionado = valoresSimulacao[2];
  int _prazoSelecionado = prazosSimulacao[1];

  @override
  void initState() {
    super.initState();
    if (widget.scrollToSimulador) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSimulador());
    }
  }

  void _scrollToSimulador() {
    final ctx = _simuladorKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: AppMotion.slow,
      curve: AppMotion.easingOut,
    );
  }

  SimulacaoOpcao? get _opcaoAtual =>
      simulacao.cast<SimulacaoOpcao?>().firstWhere(
        (s) => s!.valor == _valorSelecionado && s.prazo == _prazoSelecionado,
        orElse: () => null,
      );

  LinhaCredito get _linhaAtual =>
      linhas.firstWhere((l) => l.id == 'custeio-safra');

  void _abrirLinha(LinhaCredito linha) {
    showAppDetailPage<void>(
      context,
      title: linha.nome,
      child: _LinhaBottomSheetContent(
        linha: linha,
        onSimular: () {
          Navigator.of(context).maybePop();
          _scrollToSimulador();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final opcaoAtual = _opcaoAtual;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        // Hero — oferta pré-aprovada.
        RiseIn(child: _CreditoHero(onSimular: _scrollToSimulador)),
        const SizedBox(height: AppSpacing.space6),

        // Simulador rápido.
        RiseIn(
          index: 1,
          child: Column(
            key: _simuladorKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Simulador rápido')),
              const SizedBox(height: AppSpacing.space2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space1,
                ),
                child: Text(
                  'Valor',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Wrap(
                spacing: AppSpacing.space2,
                runSpacing: AppSpacing.space2,
                children: [
                  for (final valor in valoresSimulacao)
                    AppButton(
                      size: AppButtonSize.sm,
                      variant: valor == _valorSelecionado
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      onPressed: () =>
                          setState(() => _valorSelecionado = valor),
                      child: Text(valor),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space1,
                ),
                child: Text(
                  'Prazo',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Wrap(
                spacing: AppSpacing.space2,
                runSpacing: AppSpacing.space2,
                children: [
                  for (final prazo in prazosSimulacao)
                    AppButton(
                      size: AppButtonSize.sm,
                      variant: prazo == _prazoSelecionado
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      onPressed: () =>
                          setState(() => _prazoSelecionado = prazo),
                      child: Text('$prazo meses'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Parcela estimada',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.fgMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      opcaoAtual?.parcela ?? '—',
                      style: TextStyle(
                        fontSize: AppTypography.xl2,
                        fontWeight: AppTypography.weightBold,
                        color: semantic.fgDefault,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.half),
                    Text(
                      'Taxa ${_linhaAtual.taxa} · $_prazoSelecionado parcelas',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: semantic.fgSubtle,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    AppButton(
                      fullWidth: true,
                      onPressed: () => context.go('/credito/propostas'),
                      child: const Text('Enviar proposta'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Linhas disponíveis.
        RiseIn(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Linhas disponíveis')),
              const SizedBox(height: AppSpacing.space2),
              Column(
                children: [
                  for (final linha in linhas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: AppCard(
                        interactive: true,
                        onTap: () => _abrirLinha(linha),
                        child: Row(
                          children: [
                            Container(
                              width: AppSpacing.space10 + AppSpacing.space1,
                              height: AppSpacing.space10 + AppSpacing.space1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: semantic.accentDefault,
                              ),
                              child: AppIcon(
                                _linhaIcons[linha.id] ?? AppIcons.fileText,
                                size: AppSize.iconMd,
                                color: AppColors.neutral0,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          linha.nome,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: AppTypography.sm,
                                            fontWeight:
                                                AppTypography.weightSemibold,
                                            color: semantic.fgDefault,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.space2),
                                      AppChip(
                                        tone: AppChipTone.brand,
                                        child: Text(linha.taxa),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.half),
                                  Text(
                                    linha.descricao,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppTypography.xs,
                                      color: semantic.fgMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppIcon(
                              AppIcons.arrowRight,
                              size: AppSize.iconSmPlus,
                              color: semantic.accentDefault,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Minhas propostas.
        RiseIn(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionTitle(child: Text('Minhas propostas')),
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    rightIcon: const AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconXs,
                    ),
                    onPressed: () => context.go('/credito/propostas'),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              AppCard(
                padded: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Column(
                    children: [
                      for (final proposta in propostas.take(2))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.space3,
                          ),
                          decoration: proposta == propostas.take(2).last
                              ? null
                              : BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: semantic.borderDefault,
                                    ),
                                  ),
                                ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      proposta.linha,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppTypography.sm,
                                        fontWeight: AppTypography.weightMedium,
                                        color: semantic.fgDefault,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.half),
                                    Text(
                                      proposta.data,
                                      style: TextStyle(
                                        fontSize: AppTypography.xs,
                                        color: semantic.fgMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    proposta.valor,
                                    style: TextStyle(
                                      fontSize: AppTypography.sm,
                                      fontWeight: AppTypography.weightSemibold,
                                      color: semantic.fgDefault,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space1),
                                  AppChip(
                                    tone: propostaStatusTone(proposta.status),
                                    child: Text(
                                      propostaStatusLabel(proposta.status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Hero de crédito pré-aprovado — gradiente escuro com glow radial da marca.
class _CreditoHero extends StatelessWidget {
  const _CreditoHero({required this.onSimular});

  final VoidCallback onSimular;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppComponentColors.hubBankCardFrom,
            AppComponentColors.hubBankCardTo,
          ],
        ),
        boxShadow: Theme.of(context).extension<AppSemanticColors>()!.shadowCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            top: -64,
            child: IgnorePointer(
              child: Container(
                width: 176,
                height: 176,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppComponentColors.hubBankCardGlow,
                      AppColors.transparent,
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSpacing.space8,
                    height: AppSpacing.space8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neutral0.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      AppIcons.handCoins,
                      size: AppSize.iconSm,
                      color: AppColors.neutral0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  const AppChip(
                    tone: AppChipTone.brand,
                    child: Text('Pré-aprovado'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              const Text(
                PreAprovado.valor,
                style: TextStyle(
                  fontSize: AppTypography.xl4,
                  fontWeight: AppTypography.weightBold,
                  height: AppTypography.lineHeightTight,
                  color: AppColors.neutral0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              const Text(
                'Validade ${PreAprovado.validade} · ${PreAprovado.taxa}',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: AppComponentColors.hubBankCardFgMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: onSimular,
                child: const Text('Simular agora'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinhaBottomSheetContent extends StatelessWidget {
  const _LinhaBottomSheetContent({
    required this.linha,
    required this.onSimular,
  });

  final LinhaCredito linha;
  final VoidCallback onSimular;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppReviewList(
          items: [AppReviewItem(label: 'Taxa', value: linha.taxa)],
        ),
        const SizedBox(height: AppSpacing.space3),
        Text(
          linha.descricao,
          style: TextStyle(
            fontSize: AppTypography.sm,
            color: semantic.fgSubtle,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        AppButton(
          fullWidth: true,
          onPressed: onSimular,
          child: const Text('Simular esta linha'),
        ),
      ],
    );
  }
}
