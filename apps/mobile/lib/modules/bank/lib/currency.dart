/// Formatação monetária BRL para os fluxos de pagamento do Bank.
/// Entrada é o valor em reais (double); saída no padrão "R$ 1.234,56".
/// Espelha `src/modules/bank/lib/currency.ts`. Implementação manual (sem
/// `package:intl`, indisponível neste app — ver `pubspec.yaml`, que não deve
/// ser editado por esta tarefa) mas com o mesmo resultado visual do `Intl.NumberFormat`.
String formatBRL(double reais) {
  final value = reais.isFinite ? reais : 0.0;
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final integerPart = (cents ~/ 100).toString();
  final decimalPart = (cents % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var i = 0; i < integerPart.length; i++) {
    final posFromEnd = integerPart.length - i;
    buffer.write(integerPart[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }

  return 'R\$ ${negative ? '-' : ''}$buffer,$decimalPart';
}

/// Converte o texto digitado (aceita vírgula ou ponto) em número de reais.
double parseReais(String input) {
  final normalized = input
      .replaceAll('.', '')
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.]'), '');
  final n = double.tryParse(normalized);
  return n != null && n.isFinite ? n : 0;
}
