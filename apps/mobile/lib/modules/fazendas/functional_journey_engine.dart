import 'functional_catalog.dart';
import 'state/prototype_records_store.dart';

enum FunctionalJourneyMode { list, form, success }

class FunctionalJourneyController {
  FunctionalJourneyController(this.feature);

  final FeatureDefinition feature;
  FunctionalJourneyMode mode = FunctionalJourneyMode.list;
  FunctionalFormState form = const FunctionalFormState();

  /// Etapa atual quando a funcionalidade declara [FeatureDefinition.steps].
  /// Sem etapas declaradas fica sempre em zero e o formulário é de rolagem
  /// única — comportamento anterior à onda 0 da esteira de fidelidade.
  int stepIndex = 0;

  bool get hasSteps => feature.steps.isNotEmpty;

  int get stepCount => hasSteps ? feature.steps.length : 1;

  FeatureFormStep? get currentStep =>
      hasSteps ? feature.steps[stepIndex.clamp(0, stepCount - 1)] : null;

  bool get isFirstStep => stepIndex <= 0;

  bool get isLastStep => stepIndex >= stepCount - 1;

  /// Id do registro em edição — `null` quando o formulário está criando um
  /// registro novo. [submit] usa isto para decidir entre `addRecord` e
  /// `updateRecord`, e a tela para trocar "Salvar registro" por "Salvar
  /// alterações".
  String? editingRecordId;

  void startForm() {
    mode = FunctionalJourneyMode.form;
    // Datas de lançamento já vêm com hoje: quase sempre é o registro do
    // próprio dia, e digitar data é o passo mais lento do formulário.
    form = FunctionalFormState(
      values: {
        for (final field in feature.fields)
          if (field.type == FeatureFieldType.date &&
              _datasDoDia.contains(field.label))
            field.id: hojeFormatado(),
      },
    );
    stepIndex = 0;
    editingRecordId = null;
  }

  /// Hoje em `DD/MM/AAAA` — mesmo formato de `hojeFormatado()` do app
  /// Operação (`cadastros_vinculados.dart`, que não existe neste app).
  static String hojeFormatado() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  /// Rótulos de data que registram algo que aconteceu agora. Datas de
  /// nascimento, previsão, início/término e formação ficam em branco — hoje
  /// seria um chute errado.
  static const _datasDoDia = {
    'Data',
    'Data do manejo',
    'Data do lançamento',
    'Data de entrada',
    'Data do diagnóstico',
    'Data da transferência',
    'Data da ocorrência',
    'Data da marcação',
    'Data da desmama',
    'Data da batida',
  };

  /// Reabre o formulário preenchido com os valores de [record], para o
  /// perfil operacional corrigir um registro já gravado — a mesma tela de
  /// cadastro, agora em modo de edição.
  ///
  /// `record.details` é achatado por rótulo ([PrototypeRecord.details]); a
  /// tradução de volta para `fieldId` usa [FeatureDefinition.fields]. Campos
  /// de coleção não fazem parte deste mapa (ver `buildPrototypeRecordDraft`)
  /// e por isso não são reconstituídos aqui — a pessoa os refaz ao editar,
  /// como já acontece em qualquer campo opcional não respondido.
  void startEditing(PrototypeRecord record) {
    final idByLabel = {
      for (final field in feature.fields) field.label: field.id,
    };
    final values = <String, String>{
      for (final entry in record.details.entries)
        ?idByLabel[entry.key]: entry.value,
    };
    mode = FunctionalJourneyMode.form;
    form = FunctionalFormState(values: values);
    stepIndex = 0;
    editingRecordId = record.id;
  }

  void setValue(String fieldId, String value) {
    form = form.setValue(fieldId, value);
  }

  /// Acrescenta um item à coleção. Sem [item], entra um item vazio — é o
  /// comportamento de contador das coleções que ainda não declaram campos.
  void addGroupItem(String group, [Map<String, String> item = const {}]) {
    form = form.addGroupItem(group, item);
  }

  void removeGroupItem(String group, int index) {
    form = form.removeGroupItem(group, index);
  }

  void updateGroupItem(String group, int index, Map<String, String> item) {
    form = form.updateGroupItem(group, index, item);
  }

