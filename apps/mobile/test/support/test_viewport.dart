import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aumenta a superfície de teste para caber telas inteiras de módulo (`ListView`
/// com várias seções). Sem isso, `RenderSliverList` não constrói nem permite
/// hit-test em itens fora do viewport padrão de teste (800x600), fazendo
/// `find.text`/`tester.tap` falharem para conteúdo "abaixo da dobra".
Future<void> setTallSurface(WidgetTester tester, {double height = 3000}) async {
  await tester.binding.setSurfaceSize(Size(800, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
