import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

/// Ícone e variante de cada cartão, na ordem de `pecuariaFinanceiro`
/// (receita, custo, margem). As variantes coloridas de `AppDashboardCard` já
/// existiam no catálogo e nunca tinham sido usadas nos painéis — é exatamente
/// aqui que elas fazem sentido: verde entra, vermelho sai, azul é o resultado.
const _cardStyle = [
  (icon: AppIcons.wallet, variant: AppDashboardCardVariant.revenue),
  (icon: AppIcons.package, variant: AppDashboardCardVariant.expense),
  (icon: AppIcons.beef, variant: AppDashboardCardVariant.finance),
];

/// Painel **Resultado** — fusão de "Financeiro" (§4.3) com o bloco financeiro
/// de "Pecuária de Corte" (§4.1).
///
/// Os dois painéis mostravam o mesmo P&L: receita, custo e margem apareciam em
/// Pecuária com exatamente os mesmos valores que a Home gerencial já exibia, e
/// o resto da tela de Pecuária era um bloco produtivo desativado mais uma lista
/// de atividades que já existe em `/fazendas/atividades`. O desempenho
/// produtivo migrou para o painel de Confinamento, onde há dado real (GMD
/// observado × previsto); aqui fica só a decisão de dinheiro.
///
/// Ver `docs/ESTEIRA-DASHBOARDS-ADM.md`, seção 2.
class DashResultado extends StatelessWidget {
  const DashResultado({super.key});

  @override
  Widget build(BuildContext context) {
    final atual = resultadoMeses.last;

    return DashboardScreen(
      title: 'Resultado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppMetricGrid(
            children: [
              AppKpiStatCard(
                label: 'A Receber',
                value: FinanceiroKpis.aReceber,
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(label: 'A Pagar', value: FinanceiroKpis.aPagar),
              AppKpiStatCard(
                label: 'Atrasados',
                value: FinanceiroKpis.atrasados,
                tone: AppKpiStatTone.negative,
                caption: 'Vencidos > 0',
              ),
              AppKpiStatCard(
                label: 'Investimentos',
                value: FinanceiroKpis.investimentos,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Receita × custo',
            period: '6 meses',
            footnote:
                'Margem do mês: ${formatMilhares(atual.margem)} '
                '(${formatMilhares(atual.receita)} − ${formatMilhares(atual.custo)}).',
            child: AppLineChart(
              labels: [for (final m in resultadoMeses) m.label],
              formatValue: (v) => formatMilhares(v),
              series: [
                AppLineSeries(
                  label: 'Receita',
                  points: [for (final m in resultadoMeses) m.receita],
                  filled: true,
                ),
                AppLineSeries(
                  label: 'Custo',
                  points: [for (final m in resultadoMeses) m.custo],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppMetricGrid(
            children: [
              for (var i = 0; i < pecuariaFinanceiro.length; i++)
                AppDashboardCard(
                  icon: _cardStyle[i % _cardStyle.length].icon,
                  label: pecuariaFinanceiro[i].label,
                  value: pecuariaFinanceiro[i].value,
                  delta: pecuariaFinanceiro[i].delta,
                  spark: pecuariaFinanceiro[i].spark,
                  variant: _cardStyle[i % _cardStyle.length].variant,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Despesa por centro de custo',
            subtitle: 'Mês corrente, em milhares (R\$)',
            child: AppBarChart(
              data: [
                for (final c in centrosCusto)
                  AppBarDatum(label: c.label, value: c.value),
              ],
              formatValue: (v) => '${v.toStringAsFixed(0)}k',
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Composição do custo',
            period: '6 meses',
            footnote:
                '"Outros" reúne manutenção, administrativo e logística — abertos '
                'na barra por centro de custo acima.',
            child: AppStackedBar(
              categories: resultadoCategorias,
              formatValue: (v) => '${v.toStringAsFixed(0)}k',
              data: [
                for (final m in resultadoMeses)
                  AppStackedDatum(
                    label: m.label,
                    values: [m.nutricao, m.sanidade, m.maoDeObra, m.outros],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
