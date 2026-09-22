/// Escala de eixo compartilhada pelos gráficos com eixo de valor
/// ([AppLineChart], [AppBarChart], [AppStackedBar]).
///
/// Este arquivo é interno ao catálogo: **não** é exportado por `ui.dart`, logo
/// não precisa de caso de Widgetbook — é matemática, não widget.
library;

import 'dart:math' as math;

/// Um eixo de valor "redondo": limites e passo escolhidos entre 1, 2, 2,5 e 5
/// vezes uma potência de dez, para os rótulos caírem em números que uma pessoa
/// lê sem esforço (0 / 100 / 200 …, nunca 0 / 137 / 274 …).
class ChartScale {
  const ChartScale({required this.min, required this.max, required this.step});

  final double min;
  final double max;
  final double step;

  /// Os valores de cada linha de grade, do menor para o maior.
  List<double> get ticks {
    if (step <= 0) return [min, max];
    final out = <double>[];
    // Tolerância de meio passo evita perder o último tick por erro de ponto
    // flutuante acumulado na soma.
    for (var v = min; v <= max + step / 2; v += step) {
      out.add(v);
    }
    return out;
  }

  /// Posição de [value] no eixo, de 0 (base) a 1 (topo).
  double fraction(double value) {
    final span = max - min;
    if (span <= 0) return 0;
    return ((value - min) / span).clamp(0.0, 1.0);
  }

  /// Constrói a escala que cobre [values] com aproximadamente [targetTicks]
  /// linhas de grade. Séries só de zeros caem num eixo 0–1 em vez de degenerar.
  factory ChartScale.forValues(
    Iterable<double> values, {
    int targetTicks = 4,
    bool includeZero = true,
  }) {
    final list = values.where((v) => v.isFinite).toList();
    if (list.isEmpty) return const ChartScale(min: 0, max: 1, step: 1);

    var lo = list.reduce(math.min);
    var hi = list.reduce(math.max);
    if (includeZero) {
      lo = math.min(lo, 0);
      hi = math.max(hi, 0);
    }
    if (lo == hi) {
      if (hi == 0) return const ChartScale(min: 0, max: 1, step: 0.25);
      lo = math.min(0, hi);
      hi = math.max(0, hi);
    }

    final step = _bestStep(lo, hi, targetTicks);
    final niceMin = (lo / step).floorToDouble() * step;
    final niceMax = (hi / step).ceilToDouble() * step;
    return ChartScale(min: niceMin, max: niceMax, step: step);
  }

  /// Escolhe o passo redondo que menos desperdiça altura.
  ///
  /// Arredondar um único passo a partir da média deixa buracos: com valores até
  /// 1004 e 4 marcas, o passo cai em 500 e o eixo sobe até 1500 — mais de um
  /// terço do gráfico em branco. Aqui todos os passos redondos plausíveis são
  /// testados e vence o menor topo que ainda mantenha uma contagem de marcas
  /// legível.
  static double _bestStep(double lo, double hi, int targetTicks) {
    const factors = [1.0, 2.0, 2.5, 5.0, 10.0];
    final span = hi - lo;
    if (span <= 0) return 1;

    final baseExp = (math.log(span / targetTicks) / math.ln10).floor();
    final minTicks = math.max(2, targetTicks - 2);
    // Teto de marcas: dobrar o alvo aperta bem o topo, mas enche um cartao
    // pequeno de linha de grade. +2 e o meio-termo.
    final maxTicks = targetTicks + 2;

    double? melhorPasso;
    double? melhorTopo;

    for (var exp = baseExp - 1; exp <= baseExp + 1; exp++) {
      final magnitude = math.pow(10, exp).toDouble();
      for (final factor in factors) {
        final step = factor * magnitude;
        if (step <= 0) continue;
        final niceMin = (lo / step).floorToDouble() * step;
        final niceMax = (hi / step).ceilToDouble() * step;
        final ticks = ((niceMax - niceMin) / step).round();
        if (ticks < minTicks || ticks > maxTicks) continue;
        if (melhorTopo == null || niceMax < melhorTopo) {
          melhorTopo = niceMax;
          melhorPasso = step;
        }
      }
    }

    // Nenhum candidato coube na faixa de marcas (série muito plana): cai no
    // arredondamento simples, que sempre produz um passo válido.
    return melhorPasso ?? _niceStep(span / targetTicks);
  }

  static double _niceStep(double rough) {
    if (rough <= 0) return 1;
    final magnitude = math
        .pow(10, (math.log(rough) / math.ln10).floor())
        .toDouble();
    final normalized = rough / magnitude;
    final factor = normalized <= 1
        ? 1.0
        : normalized <= 2
        ? 2.0
        : normalized <= 2.5
        ? 2.5
        : normalized <= 5
        ? 5.0
        : 10.0;
    return factor * magnitude;
  }
}

/// Formata um valor de eixo sem casas supérfluas: `1200` e não `1200.0`,
/// `2,5` e não `2.5000001`.
String formatAxisValue(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  final oneDecimal = v.toStringAsFixed(1);
  return oneDecimal.replaceAll('.', ',');
}
