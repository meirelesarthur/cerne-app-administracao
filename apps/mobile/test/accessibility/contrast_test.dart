import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme_extension.dart';

/// Trava o contraste WCAG 2.x dos pares semânticos nos dois temas. Uma cor
/// nova em `design/tokens.ts` que derrube um par abaixo do mínimo quebra aqui,
/// antes de chegar a uma tela.
///
/// Mínimos: 4,5:1 para texto de corpo (1.4.3) e 3:1 para rótulos de gráfico
/// e marcas gráficas (1.4.11). Cores translúcidas são compostas sobre o fundo
/// antes do cálculo — é o que o olho vê.
Color _over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

double _ratio(Color fg, Color bg) {
  final a = _over(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final hi = a > b ? a : b;
  final lo = a > b ? b : a;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const themes = {
    'claro': AppSemanticColors.light,
    'escuro (gbMode)': AppSemanticColors.gbMode,
  };

  for (final MapEntry(key: nome, value: s) in themes.entries) {
    group('Contraste — tema $nome', () {
      final fundos = {
        'surface': s.bgSurface,
        'canvas': s.bgCanvas,
        'sheet': s.bgSheet,
      };

      final textos = {
        'fgDefault': s.fgDefault,
        'fgHeading': s.fgHeading,
        'fgSection': s.fgSection,
        'fgMuted': s.fgMuted,
        'fgSecondary': s.fgSecondary,
        'fgSubtle': s.fgSubtle,
        'fgQuiet': s.fgQuiet,
        'accentDefault': s.accentDefault,
      };

      for (final t in textos.entries) {
        for (final f in fundos.entries) {
          test('${t.key} sobre ${f.key} ≥ 4,5:1', () {
            expect(_ratio(t.value, f.value), greaterThanOrEqualTo(4.5));
          });
        }
      }

      // Placeholder é exemplo, não conteúdo: o valor canônico do app
      // Operação fica em ~4,3:1 no campo cinza. Piso de 4:1 aqui para não
      // regredir; subir para 4,5 é decisão conjunta dos dois apps.
      test('placeholder sobre os preenchimentos de campo ≥ 4:1', () {
        expect(
          _ratio(s.fgPlaceholder, s.fieldOnSurface),
          greaterThanOrEqualTo(4),
        );
        expect(
          _ratio(s.fgPlaceholder, s.fieldOnCanvas),
          greaterThanOrEqualTo(4),
        );
      });

      test('texto do CTA sobre o CTA ≥ 4,5:1', () {
        expect(_ratio(s.ctaFg, s.ctaBg), greaterThanOrEqualTo(4.5));
      });

      test('eixo de gráfico sobre surface ≥ 4,5:1', () {
        expect(_ratio(s.chartAxis, s.bgSurface), greaterThanOrEqualTo(4.5));
      });

      test('cada série de gráfico sobre surface ≥ 3:1', () {
        for (final (i, cor) in s.chartSeries.indexed) {
          expect(
            _ratio(cor, s.bgSurface),
            greaterThanOrEqualTo(3),
            reason: 'série $i',
          );
        }
      });

      final tons = {
        'brand': (s.toneBrandFg, s.toneBrandBg),
        'blue': (s.toneBlueFg, s.toneBlueBg),
        'amber': (s.toneAmberFg, s.toneAmberBg),
        'red': (s.toneRedFg, s.toneRedBg),
        'neutral': (s.toneNeutralFg, s.toneNeutralBg),
      };
      for (final st in tons.entries) {
        test('tom ${st.key}: texto sobre o fundo suave e sobre surface', () {
          final (fg, bg) = st.value;
          final chip = _over(bg, s.bgSurface);
          expect(_ratio(fg, chip), greaterThanOrEqualTo(4.5));
          expect(_ratio(fg, s.bgSurface), greaterThanOrEqualTo(4.5));
        });
      }
    });
  }
}
