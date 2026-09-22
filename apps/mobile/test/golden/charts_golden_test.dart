import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/bar_chart.dart';
import 'package:cerne_app/ui/bullet_chart.dart';
import 'package:cerne_app/ui/donut_chart.dart';
import 'package:cerne_app/ui/gauge.dart';
import 'package:cerne_app/ui/line_chart.dart';
import 'package:cerne_app/ui/stacked_bar.dart';

import 'golden_helpers.dart';

/// Goldens dos gráficos do catálogo. Além de travar a regressão visual, são a
/// prova de que a série categórica agora sobrevive ao gbMode: cada cenário é
/// renderizado nos dois temas, lendo `AppSemanticColors.chartSeries`.
void main() {
  const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
  const receita = AppLineSeries(
    label: 'Receita',
    points: [1820, 1960, 1740, 2280, 2143, 2400],
    filled: true,
  );
  const custo = AppLineSeries(
    label: 'Custo',
    points: [1180, 1240, 1090, 1160, 1146, 1100],
  );

  goldenTest(
    'AppLineChart — série temporal nos dois temas',
    fileName: 'app_line_chart',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final variant in AppThemeVariant.values)
          GoldenTestScenario(
            name: variant.name,
            child: SizedBox(
              width: 360,
              child: themedGolden(
                variant,
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppLineChart(series: [receita, custo], labels: meses),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  // Cenário deliberado de valores desiguais: com o piso de 14% que existia
  // antes, "Miúdos" (5) desenhava quase a mesma barra de "Sanidade" (120).
  goldenTest(
    'AppBarChart — proporção honesta em valores desiguais',
    fileName: 'app_bar_chart',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final variant in AppThemeVariant.values)
          GoldenTestScenario(
            name: variant.name,
            child: SizedBox(
              width: 360,
              child: themedGolden(
                variant,
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppBarChart(
                    data: [
                      AppBarDatum(label: 'Nutrição', value: 590),
                      AppBarDatum(label: 'Sanidade', value: 120),
                      AppBarDatum(label: 'Logística', value: 48),
                      AppBarDatum(label: 'Miúdos', value: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'AppStackedBar — composição por período',
    fileName: 'app_stacked_bar',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final variant in AppThemeVariant.values)
          GoldenTestScenario(
            name: variant.name,
            child: SizedBox(
              width: 360,
              child: themedGolden(
                variant,
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppStackedBar(
                    categories: ['Nutrição', 'Sanidade', 'Mão de obra'],
                    data: [
                      AppStackedDatum(label: 'Jan', values: [496, 160, 300]),
                      AppStackedDatum(label: 'Fev', values: [521, 168, 315]),
                      AppStackedDatum(label: 'Mar', values: [458, 148, 277]),
                      AppStackedDatum(label: 'Abr', values: [487, 157, 295]),
                      AppStackedDatum(label: 'Mai', values: [481, 155, 291]),
                      AppStackedDatum(label: 'Jun', values: [462, 149, 279]),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'AppGauge — ocupação e meta',
    fileName: 'app_gauge',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final variant in AppThemeVariant.values) ...[
          GoldenTestScenario(
            name: '${variant.name}_ocupacao',
            child: themedGolden(
              variant,
              const Padding(
                padding: EdgeInsets.all(16),
                child: AppGauge(value: 64, label: 'ocupação'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${variant.name}_meta',
            child: themedGolden(
              variant,
              const Padding(
                padding: EdgeInsets.all(16),
                child: AppGauge(
                  value: 1.42,
                  max: 1.86,
                  target: 1.55,
                  valueLabel: '1,42',
                  label: 'GMD kg/dia',
                  tone: AppGaugeTone.warning,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  goldenTest(
    'AppBulletChart — realizado contra meta',
    fileName: 'app_bullet_chart',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final variant in AppThemeVariant.values)
          GoldenTestScenario(
            name: variant.name,
            child: SizedBox(
              width: 360,
              child: themedGolden(
                variant,
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppBulletChart(
                    data: [
                      AppBulletDatum(
                        label: 'Economia em cotações',
                        value: 82,
                        target: 70,
                      ),
                      AppBulletDatum(
                        label: 'Precisão de batelada',
                        value: 93,
                        target: 95,
                      ),
                      // "Maior é melhor" é o padrão do componente; métricas em
                      // que menor é melhor (preço, prazo) passam `color`.
                      AppBulletDatum(
                        label: 'Cobertura de estoque',
                        value: 48,
                        target: 72,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'AppDonutChart — legenda com percentual',
    fileName: 'app_donut_chart',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final variant in AppThemeVariant.values)
          GoldenTestScenario(
            name: variant.name,
            child: SizedBox(
              width: 360,
              child: themedGolden(
                variant,
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppDonutChart(
                    centerValue: 'R\$ 1,88 mi',
                    centerLabel: 'aquisição',
                    data: [
                      AppDonutSlice(label: 'Máquinas', value: 1290),
                      AppDonutSlice(label: 'Infraestrutura', value: 310),
                      AppDonutSlice(label: 'Veículos', value: 240),
                      AppDonutSlice(label: 'Equipamentos', value: 45),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