  /// Avança uma etapa. Devolve `false` quando a etapa atual tem pendência —
  /// a tela mostra os erros e não sai do lugar. Na última etapa não avança:
  /// quem conclui o fluxo é [submit].
  bool advanceStep() {
    if (!hasSteps || isLastStep) return false;
    form = form.markAttempted();
    if (!isFeatureStepValid(feature, form, stepIndex)) return false;
    stepIndex += 1;
    form = form.clearAttempted();
    return true;
  }

  bool retreatStep() {
    if (!hasSteps || isFirstStep) return false;
    stepIndex -= 1;
    form = form.clearAttempted();
    return true;
  }

  PrototypeRecordDraft? submit() {
    form = form.markAttempted();
    if (!isFeatureFormValid(feature, form)) {
      // Formulário em etapas: volta para a primeira etapa com pendência, para
      // que o erro apareça na tela em que a pessoa consegue corrigi-lo.
      if (hasSteps) {
        for (var index = 0; index < stepCount; index++) {
          if (!isFeatureStepValid(feature, form, index)) {
            stepIndex = index;
            break;
          }
        }
      }
      return null;
    }
    mode = FunctionalJourneyMode.success;
    return buildPrototypeRecordDraft(feature, form);
  }

  void showList() {
    mode = FunctionalJourneyMode.list;
    stepIndex = 0;
  }
}

class FunctionalFormState {
  const FunctionalFormState({
    this.values = const {},
    this.groupItems = const {},
    this.attempted = false,
  });

  final Map<String, String> values;

  /// Itens de cada coleção, na ordem em que foram adicionados. Cada item é um
  /// mapa `id do campo → valor`. Até a onda 8 aqui havia só uma contagem: a
  /// coleção existia na tela mas não guardava o que continha.
  final Map<String, List<Map<String, String>>> groupItems;

  final bool attempted;

  /// Quantos itens por coleção — a leitura que o resto do app já fazia.
  Map<String, int> get groupCounts => {
    for (final entry in groupItems.entries) entry.key: entry.value.length,
  };

  List<Map<String, String>> itemsOf(String group) =>
      groupItems[group] ?? const [];

  FunctionalFormState setValue(String fieldId, String value) =>
      FunctionalFormState(
        values: {...values, fieldId: value},
        groupItems: groupItems,
        attempted: attempted,
      );

  FunctionalFormState addGroupItem(
    String group, [
    Map<String, String> item = const {},
  ]) => FunctionalFormState(
    values: values,
    groupItems: {
      ...groupItems,
      group: [...itemsOf(group), item],
    },
    attempted: attempted,
  );

  FunctionalFormState removeGroupItem(String group, int index) {
    final atuais = [...itemsOf(group)];
    if (index < 0 || index >= atuais.length) return this;
    atuais.removeAt(index);
    return FunctionalFormState(
      values: values,
      groupItems: {...groupItems, group: atuais},
      attempted: attempted,
    );
  }

  FunctionalFormState updateGroupItem(
    String group,
    int index,
    Map<String, String> item,
  ) {
    final atuais = [...itemsOf(group)];
    if (index < 0 || index >= atuais.length) return this;
    atuais[index] = item;
    return FunctionalFormState(
      values: values,
      groupItems: {...groupItems, group: atuais},
      attempted: attempted,
    );
  }

  FunctionalFormState markAttempted() => FunctionalFormState(
    values: values,
    groupItems: groupItems,
    attempted: true,
  );

  FunctionalFormState clearAttempted() =>
      FunctionalFormState(values: values, groupItems: groupItems);
}

/// Campos de uma etapa, na ordem declarada. Campos citados na etapa que não
/// existem em [FeatureDefinition.fields] são ignorados (a invariante de
/// catálogo cobre esse caso em teste).
List<FeatureField> featureStepFields(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return feature.fields;
  final step = feature.steps[index.clamp(0, feature.steps.length - 1)];
  final byId = {for (final field in feature.fields) field.id: field};
  return [for (final id in step.fields) ?byId[id]];
}

/// Coleções de uma etapa. Sem etapas declaradas, todas as coleções da
/// funcionalidade aparecem juntas, como antes.
List<String> featureStepSections(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return feature.sections;
  final step = feature.steps[index.clamp(0, feature.steps.length - 1)];
  return [
    for (final section in step.sections)
      if (feature.sections.contains(section)) section,
  ];
}

