import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';

void main() {
  group('catálogo funcional AGRO365', () {
    test('preserva as 17 funcionalidades administrativas', () {
      // Este repo é o CERNE ADM: o perfil Operacional (e as 38
      // funcionalidades de campo que ele carregava) vive no app irmão. Sobra
      // só o catálogo administrativo — 5 painéis de decisão, 10 consultas e
      // auditoria e 2 consultas de Ordem de Serviço.
      expect(adminFeatures, hasLength(17));
      expect(allFeatures, hasLength(17));

      expect(
        adminFeatures.every(
          (feature) => feature.profile == FeatureProfile.administration,
        ),
        isTrue,
      );
    });

    test('mantém IDs únicos e permite consulta pelo identificador', () {
      final ids = allFeatures.map((feature) => feature.id).toSet();

      expect(ids, hasLength(allFeatures.length));
      for (final feature in allFeatures) {
        expect(featureById(feature.id), same(feature));
      }
      expect(featureById('funcionalidade-inexistente'), isNull);
    });

    test('preserva a maturidade: 17 ready, zero hardware e zero mapped', () {
      // O catálogo administrativo é todo Ready: os itens de hardware
      // (Bluetooth, RFID, balança, SISBOV) eram exclusivamente do perfil
      // Operacional e saíram com ele.
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.ready),
        hasLength(17),
      );
      expect(
        allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ),
        isEmpty,
      );
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.mapped),
        isEmpty,
      );
    });

    test('preserva as invariantes estruturais do catálogo congelado', () {
      final fields = allFeatures.expand((feature) => feature.fields).toList();

      // Contagens do catálogo administrativo depois do fork CERNE ADM. Elas
      // são o freio de mão contra mudança acidental no contrato: qualquer
      // campo a mais ou a menos precisa ser uma decisão explícita.
      expect(fields, hasLength(60));
      expect(fields.where((field) => field.isRequired), hasLength(27));
      expect(allFeatures.where((feature) => feature.listMode), hasLength(9));
      expect(
        allFeatures.where((feature) => feature.existingRoute != null),
        hasLength(8),
      );
      // 5 coleções: "Lotes vinculados" (lotes-reproducao), as duas seções de
      // agrupamento de `processamentos` e as duas de `compras-animais`.
      expect(allFeatures.expand((feature) => feature.sections), hasLength(5));
      // Capabilities de hardware saíram junto com o perfil Operacional.
      expect(allFeatures.expand((feature) => feature.capabilities), isEmpty);
    });

    // fidelidade-campos (onda 0): um formulário em etapas pode esconder um
    // campo para sempre se ele não constar de nenhuma etapa — e o motor não
    // tem como perceber, porque o campo continua no contrato e continua sendo
    // validado no `submit`. Esta é a invariante que impede isso.
    test('as etapas alcançam todo campo e toda coleção do cadastro', () {
      final comEtapas = allFeatures
          .where((feature) => feature.steps.isNotEmpty)
          .toList(growable: false);

      // `consulta-produtos` é o único cadastro em etapas do CERNE ADM: com
      // ~40 campos fiscais, a rolagem única esconderia o fim do formulário.
      expect(comEtapas, hasLength(1));

      for (final feature in comEtapas) {
        final camposEmEtapas = [
          for (final step in feature.steps) ...step.fields,
        ];
        expect(
          camposEmEtapas.toSet(),
          hasLength(camposEmEtapas.length),
          reason: 'campo repetido em duas etapas de ${feature.id}',
        );
        expect(
          camposEmEtapas.toSet(),
          feature.fields.map((field) => field.id).toSet(),
          reason: 'campo fora de qualquer etapa em ${feature.id}',
        );

        final colecoesEmEtapas = [
          for (final step in feature.steps) ...step.sections,
        ];
        expect(
          colecoesEmEtapas.toSet(),
          feature.sections.toSet(),
          reason: 'coleção fora de qualquer etapa em ${feature.id}',
        );

        // A etapa sem campo e sem coleção é a revisão: existe uma só, e é a
        // última — do contrário o motor mostraria uma tela vazia no meio.
        final vazias = [
          for (var index = 0; index < feature.steps.length; index++)
            if (feature.steps[index].fields.isEmpty &&
                feature.steps[index].sections.isEmpty)
              index,
        ];
        expect(vazias, [feature.steps.length - 1], reason: feature.id);

        final simulationTargetField = feature.simulationTargetField;
        if (simulationTargetField != null) {
          expect(
            feature.steps.first.fields,
            contains(simulationTargetField),
            reason: 'simulação fora da 1a etapa em ${feature.id}',
          );
        }
      }
    });

    // fidelidade-campos (onda 8): a coleção deixou de ser um nome numa lista
    // de `String` e passou a declarar o que **um item** é. Estas são as
    // invariantes que impedem uma coleção de voltar ao estado de contador sem
    // que alguém decida isso.
    test('coleção com campos descreve o item por inteiro', () {
      final colecoes = [
        for (final feature in allFeatures)
          for (final collection in feature.collections)
            (feature: feature, collection: collection),
      ];

      // 5 coleções no catálogo administrativo: "Lotes vinculados"
      // (`lotes-reproducao`), as duas seções de agrupamento de
      // `processamentos` (Pendentes/Concluídos, contadores de propósito) e
      // "Itens da compra"/"Parcelas" de `compras-animais`.
      expect(colecoes, hasLength(5));

      final comCampos = colecoes
          .where((par) => par.collection.fields.isNotEmpty)
          .toList(growable: false);
      expect(comCampos, hasLength(3));
      expect(
        colecoes
            .where((par) => par.collection.fields.isEmpty)
            .map((par) => par.feature.id)
            .toSet(),
        {'processamentos'},
      );
      expect(
        comCampos.fold<int>(
          0,
          (total, par) => total + par.collection.fields.length,
        ),
        11,
      );

      for (final par in comCampos) {
        final onde = '${par.feature.id}/${par.collection.name}';
        final ids = par.collection.fields
            .map((field) => field.id)
            .toList(growable: false);

        expect(ids.toSet(), hasLength(ids.length), reason: onde);
        // Sem rótulo do item, a folha do formulário abriria com o nome da
        // coleção no plural ("Insumos") para cadastrar um só.
        expect(par.collection.itemLabel, isNotNull, reason: onde);
        expect(ids, contains(par.collection.titleField), reason: onde);
        for (final campo in par.collection.subtitleFields) {
          expect(ids, contains(campo), reason: onde);
        }
        // Um item sem nenhum campo obrigatório entraria vazio na lista.
        expect(
          par.collection.fields.any((field) => field.isRequired),
          isTrue,
          reason: onde,
        );
      }
    });

    test('coleção obrigatória sempre existe entre as coleções da tela', () {
      for (final feature in allFeatures) {
        for (final section in feature.requiredSections) {
          expect(feature.sections, contains(section), reason: feature.id);
        }
      }

      // As duas coleções `min:1` que sobraram no catálogo administrativo:
      // em ambos os casos a coleção **é** o registro, e salvar sem nenhum
      // item não registra nada.
      expect(
        {
          for (final feature in allFeatures)
            if (feature.requiredSections.isNotEmpty)
              feature.id: feature.requiredSections,
        },
        {
          'lotes-reproducao': ['Lotes vinculados'],
          'compras-animais': ['Itens da compra'],
        },
      );
    });

    test('referências internas apontam para contratos e campos existentes', () {
      final featuresById = {
        for (final feature in allFeatures) feature.id: feature,
      };

      for (final feature in allFeatures) {
        final fieldIds = feature.fields.map((field) => field.id).toSet();
        expect(
          fieldIds,
          hasLength(feature.fields.length),
          reason: 'IDs de campo duplicados em ${feature.id}',
        );

        final dataSourceId = feature.dataSourceId;
        if (dataSourceId != null) {
          // A fonte é um cadastro do app irmão (CERNE Operação): aqui ela
          // não existe no catálogo, e a consulta abre vazia até o backend
          // ligar as duas pontas.
          expect(
            featuresById.containsKey(dataSourceId),
            isFalse,
            reason: 'Fonte operacional inválida em ${feature.id}',
          );
        }

        final recordTitleField = feature.recordTitleField;
        if (recordTitleField != null) {
          expect(
            fieldIds,
            contains(recordTitleField),
            reason: 'Título de registro inválido em ${feature.id}',
          );
        }

        for (final descriptionField in feature.recordDescriptionFields) {
          expect(
            fieldIds,
            contains(descriptionField),
            reason: 'Descrição de registro inválida em ${feature.id}',
          );
        }

        final simulationTargetField = feature.simulationTargetField;
        if (simulationTargetField != null) {
          // fidelidade-esteira (onda 13): quando a captura empilha numa
          // coleção (`simulationCollectionName`), o campo-alvo é o `id` de
          // um campo **do item**, não de `feature.fields` — o cabeçalho não
          // tem mais esse campo escalar.
          final simulationCollectionName = feature.simulationCollectionName;
          final targetIds = simulationCollectionName == null
              ? fieldIds
              : feature
                    .collectionByName(simulationCollectionName)!
                    .fields
                    .map((field) => field.id)
                    .toSet();
          expect(
            targetIds,
            contains(simulationTargetField),
            reason: 'Campo-alvo da simulação inválido em ${feature.id}',
          );
        }
      }
    });

    test('não sobrou nenhum item de hardware no catálogo administrativo', () {
      // Bluetooth, RFID, balança e SISBOV eram exclusivos do perfil
      // Operacional: nenhum deles tem contraparte administrativa.
      expect(
        allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ),
        isEmpty,
      );
      expect(
        allFeatures.where((feature) => feature.simulation != null),
        isEmpty,
      );
    });

    test('preserva consultas compartilhadas e exportações de auditoria', () {
      expect(featureById('areas')?.dataSourceId, 'cadastrar-area');
      // confinamento (onda 2): `carga`, `descarga`, `balanca` e `nota-cocho`
      // saíram do catálogo — o Confinamento absorveu o que restava do
      // Misturador. Ver comentário em `functional_catalog.dart`.
      expect(featureById('carga'), isNull);
      // fidelidade-campos (onda 4): `lotes-reproducao` voltou — agora como
      // consulta administrativa somente leitura.
      expect(featureById('lotes-reproducao')?.readOnly, isTrue);
      expect(
        featureById('lotes-reproducao')?.profile,
        FeatureProfile.administration,
      );
      expect(featureById('descarga'), isNull);
      expect(featureById('balanca'), isNull);
      expect(featureById('nota-cocho'), isNull);
      expect(
        featureById('exportar-log-estoque')?.auditExport,
        AuditExportKind.estoque,
      );
      expect(
        featureById('exportar-log-pecuaria')?.auditExport,
        AuditExportKind.pecuaria,
      );
    });
  });
}
