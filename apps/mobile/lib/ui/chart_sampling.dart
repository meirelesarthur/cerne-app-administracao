/// Índices uniformemente distribuídos para manter gráficos legíveis com séries
/// longas sem descartar as extremidades (o primeiro e o último ponto).
///
/// A amostragem acontece antes do `CustomPainter`, então o custo de layout e
/// pintura permanece limitado mesmo quando a API devolver milhares de pontos.
List<int> sampleChartIndexes(int length, int maxPoints) {
  if (length <= 0) return const [];
  if (length <= maxPoints) return List<int>.generate(length, (i) => i);
  if (maxPoints <= 1) return [0];

  return List<int>.generate(
    maxPoints,
    (i) => (i * (length - 1) / (maxPoints - 1)).round(),
  );
}