/// A etapa sem campos e sem coleções é a revisão do que foi preenchido.
bool isFeatureReviewStep(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return false;
  return featureStepFields(feature, index).isEmpty &&
      featureStepSections(feature, index).isEmpty;
}

/// Obrigatoriedade efetiva do campo. Sai de [FeatureField.isRequired] na
/// maioria dos casos, mas o contrato real também tem obrigatoriedade
/// condicional — em `/pastures` o destino é `area_uuid` XOR `grazing_uuid`, e
/// qual dos dois é exigido depende da escolha em `destino`. A tela usa isto
/// para o asterisco, e [featureFieldError] para a mensagem.
bool isFeatureFieldRequired(
  FeatureDefinition feature,
  FeatureField field,
  Map<String, String> values,
) {
  if (field.isRequired) return true;
  if (feature.id == 'pastagens') {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area') return destino == 'Área';
    if (field.id == 'piquete') return destino == 'Piquete';
  }
  // fidelidade-contrato (onda 6): `/batch-module-area-transfers` exige
  // **exatamente um** destino — área, módulo ou curral — nunca dois fixos
  // como o catálogo obrigava antes desta onda. Mesmo padrão do XOR acima.
  if (feature.id == 'transferencia-lote-area') {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area') return destino == 'Área';
    if (field.id == 'modulo') return destino == 'Módulo';
    if (field.id == 'curral') return destino == 'Curral';
  }
  // fidelidade-contrato (onda 6): `/breeding-matings` liga a obrigatoriedade
  // de estação/material/protocolo ao par `type`/`launch_type` — hoje o
  // catálogo trata os quatro como sempre opcionais. Modelagem mínima: um
  // acasalamento por protocolo exige o protocolo; um lançamento por lote
  // (não por animal) exige o material reprodutivo usado no lote inteiro.
  if (feature.id == 'monta-natural') {
    final tipo = values['tipo']?.trim() ?? '';
    final tipoLancamento = values['tipo-lancamento']?.trim() ?? '';
    // fidelidade-contrato (re-auditoria 3ª avaliação): BreedingMatingRequest
    // amarra a obrigatoriedade ao par type/launch_type. Interpretação do
    // launch_type no app: 'Por lote' ≈ Normal, 'Animal por animal' ≈
    // Simplificado (BreedingMatingLaunchType). breeding_season_uuid é required
    // fora do Simplificado; protocol_uuid/protocol_identification quando não
    // é natural e é Normal.
    // type: 1=Monta natural, 2=IATF, 3=FIV; launch_type: 1=Normal(Por lote),
    // 2=Simplificado(Animal por animal) — backing int do contrato.
    final normal = tipoLancamento == '1';
    final naoNatural = tipo != '1';
    if (field.id == 'estacao-monta') return normal;
    if (field.id == 'protocolo') return naoNatural && normal;
    if (field.id == 'identificacao-protocolo') return naoNatural && normal;
    if (field.id == 'material-reprodutivo') return normal;
    // breeding_batch_uuid (lote) e bull_seed_season_uuid: nullable no
    // Simplificado, required no Normal.
    if (field.id == 'lote') return normal;
    if (field.id == 'bull-seed-season') return normal;
  }
  // fidelidade-esteira (onda 13): `same_batch` decide entre um destino único
  // (`novo-lote` de cabeçalho, aqui) ou um destino por animal (`novo-lote`
  // dentro de cada item de "Animais transferidos",
  // [isCollectionItemFieldRequired] abaixo) — nunca os dois.
  if (feature.id == 'transferencia-animal' && field.id == 'novo-lote') {
    return (values['destino-unico']?.trim() ?? '') == 'true';
  }
  // fidelidade-contrato (re-auditoria 3ª avaliação): `ProductRequest` torna
  // `cultivation_uuid`/`ncm_uuid` obrigatórios via `required_if` quando o
  // grupo é "Produção" (`GroupProduct::PRODUCTION_GROUP_ID`). O gate vive no
  // grupo escolhido, não num asterisco fixo.
  if (feature.id == 'consulta-produtos' &&
      (field.id == 'cultivation-uuid' || field.id == 'ncm-uuid')) {
    return (values['group-uuid']?.trim() ?? '') == 'Produção';
  }
  return false;
}

