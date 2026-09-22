import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';

Widget _wrap(Widget child, {AppThemeVariant variant = AppThemeVariant.light}) =>
    MaterialApp(
      theme: buildAppTheme(variant),
      home: Scaffold(body: Center(child: child)),
    );

HugeIcon _rendered(WidgetTester tester) =>
    tester.widget<HugeIcon>(find.byType(HugeIcon));

void main() {
  group('AppIcon', () {
    testWidgets('aplica o traço 1.2 do token a todo ícone', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.tractor)));

      expect(_rendered(tester).strokeWidth, AppSize.iconStroke);
      expect(AppSize.iconStroke, 1.2);
    });

    testWidgets('cai em 24 px quando nada define tamanho', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.wallet)));

      expect(_rendered(tester).size, AppSize.iconLg);
    });

    testWidgets('herda tamanho e cor do IconTheme do contexto', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const IconTheme(
            data: IconThemeData(size: AppSize.iconXs, color: Color(0xFFAA0000)),
            child: AppIcon(AppIcons.bell),
          ),
        ),
      );

      final icon = _rendered(tester);
      expect(icon.size, AppSize.iconXs);
      expect(icon.color, const Color(0xFFAA0000));
    });

    testWidgets('parâmetros explícitos vencem o IconTheme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const IconTheme(
            data: IconThemeData(size: AppSize.iconXs, color: Color(0xFFAA0000)),
            child: AppIcon(
              AppIcons.bell,
              size: AppSize.iconXl,
              color: Color(0xFF00AA00),
            ),
          ),
        ),
      );

      final icon = _rendered(tester);
      expect(icon.size, AppSize.iconXl);
      expect(icon.color, const Color(0xFF00AA00));
    });

    testWidgets('sem rótulo o ícone permanece decorativo', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.tractor)));

      expect(find.bySemanticsLabel('Trator'), findsNothing);
    });

    testWidgets('semanticLabel chega ao leitor de tela', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(AppIcons.tractor, semanticLabel: 'Trator')),
      );

      expect(find.bySemanticsLabel('Trator'), findsOneWidget);
    });

    testWidgets('renderiza nos dois temas sem exceções', (tester) async {
      for (final variant in AppThemeVariant.values) {
        await tester.pumpWidget(
          _wrap(const AppIcon(AppIcons.confinamento), variant: variant),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('ocupa exatamente a caixa do tamanho pedido', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(AppIcons.barns, size: AppSize.iconMd)),
      );

      expect(
        tester.getSize(find.byType(HugeIcon)),
        const Size(AppSize.iconMd, AppSize.iconMd),
      );
    });

    testWidgets('sem cor explícita, pinta como `Icon` pintaria', (
      tester,
    ) async {
      // O contrato que a migração precisa preservar: onde antes havia
      // `Icon(LucideIcons.x)` herdando a cor do tema, `AppIcon` herda a mesma.
      late Color themeIconColor;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(AppThemeVariant.light),
          home: Builder(
            builder: (context) {
              themeIconColor = IconTheme.of(context).color!;
              return const Scaffold(body: AppIcon(AppIcons.wallet));
            },
          ),
        ),
      );

      expect(_rendered(tester).color, themeIconColor);
    });
  });

  group('AppIcons — catálogo', () {
    test('apelidos de domínio apontam para entradas reais do catálogo', () {
      const aliases = <String, AppIconData>{
        'confinamento': AppIcons.confinamento,
        'pecuaria': AppIcons.pecuaria,
        'agricultura': AppIcons.agricultura,
        'ordemServico': AppIcons.ordemServico,
        'misturador': AppIcons.misturador,
        'reproducao': AppIcons.reproducao,
        'consultas': AppIcons.consultas,
        'gestaoFrota': AppIcons.gestaoFrota,
        'sincronizar': AppIcons.sincronizar,
        'fazenda': AppIcons.fazenda,
        'estoque': AppIcons.estoque,
        'marketplace': AppIcons.marketplace,
        'openFinance': AppIcons.openFinance,
        'banking': AppIcons.banking,
      };

      for (final entry in aliases.entries) {
        final icon = entry.value;
        expect(
          icon.glyph != null || icon.asset != null,
          isTrue,
          reason: 'AppIcons.${entry.key} não aponta para desenho nenhum',
        );
        expect(
          icon.glyph,
          anyOf(isNull, isNotEmpty),
          reason: 'AppIcons.${entry.key} tem glifo vazio',
        );
      }
    });

    test('os ícones nomeados pelo Figma são os do Figma', () {
      // Nomes de camada lidos do nó 54300-2458 — ver §3.4 da esteira.
      expect(AppIcons.barns.glyph, HugeIcons.strokeRoundedBarns);
      expect(AppIcons.tractor.glyph, HugeIcons.strokeRoundedTractor);
      expect(AppIcons.scanHeart.glyph, HugeIcons.strokeRoundedScanHeart);
      expect(AppIcons.bookSearch.glyph, HugeIcons.strokeRoundedBookSearch);
      expect(AppIcons.landmark.glyph, HugeIcons.strokeRoundedBank);
      expect(AppIcons.eyeOff.glyph, HugeIcons.strokeRoundedViewOff);
      expect(AppIcons.aiSearch.glyph, HugeIcons.strokeRoundedAiSearch02);
      expect(AppIcons.filter.glyph, HugeIcons.strokeRoundedFilterHorizontal);
      expect(AppIcons.arrowRight.glyph, HugeIcons.strokeRoundedArrowRight01);
      expect(AppIcons.store02.glyph, HugeIcons.strokeRoundedStore02);
      expect(AppIcons.connect.glyph, HugeIcons.strokeRoundedConnect);
      expect(AppIcons.cash.glyph, HugeIcons.strokeRoundedCash02);
      expect(
        AppIcons.creditCardAccept.glyph,
        HugeIcons.strokeRoundedCreditCardAccept,
      );
    });

    test('os dois ícones agro vêm dos vetores autorais, não do set', () {
      // Não há bovino no Hugeicons gratuito — §3.3 da esteira. Se alguém trocar
      // estes por um equivalente do set, o desenho da marca some sem aviso.
      expect(AppIcons.confinamento.asset, 'assets/icons/confinamento.svg');
      expect(AppIcons.pecuaria.asset, 'assets/icons/pecuaria.svg');
      expect(AppIcons.confinamento.glyph, isNull);
      expect(AppIcons.pecuaria.glyph, isNull);
    });

    test('o traço dos vetores autorais é o traço do sistema', () async {
      // O desenho vive num viewBox de 34 de largura e é encaixado numa caixa de
      // 24: a espessura na fonte precisa ser 1.2 × 34/24 = 1.7 para cair em 1.2
      // na tela. Este teste guarda a conta — reexportar o SVG do Figma sem
      // renormalizar deixaria o ícone mais fino que todo o resto do app.
      const esperado = 1.2 * 34 / 24;
      final svg = await File(AppIcons.confinamento.asset!).readAsString();
      final larguras = RegExp(
        r'stroke-width="([\d.]+)"',
      ).allMatches(svg).map((m) => double.parse(m.group(1)!)).toSet();

      expect(larguras, isNotEmpty, reason: 'o SVG perdeu os traços');
      for (final largura in larguras) {
        expect(largura, closeTo(esperado, 0.001));
      }
    });

    test('pecuária é contorno vetorizado, e não traço', () async {
      // Registro executável de uma limitação real (§6-C da esteira): o arquivo
      // enviado não tem traço nenhum — a espessura está embutida na geometria e
      // não acompanha `AppSize.iconStroke`. Se um dia vier uma versão traçada,
      // este teste falha e avisa que a ressalva pode sair da documentação.
      final svg = await File(AppIcons.pecuaria.asset!).readAsString();

      expect(svg.contains('stroke-width'), isFalse);
    });

    test('o set de origem é stroke-rounded, e não sólido', () {
      // Um ícone sólido não teria atributo de traço para sobrescrever — é o que
      // torna o 1.2 possível. Guarda contra troca silenciosa de estilo.
      final attributes = AppIcons.tractor.glyph!
          .map((element) => element[1] as Map<String, dynamic>)
          .toList();

      expect(
        attributes.any((a) => a.containsKey('strokeWidth')),
        isTrue,
        reason: 'ícone sem strokeWidth: o override de 1.2 não teria efeito',
      );
    });

    test(
      'ícones de navegação distintos não colidem por identidade',
      () {
        // banco-real (correção de identidade): `chevronLeft`/`chevronRight`
        // reaproveitavam o mesmo glifo 01 de `arrowLeft`/`arrowRight` — como
        // os dois são `const AppIconData.glyph(...)` com o mesmo argumento,
        // Dart canoniza os dois literais no mesmo objeto, e
        // `find.byWidgetPredicate` por `identical(...)`
        // (`test/helpers/app_icon_finder.dart`) via `findAppIcon` passava a
        // casar os dois ao mesmo tempo — uma tela com o botão Voltar
        // (`arrowLeft`) e uma paginação (`chevronLeft`) juntos quebrava
        // `getRect`/`tap` por ambiguidade. Guarda para o par não colidir de
        // novo silenciosamente.
        expect(identical(AppIcons.arrowLeft, AppIcons.chevronLeft), isFalse);
        expect(identical(AppIcons.arrowRight, AppIcons.chevronRight), isFalse);
      },
    );
  });
}
