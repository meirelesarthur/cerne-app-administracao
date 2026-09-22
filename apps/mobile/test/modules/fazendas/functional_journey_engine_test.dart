import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';

/// Preenche todos os campos escalares da funcionalidade com um valor válido
/// para o tipo — o motor de etapas só precisa de dado plausível, não de
/// domínio real, e preencher tudo evita depender da lista exata de
/// obrigatórios (que muda com `required_if`).
void _preencherTudo(
  FunctionalJourneyController controller,
  FeatureDefinition feature,
) {
  for (final field in feature.fields) {
    controller.setValue(
      field.id,
      field.options.isNotEmpty
          ? field.options.first
          : switch (field.type) {
              FeatureFieldType.number ||
              FeatureFieldType.integer => '1',
              FeatureFieldType.date => '2026-08-16',
              _ => 'Dado de teste',
            },
    );
  }
}

void main() {
  test('consulta-produtos: cultivo/NCM são required_if grupo = Produção', () {
    final feature = featureById('consulta-produtos')!;
    final cultivo = feature.fields.firstWhere(
      (field) => field.id == 'cultivation-uuid',
    );
    final ncm = feature.fields.firstWhere((field) => field.id == 'ncm-uuid');

    // Grupo diferente de Produção: opcionais (sem asterisco, sem erro).
    const outroGrupo = {'group-uuid': 'Insumo agropecuário'};
    expect(isFeatureFieldRequired(feature, cultivo, outroGrupo), isFalse);
    expect(featureFieldError(feature, cultivo, outroGrupo), isNull);

    // Grupo = Produção: os dois viram obrigatórios.
    const producao = {'group-uuid': 'Produção'};
    expect(isFeatureFieldRequired(feature, cultivo, producao), isTrue);
    expect(isFeatureFieldRequired(feature, ncm, producao), isTrue);
    expect(
      featureFieldError(feature, cultivo, producao),
      'Selecione o cultivo (lavoura).',
    );
    expect(featureFieldError(feature, ncm, producao), 'Selecione o NCM.');
    // Preenchido, não erra.
    expect(
      featureFieldError(feature, cultivo, const {
        'group-uuid': 'Produção',
        'cultivation-uuid': 'Soja 2025/2026 — Talhão 01',
      }),
      isNull,
    );
  });


  // fidelidade-campos (onda 0): motor de etapas. `consulta-produtos` é o
  // único cadastro em etapas que sobrou no CERNE ADM — os formulários de
  // campo vivem no app irmão.
  test('formulário em etapas valida etapa a etapa e só salva na última', () {
    final feature = featureById('consulta-produtos')!;
    final controller = FunctionalJourneyController(feature)..startForm();

    expect(controller.hasSteps, isTrue);
    expect(controller.stepCount, 5);
    expect(controller.currentStep?.title, 'Dados básicos');

    // Etapa incompleta não avança — e não deixa o erro para o fim.
    expect(controller.advanceStep(), isFalse);
    expect(controller.stepIndex, 0);
    expect(controller.form.attempted, isTrue);

    _preencherTudo(controller, feature);

    while (!controller.isLastStep) {
      final anterior = controller.stepIndex;
      expect(controller.advanceStep(), isTrue, reason: 'etapa $anterior');
      expect(controller.stepIndex, anterior + 1);
      // Avançar limpa o "já tentei": a etapa nova começa sem erro em vermelho.
      expect(controller.form.attempted, isFalse);
    }

    expect(isFeatureReviewStep(feature, controller.stepIndex), isTrue);
    expect(controller.advanceStep(), isFalse);

    final salvo = controller.submit();
    expect(salvo?.title, 'Dado de teste');
    expect(controller.mode, FunctionalJourneyMode.success);

    controller.showList();
    expect(controller.mode, FunctionalJourneyMode.list);
  });

  test('voltar uma etapa preserva o preenchido e apaga os erros', () {
    final feature = featureById('consulta-produtos')!;
    final controller = FunctionalJourneyController(feature)..startForm();
    _preencherTudo(controller, feature);

    expect(controller.advanceStep(), isTrue);
    expect(controller.retreatStep(), isTrue);
    expect(controller.stepIndex, 0);
    expect(controller.form.values['nome-produto'], 'Dado de teste');
    expect(controller.form.attempted, isFalse);
    expect(controller.retreatStep(), isFalse);
  });
}