/// Mesma obrigatoriedade condicional de [isFeatureFieldRequired], mas para um
/// campo de **item de coleção** — os poucos casos em que a exigência de um
/// campo do item depende de outro campo do mesmo item, não de um campo do
/// cabeçalho. Sem `feature`/`collection` para identificar o caso, um
/// `featureItemFieldError` genérico não teria como saber disso.
bool isCollectionItemFieldRequired(
  FeatureDefinition feature,
  FeatureCollection collection,
  FeatureField field,
  Map<String, String> values, [
  Map<String, String> formValues = const {},
]) {
  if (field.isRequired) return true;
  // fidelidade-contrato (onda 6): `pastagens."Serviços"` — o executor é
  // `employee`/`function`/`provider` no contrato; "Função" já é a resposta
  // (o tipo de mão de obra), então só "Empregado"/"Prestador" pedem a
  // pessoa. Mesma ideia de `sanitario.labor`, mas aqui é XOR de fato: o
  // contrato não aceita os dois de uma vez.
  if (feature.id == 'pastagens' && collection.name == 'Serviços') {
    final tipoExecutor = values['tipo-executor']?.trim() ?? '';
    if (field.id == 'executor') {
      return tipoExecutor == 'Empregado' || tipoExecutor == 'Prestador';
    }
  }
  // fidelidade-contrato (onda 6): `protocolos-estacao."Etapas do
  // protocolo"` — o item é produto **ou** serviço, nunca os dois; `tipo`
  // decide qual dos dois campos vira obrigatório.
  if (feature.id == 'protocolos-estacao' &&
      collection.name == 'Etapas do protocolo') {
    final tipoItem = values['tipo']?.trim() ?? '';
    if (field.id == 'produto') return tipoItem == 'Produto';
    if (field.id == 'servico') return tipoItem == 'Serviço';
    // measurement_uuid é required_with:product_uuid — só a linha de Produto
    // exige a unidade.
    if (field.id == 'unidade') return tipoItem == 'Produto';
  }
  // fidelidade-esteira (onda 13): `transferencia-animal."Animais
  // transferidos"` — diferente dos dois casos acima, o XOR aqui depende de
  // um campo do **cabeçalho** (`destino-unico`), não de outro campo do
  // próprio item; por isso o parâmetro extra `formValues`.
  if (feature.id == 'transferencia-animal' &&
      collection.name == 'Animais transferidos' &&
      field.id == 'novo-lote') {
    return (formValues['destino-unico']?.trim() ?? '') == 'false';
  }
  // fidelidade-contrato (re-auditoria pós-fix): em `/maintenances` o executor
  // vive DENTRO de `items.*` (coleção "Peças / Insumos"). `executor_type` é
  // nullable; quando informado, o alvo e o valor do tipo escolhido viram
  // obrigatórios: employee → executor + horas; provider → executor + total.
  if (feature.id == 'manutencao-frota' &&
      collection.name == 'Peças / Insumos') {
    final tipoExecutor = values['tipo-executor']?.trim() ?? '';
    if (field.id == 'executor') {
      return tipoExecutor == 'employee' || tipoExecutor == 'provider';
    }
    if (field.id == 'horas') return tipoExecutor == 'employee';
    if (field.id == 'total') return tipoExecutor == 'provider';
  }
  return false;
}

/// Mensagem de obrigatório com o nome do campo — "Campo obrigatório." não
/// dizia qual, e numa tela longa a pessoa não achava o que faltava.
String featureRequiredMessage(FeatureField field) => switch (field.type) {
  FeatureFieldType.select ||
  FeatureFieldType.searchSelect ||
  FeatureFieldType.color ||
  FeatureFieldType.boolean => 'Escolha uma opção em "${field.label}".',
  FeatureFieldType.date => 'Informe a data em "${field.label}".',
  _ => 'Preencha o campo "${field.label}".',
};

/// Validação que não depende do cadastro: obrigatoriedade e número positivo.
/// Serve tanto para o campo do formulário principal quanto para o campo de um
/// **item de coleção**, que não tem `FeatureDefinition` por trás.
String? featureItemFieldError(FeatureField field, Map<String, String> values) {
  final value = values[field.id]?.trim() ?? '';
  if (field.isRequired && value.isEmpty) return featureRequiredMessage(field);
  if (field.type == FeatureFieldType.number && value.isNotEmpty) {
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero.';
    }
  }
  if (field.type == FeatureFieldType.integer && value.isNotEmpty) {
    final inteiro = int.tryParse(value);
    if (inteiro == null || inteiro <= 0) {
      return 'Informe um número inteiro maior que zero.';
    }
  }
  return null;
}

