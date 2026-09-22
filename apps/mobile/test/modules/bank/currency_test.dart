import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/bank/lib/currency.dart';

void main() {
  group('formatBRL', () {
    test('formata valores com milhar e centavos no padrão BRL', () {
      expect(formatBRL(128450.32), 'R\$ 128.450,32');
      expect(formatBRL(0), 'R\$ 0,00');
      expect(formatBRL(1200), 'R\$ 1.200,00');
    });

    test('valores não finitos caem para zero', () {
      expect(formatBRL(double.nan), 'R\$ 0,00');
      expect(formatBRL(double.infinity), 'R\$ 0,00');
    });
  });

  group('parseReais', () {
    test('aceita vírgula como separador decimal', () {
      expect(parseReais('1.234,56'), 1234.56);
      expect(parseReais('0,50'), 0.5);
    });

    test('texto inválido ou vazio resulta em zero', () {
      expect(parseReais(''), 0);
      expect(parseReais('abc'), 0);
    });
  });
}