/// O item de coleção só entra na lista quando seus obrigatórios estão de pé.
bool isCollectionItemValid(
  FeatureCollection collection,
  Map<String, String> values,
) => collection.fields.every(
  (field) => featureItemFieldError(field, values) == null,
);

/// Erro de um campo de **item de coleção**, com a mesma obrigatoriedade
/// condicional de [isCollectionItemFieldRequired] — para os poucos itens
/// (`pastagens."Serviços"`, `protocolos-estacao."Etapas do protocolo"`) cujo
/// XOR só existe dentro do próprio item, não do cabeçalho.
String? collectionItemFieldError(
  FeatureDefinition feature,
  FeatureCollection collection,
  FeatureField field,
  Map<String, String> values, [
  Map<String, String> formValues = const {},
]) {
  final value = values[field.id]?.trim() ?? '';
  if (isCollectionItemFieldRequired(
        feature,
        collection,
        field,
        values,
        formValues,
      ) &&
      value.isEmpty) {
    return featureRequiredMessage(field);
  }
  if (field.type == FeatureFieldType.number && value.isNotEmpty) {
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero.';
    }
  }
  if (field.type == FeatureFieldType.integer && value.isNotEmpty) {
    final inteiro = int.tryParse(value);
    if (inteiro == null || inteiro <= 0) {
      return 'Informe um número inteiro maior que zero.';
    }
  }
  return null;
}

/// Mesma ideia de [isCollectionItemValid], mas usando
/// [collectionItemFieldError] — para as duas coleções com XOR interno.
bool isCollectionItemValidFor(
  FeatureDefinition feature,
  FeatureCollection collection,
  Map<String, String> values, [
  Map<String, String> formValues = const {},
]) => collection.fields.every(
  (field) =>
      collectionItemFieldError(
        feature,
        collection,
        field,
        values,
        formValues,
      ) ==
      null,
);

/// Título da linha de um item já adicionado.
String collectionItemTitle(
  FeatureCollection collection,
  Map<String, String> item,
) {
  final id =
      collection.titleField ??
      (collection.fields.isEmpty ? null : collection.fields.first.id);
  final value = id == null ? '' : item[id]?.trim() ?? '';
  return value.isEmpty ? collection.itemLabel ?? collection.name : value;
}

/// Resumo da linha — os campos de [FeatureCollection.subtitleFields] que a
/// pessoa preencheu, na ordem declarada.
String? collectionItemSubtitle(
  FeatureCollection collection,
  Map<String, String> item,
) {
  final partes = [
    for (final id in collection.subtitleFields)
      if ((item[id]?.trim() ?? '').isNotEmpty) item[id]!.trim(),
  ];
  return partes.isEmpty ? null : partes.join(' · ');
}

String? featureFieldError(
  FeatureDefinition feature,
  FeatureField field,
  Map<String, String> values,
) {
  final generico = featureItemFieldError(field, values);
  if (generico != null) return generico;
  final value = values[field.id]?.trim() ?? '';
  if (feature.id == 'estacao-monta' &&
      field.id == 'fim' &&
      value.isNotEmpty &&
      (values['inicio']?.isNotEmpty ?? false) &&
      value.compareTo(values['inicio']!) < 0) {
    return 'A data final deve ser posterior à data inicial.';
  }
  // fidelidade-campos (onda 1): em `/pastures` o destino do manejo é um XOR —
  // `area_uuid` **ou** `grazing_uuid`, nunca os dois e nunca nenhum. Nenhum
  // dos dois pode ser `isRequired` no catálogo (senão os dois seriam sempre
  // exigidos); a obrigatoriedade nasce da escolha em `destino`.
  if (feature.id == 'pastagens' && value.isEmpty) {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area' && destino == 'Área') {
      return 'Selecione a área do manejo.';
    }
    if (field.id == 'piquete' && destino == 'Piquete') {
      return 'Selecione o piquete do manejo.';
    }
  }
  // fidelidade-contrato (onda 6): mesmo XOR de `pastagens.destino`, agora com
  // três destinos possíveis.
  if (feature.id == 'transferencia-lote-area' && value.isEmpty) {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area' && destino == 'Área') {
      return 'Selecione a nova área.';
    }
    if (field.id == 'modulo' && destino == 'Módulo') {
      return 'Selecione o novo módulo.';
    }
    if (field.id == 'curral' && destino == 'Curral') {
      return 'Selecione o curral de destino.';
    }
  }
  // fidelidade-contrato (onda 6): `/breeding-matings` — protocolo é exigido
  // quando o tipo é IATF; material reprodutivo é exigido quando o
  // lançamento é por lote inteiro (não por animal).
  if (feature.id == 'monta-natural' && value.isEmpty) {
    final tipo = values['tipo']?.trim() ?? '';
    final normal = (values['tipo-lancamento']?.trim() ?? '') == '1';
    final naoNatural = tipo != '1';
    if (field.id == 'estacao-monta' && normal) {
      return 'Selecione a estação de monta.';
    }
    if (field.id == 'protocolo' && naoNatural && normal) {
      return 'Selecione o protocolo da estação.';
    }
    if (field.id == 'identificacao-protocolo' && naoNatural && normal) {
      return 'Informe a identificação do protocolo.';
    }
    if (field.id == 'material-reprodutivo' && normal) {
      return 'Informe o material reprodutivo usado no lote.';
    }
    if (field.id == 'lote' && normal) {
      return 'Selecione o lote de matrizes.';
    }
    if (field.id == 'bull-seed-season' && normal) {
      return 'Selecione o touro / sêmen da estação.';
    }
  }
  // fidelidade-esteira (onda 13): mesmo XOR de cabeçalho × item descrito em
  // [isFeatureFieldRequired].
  if (feature.id == 'transferencia-animal' &&
      field.id == 'novo-lote' &&
      value.isEmpty &&
      (values['destino-unico']?.trim() ?? '') == 'true') {
    return 'Selecione o novo lote.';
  }
  // fidelidade-contrato (re-auditoria 3ª avaliação): `cultivation_uuid`/
  // `ncm_uuid` são `required_if` grupo = Produção no `ProductRequest`.
  if (feature.id == 'consulta-produtos' &&
      value.isEmpty &&
      (values['group-uuid']?.trim() ?? '') == 'Produção') {
    if (field.id == 'cultivation-uuid') return 'Selecione o cultivo (lavoura).';
    if (field.id == 'ncm-uuid') return 'Selecione o NCM.';
  }
  return null;
}

/// Seções obrigatórias efetivas: as estáticas ([FeatureDefinition.requiredSections])
/// mais as condicionais por-feature. Em `monta-natural` a coleção exigida
/// depende do par type/launch_type (natural.cow_uuids, simplified_animals,
/// protocol_animals) — mesma ideia condicional de [isFeatureFieldRequired],
/// mas para `min:1` de coleção.
List<String> effectiveRequiredSections(
  FeatureDefinition feature,
  Map<String, String> values,
) {
  final sections = [...feature.requiredSections];
  void req(String name) {
    if (!sections.contains(name)) sections.add(name);
  }

  if (feature.id == 'monta-natural') {
    final tipo = values['tipo']?.trim() ?? '';
    final normal = (values['tipo-lancamento']?.trim() ?? '') == '1';
    // type: 1=NATURAL; launch_type: 1=Normal, 2=Simplificado (backing int).
    // natural.cow_uuids min:1 quando type=NATURAL.
    if (tipo == '1') req('Vacas do acasalamento');
    // simplified_animals min:1 no Simplificado (Animal por animal).
    if (!normal) req('Animais (lançamento simplificado)');
    // protocol_animals min:1 no Protocolo Normal (por lote, não natural).
    if (normal && tipo != '1') req('Animais do protocolo');
  }
  return sections;
}

/// Pendência de coleção obrigatória (`min:1` no contrato real). Devolve a
/// primeira coleção vazia entre as seções obrigatórias efetivas.
String? featureCollectionError(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  for (final section in effectiveRequiredSections(feature, state.values)) {
    if ((state.groupCounts[section] ?? 0) < 1) {
      return 'Adicione ao menos um item em "$section".';
    }
  }
  return null;
}

bool isFeatureStepValid(
  FeatureDefinition feature,
  FunctionalFormState state,
  int index,
) {
  final fieldsValid = featureStepFields(
    feature,
    index,
  ).every((field) => featureFieldError(feature, field, state.values) == null);
  if (!fieldsValid) return false;
  final sections = featureStepSections(feature, index);
  for (final section in effectiveRequiredSections(feature, state.values)) {
    if (sections.contains(section) && (state.groupCounts[section] ?? 0) < 1) {
      return false;
    }
  }
  // A simulação de hardware vive na primeira etapa, junto do campo-alvo.
  if (index == 0 && featureSimulationError(feature, state) != null) {
    return false;
  }
  return true;
}

bool isFeatureFormValid(FeatureDefinition feature, FunctionalFormState state) {
  final fieldsValid = feature.fields.every(
    (field) => featureFieldError(feature, field, state.values) == null,
  );
  if (!fieldsValid) return false;
  if (featureCollectionError(feature, state) != null) return false;
  return featureSimulationError(feature, state) == null;
}

String? featureSimulationError(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  if (feature.simulation == null) return null;
  // fidelidade-esteira (onda 13): quando a captura empilha numa coleção
  // (`transferencia-animal`), "concluir a simulação" passa a ser "ter
  // capturado pelo menos um animal" — não mais um campo escalar preenchido.
  if (feature.simulationCollectionName case final collectionName?) {
    final count = state.groupCounts[collectionName] ?? 0;
    return count > 0 ? null : 'Capture ao menos um animal para continuar.';
  }
  final target = feature.simulationTargetField ?? '_hardware';
  if (state.values[target]?.trim().isNotEmpty ?? false) return null;
  return feature.simulationTargetField == null
      ? 'Conclua a simulação para continuar.'
      : 'Capture ou informe a identificação manualmente.';
}

PrototypeRecordDraft buildPrototypeRecordDraft(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  final labels = {for (final field in feature.fields) field.id: field.label};
  final details = <String, String>{
    for (final entry in state.values.entries)
      if (entry.value.trim().isNotEmpty)
        labels[entry.key] ?? entry.key: entry.value.trim(),
    // Onda 8: a coleção deixou de ser um número no detalhe do registro — o
    // resumo passa a citar o que foi lançado, que é o que a pessoa confere.
    for (final collection in feature.collections)
      if (state.itemsOf(collection.name).isNotEmpty)
        collection.name: _resumoColecao(
          collection,
          state.itemsOf(collection.name),
        ),
  };
  final fieldsById = {for (final field in feature.fields) field.id: field};
  final titleField = feature.recordTitleField ?? 'nome';
  final titleRaw = state.values[titleField]?.trim() ?? '';
  final titleFieldDef = fieldsById[titleField];
  final title = titleFieldDef == null
      ? titleRaw
      : featureFieldDisplay(titleFieldDef, titleRaw);
  final description = feature.recordDescriptionFields
      .map((id) {
        final raw = state.values[id]?.trim() ?? '';
        final field = fieldsById[id];
        return field == null ? raw : featureFieldDisplay(field, raw);
      })
      .where((value) => value.isNotEmpty)
      .join(' · ');

  return PrototypeRecordDraft(
    title: title.isNotEmpty ? title : feature.title,
    description: description.isEmpty ? 'Registro criado agora' : description,
    status: _statusFor(feature.id),
    details: details,
  );
}

String _resumoColecao(
  FeatureCollection collection,
  List<Map<String, String>> itens,
) {
  final contagem = '${itens.length} item(ns)';
  if (collection.fields.isEmpty) return contagem;
  final titulos = itens
      .map((item) => collectionItemTitle(collection, item))
      .toList(growable: false);
  return '$contagem · ${titulos.join(', ')}';
}

PrototypeRecordStatus _statusFor(String featureId) {
  const active = {
    'cadastrar-area',
    'formulacoes',
    'rebanho-inicial',
    'lote-animais',
    'registrar-animal',
    'material-reprodutivo',
    'configuracoes-misturador',
    'marcacao',
  };
  const scheduled = {'manutencao-frota', 'estacao-monta', 'protocolos-estacao'};
  if (scheduled.contains(featureId)) return PrototypeRecordStatus.scheduled;
  if (active.contains(featureId)) return PrototypeRecordStatus.active;
  return PrototypeRecordStatus.completed;
}

class PrototypeRecordDraft {
  const PrototypeRecordDraft({
    required this.title,
    required this.description,
    required this.status,
    required this.details,
  });

  final String title;
  final String description;
  final PrototypeRecordStatus status;
  final Map<String, String> details;
}
