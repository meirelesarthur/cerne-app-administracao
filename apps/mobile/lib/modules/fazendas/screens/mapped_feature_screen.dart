import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../functional_journey_engine.dart';
import '../state/prototype_records_store.dart';

class MappedFeatureScreen extends StatelessWidget {
  const MappedFeatureScreen({
    super.key,
    required this.featureId,
    required this.profile,
    this.centerRoute,
  });

  final String featureId;
  final FeatureProfile profile;
  final String? centerRoute;

  @override
  Widget build(BuildContext context) {
    final feature = featureById(featureId);
    final fallbackCenterRoute = profile == FeatureProfile.administration
        ? '/fazendas/administracao'
        : '/fazendas/operacional';
    final resolvedCenterRoute = centerRoute ?? fallbackCenterRoute;

    if (feature == null || feature.profile != profile) {
      return AppEmptyState(
        icon: AppIcons.shieldAlert,
        title: 'Disponível no app Operação',
        description:
            'Este lançamento é feito em campo, pelo app Operação. Aqui na '
            'Administração você acompanha o resultado pelas consultas.',
        action: AppButton(
          onPressed: () => context.go(resolvedCenterRoute),
          child: const Text('Voltar'),
        ),
      );
    }

    return _MappedFeatureJourney(
      key: ValueKey('${profile.name}/${feature.id}'),
      feature: feature,
      centerRoute: resolvedCenterRoute,
    );
  }
}

class _MappedFeatureJourney extends ConsumerStatefulWidget {
  const _MappedFeatureJourney({
    super.key,
    required this.feature,
    required this.centerRoute,
  });

  final FeatureDefinition feature;
  final String centerRoute;

  @override
  ConsumerState<_MappedFeatureJourney> createState() =>
      _MappedFeatureJourneyState();
}

class _MappedFeatureJourneyState extends ConsumerState<_MappedFeatureJourney> {
  late final FunctionalJourneyController _journey;
  PrototypeRecord? _lastCreated;

  /// Título do registro editado na última submissão — `null` quando a
  /// submissão foi uma criação. Só existe para diferenciar a mensagem do
  /// painel de sucesso ("atualizado" vs. "salvo").
  String? _lastEditedTitle;

  /// Notificações de rolagem borbulham só para ANCESTRAIS do `Scrollable`
  /// que as dispara — a `ListView` real fica aqui, um nível acima de
  /// `_RecordsList` (que é só mais um item dela). Por isso o gatilho de
  /// "carregar mais" mora neste nível e é repassado por `GlobalKey`, em vez
  /// de um `NotificationListener` dentro do próprio `_RecordsList` (que
  /// nunca veria nada — notificação não desce, só sobe).
  final _recordsListKey = GlobalKey<_RecordsListState>();

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _recordsListKey.currentState?.maybeLoadMore(notification.metrics);
    }
    return false;
  }

  FeatureDefinition get feature => widget.feature;
  String get dataSourceId => feature.dataSourceId ?? feature.id;

  @override
  void initState() {
    super.initState();
    _journey = FunctionalJourneyController(feature);
  }

  /// Valores do formulário logo ao abrir (vazio, datas de hoje ou o registro
  /// em edição) — diferença contra isto é o que conta como "não salvo".
  Map<String, String> _formBaseline = const {};

  void _startForm() => setState(() {
    _journey.startForm();
    _formBaseline = Map.of(_journey.form.values);
  });

  bool get _hasUnsavedChanges {
    if (_journey.mode != FunctionalJourneyMode.form) return false;
    final form = _journey.form;
    if (form.groupItems.values.any((items) => items.isNotEmpty)) return true;
    final keys = {...form.values.keys, ..._formBaseline.keys};
    return keys.any(
      (k) => (form.values[k] ?? '').trim() != (_formBaseline[k] ?? '').trim(),
    );
  }

  /// Sai do formulário perguntando antes quando há algo preenchido.
  /// Volta para quem abriu a tela (a busca, um painel, a aba) — e só cai na
  /// aba de origem quando não há histórico (link direto).
  void _voltarParaOrigem() =>
      context.canPop() ? context.pop() : context.go(widget.centerRoute);

  Future<void> _leaveForm(VoidCallback leave) async {
    if (_hasUnsavedChanges && !await confirmAppLeave(context)) return;
    if (mounted) leave();
  }

  /// Abre o cadastro pré-preenchido com os dados de [record] — a ação
  /// "Editar" que a visualização do registro oferece ao perfil operacional.
  /// Ver [FunctionalJourneyController.startEditing].
  void _editRecord(PrototypeRecord record) => setState(() {
    _journey.startEditing(record);
    _formBaseline = Map.of(_journey.form.values);
  });

  void _showList() => setState(_journey.showList);

  /// Botão de criar da listagem no imperativo, em até duas palavras: o
  /// `createAction` do catálogo é um título ("Nova transferência de animal"),
  /// então "Novo/Nova X" vira "Adicionar X".
  static String _rotuloCriar(String? createAction) {
    if (createAction == null) return 'Adicionar';
    final palavras = createAction.split(' ');
    if ({'Novo', 'Nova'}.contains(palavras.first)) {
      return palavras.length > 1 ? 'Adicionar ${palavras[1]}' : 'Adicionar';
    }
    return palavras.take(2).join(' ');
  }

  /// CTA do rodapé em formulário com etapas: avança enquanto houver etapa e
  /// só salva na última. Sem etapas declaradas, salva direto — o botão do
  /// arquétipo *bottom fixed* continua sendo "Salvar".
  void _advance() {
    if (_journey.hasSteps && !_journey.isLastStep) {
      setState(() {
        _journey.advanceStep();
      });
      return;
    }
    _submit();
  }

  void _retreat() => setState(() {
    _journey.retreatStep();
  });

  void _setValue(String fieldId, String value) {
    setState(() => _journey.setValue(fieldId, value));
  }

  // fidelidade-esteira (onda 13): destino da captura de hardware quando a
  // funcionalidade declara `simulationCollectionName` — cada leitura vira um
  // item novo na coleção (empilha), em vez de sobrescrever um campo
  // escalar. Ver `transferencia-animal`.
  void _captureCollectionItem(
    String collectionName,
    String fieldId,
    String value,
  ) {
    if (value.trim().isEmpty) return;
    setState(
      () => _journey.addGroupItem(collectionName, {fieldId: value.trim()}),
    );
  }

  void _removeCollectionItem(String group, int index) =>
      setState(() => _journey.removeGroupItem(group, index));

  /// Formulário de **um item** da coleção, na folha inferior. É o que faltava
  /// para a coleção deixar de ser um contador: cada "Adicionar" abre os campos
  /// que o contrato define para o item e a linha entra na lista com o dado
  /// verdadeiro. Coleção sem campos declarados continua só contando.
  void _addCollectionItem(BuildContext context, FeatureCollection collection) {
    _openCollectionItemSheet(context, collection);
  }

  /// Mesma folha de [_addCollectionItem], pré-preenchida com o item em
  /// [index] — "Editar" no lugar de "Adicionar", substitui o item ao salvar
  /// em vez de acrescentar um novo. Coleção sem campos declarados não tem o
  /// que editar (o item é `{}`), então o ícone de editar nem aparece nesse
  /// caso — ver o `onEdit` condicional no `AppCollectionList`.
  void _editCollectionItem(
    BuildContext context,
    FeatureCollection collection,
    int index,
  ) {
    _openCollectionItemSheet(
      context,
      collection,
      editIndex: index,
      initialValues: _journey.form.itemsOf(collection.name)[index],
    );
  }

  void _openCollectionItemSheet(
    BuildContext context,
    FeatureCollection collection, {
    int? editIndex,
    Map<String, String>? initialValues,
  }) {
    if (collection.fields.isEmpty) {
      setState(() => _journey.addGroupItem(collection.name));
      return;
    }

    final values = <String, String>{...?initialValues};
    var attempted = false;
    final isEditing = editIndex != null;

    showAppBottomSheet<void>(
      context,
      title: collection.itemLabel ?? collection.name,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < collection.fields.length; index++) ...[
              _FeatureFieldControl(
                field: collection.fields[index],
                value: values[collection.fields[index].id] ?? '',
                isRequired: isCollectionItemFieldRequired(
                  _journey.feature,
                  collection,
                  collection.fields[index],
                  values,
                  _journey.form.values,
                ),
                error: attempted
                    ? collectionItemFieldError(
                        _journey.feature,
                        collection,
                        collection.fields[index],
                        values,
                        _journey.form.values,
                      )
                    : null,
                onChanged: (value) => setSheetState(() {
                  values[collection.fields[index].id] = value;
                }),
              ),
              if (index < collection.fields.length - 1)
                const SizedBox(height: AppSpacing.space3),
            ],
            const SizedBox(height: AppSpacing.space4),
            // Sem botão em beco sem saída (mesma regra de `FlowShell`): o
            // toque sempre responde, e o que falta aparece nos campos.
            AppButton(
              fullWidth: true,
              onPressed: () {
                if (!isCollectionItemValidFor(
                  _journey.feature,
                  collection,
                  values,
                  _journey.form.values,
                )) {
                  setSheetState(() => attempted = true);
                  return;
                }
                setState(() {
                  if (isEditing) {
                    _journey.updateGroupItem(collection.name, editIndex, {
                      ...values,
                    });
                  } else {
                    _journey.addGroupItem(collection.name, {...values});
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final editingId = _journey.editingRecordId;
    final draft = _journey.submit();
    if (draft == null) {
      setState(() {});
      return;
    }
    _lastEditedTitle = editingId == null ? null : draft.title;
    final notifier = ref.read(prototypeRecordsProvider.notifier);
    _lastCreated = editingId == null
        ? notifier.addRecord(
            featureId: dataSourceId,
            title: draft.title,
            description: draft.description,
            status: draft.status,
            details: draft.details,
          )
        : notifier.updateRecord(
                featureId: dataSourceId,
                id: editingId,
                title: draft.title,
                description: draft.description,
                status: draft.status,
                details: draft.details,
              ) ??
              notifier.addRecord(
                featureId: dataSourceId,
                title: draft.title,
                description: draft.description,
                status: draft.status,
                details: draft.details,
              );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_journey.mode == FunctionalJourneyMode.success) {
      final wasEditing = _lastEditedTitle != null;
      final canCreate = feature.fields.isNotEmpty && !feature.readOnly;
      // Tela de resultado padrão: inclusão em verde, alteração em azul.
      // Repetir (contorno) em cima, ver a lista (CTA) embaixo.
      return AppSuccessPanel(
        kind: wasEditing ? AppResultKind.updated : AppResultKind.created,
        title: wasEditing
            ? '${_lastEditedTitle ?? feature.title} atualizado'
            : feature.successTitle ??
                  '${_lastCreated?.title ?? feature.title} salvo',
        description: Text(
          wasEditing
              ? 'As alterações foram salvas.'
              : feature.successDescription ?? 'O registro foi salvo.',
        ),
        actions: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (feature.listMode && canCreate) ...[
              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                variant: AppButtonVariant.outline,
                onPressed: _startForm,
                child: Text(_rotuloCriar(feature.createAction).toUpperCase()),
              ),
              const SizedBox(height: AppSpacing.space3),
            ],
            AppButton(
              fullWidth: true,
              size: AppButtonSize.lg,
              onPressed: feature.listMode
                  ? _showList
                  : _voltarParaOrigem,
              child: Text(feature.listMode ? 'VER TODOS' : 'CONCLUIR'),
            ),
          ],
        ),
      );
    }

    // `isForm` (mode == form) só é verdadeiro para cadastros `listMode`, que
    // têm uma listagem separada e entram em modo de formulário ao criar. Uma
    // funcionalidade `!listMode` (hardware simulado, consulta sem lista) não
    // tem esse estado de listagem — ela **é** o formulário desde o primeiro
    // frame, e cai direto no `else` de `_FeatureForm` mais abaixo,
    // independente do modo. `showingForm` é a mesma condição desse `else`:
    // sem ela, o cabeçalho/rodapé de formulário (barra de ação com o CTA,
    // folha branca, "mais opções") nunca aparecia nessas telas — o botão de
    // concluir a simulação ficava inacessível. Ver
    // docs/ESTEIRA-FIDELIDADE-CONTRATO.md.
    final isForm = _journey.mode == FunctionalJourneyMode.form;
    final isRecordsList =
        feature.listMode && _journey.mode == FunctionalJourneyMode.list;
    final showingForm = feature.auditExport == null && !isRecordsList;
    // banco-real: administração pode criar quando a própria tela declara
    // campos (ex.: Produtos) — deixou de ser exclusivo do perfil
    // operacional. `readOnly` bloqueia mesmo com `fields` preenchidos —
    // cadastro estruturante ou decisão que pertence ao desktop, o app só
    // consulta. Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    final canCreateRecords = feature.fields.isNotEmpty && !feature.readOnly;
    // Dentro de um formulário em etapas, o voltar do cabeçalho recua uma etapa
    // em vez de abandonar o preenchimento: sair perdendo tudo o que já foi
    // digitado é o pior desfecho possível num cadastro longo.
    final inStep = showingForm && _journey.hasSteps && !_journey.isFirstStep;
    final backToRecords = showingForm && feature.listMode && !inStep;
    final step = showingForm ? _journey.currentStep : null;

    // Título e voltar vivem na faixa de 64 px sobre o canvas, a régua de
    // etapas dentro da folha branca e o rodapé colado na base: a anatomia
    // inteira vem de [AppPageBody] — a mesma peça dos fluxos operacionais e do
    // Bank —, sem `Scaffold` porque o shell já resolveu a área segura.
    final isEditing = isForm && _journey.editingRecordId != null;

    return AppPageBody(
      title: isForm
          ? isEditing
                ? 'Editar ${feature.title}'
                : feature.createAction ?? feature.title
          : feature.title,
      onBack: inStep
          ? _retreat
          : backToRecords
          ? () => _leaveForm(_showList)
          : () => _leaveForm(_voltarParaOrigem),
      hasUnsavedChanges: _hasUnsavedChanges,
      actionIcon: showingForm ? AppIcons.moreVertical : null,
      actionLabel: showingForm ? 'Mais opções' : null,
      onAction: showingForm ? () => _showFormDetails(context) : null,
      totalSteps: step != null ? _journey.stepCount : null,
      currentStep: _journey.stepIndex + 1,
      // Cadastro e listagem (fidelidade-esteira: padrão de listagens — topo
      // cinza, card branco, itens da listagem em cinza): a folha é a
      // superfície branca. Só a introdução (tela sem lista, sem cadastro —
      // hardware simulado, consulta) segue na folha cinza, onde é o cinza
      // que separa um `AppCard` do outro.
      sheetColor: showingForm || isRecordsList
          ? null
          : Theme.of(context).extension<AppSemanticColors>()!.bgSheet,
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      actionBar: showingForm
          ? AppActionBar(
              primaryLabel: _journey.isLastStep
                  ? isEditing
                        ? 'Salvar alterações'
                        : feature.primaryAction ?? 'Salvar'
                  : 'Continuar',
              primaryIcon: _journey.isLastStep
                  ? AppIcons.saveAll
                  : AppIcons.arrowRight,
              onPrimary: _advance,
              secondaryLabel: inStep
                  ? 'Voltar'
                  : feature.listMode
                  ? 'Cancelar'
                  : null,
              onSecondary: inStep
                  ? _retreat
                  : feature.listMode
                  ? () => _leaveForm(_showList)
                  : null,
            )
          : isRecordsList && canCreateRecords
          ? AppActionBar(
              primaryLabel: _rotuloCriar(feature.createAction),
              primaryIcon: AppIcons.plus,
              primarySize: AppButtonSize.xl,
              onPrimary: _startForm,
            )
          : null,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            if (!isForm) ...[
              _FeatureIntroduction(feature: feature),
              const SizedBox(height: AppSpacing.space4),
            ],
            // O card "Recursos envolvidos" (Bluetooth/RFID/Balança...) saiu
            // daqui (ver plano de UX): quando a função usa hardware simulado, o
            // próprio `AppHardwareSimulator` já mostra isso mais abaixo, na hora
            // de usar — listar de novo antes, em termos técnicos, só adiantava
            // jargão sem ajudar a decisão.
            if (feature.auditExport case final auditExport?)
              _AuditExportJourney(kind: auditExport)
            else if (feature.listMode &&
                _journey.mode == FunctionalJourneyMode.list)
              _RecordsList(
                key: _recordsListKey,
                feature: feature,
                records: ref
                    .watch(prototypeRecordsProvider)
                    .recordsFor(dataSourceId),
                canCreate: canCreateRecords,
                onCreate: _startForm,
                // RBAC da visualização: o CERNE ADM consulta os registros em
                // modo somente leitura — quem edita um registro já gravado é
                // o app Operação. Sem ação de editar na ficha do registro.
                canEdit: false,
                onEdit: _editRecord,
              )
            else
              _FeatureForm(
                feature: feature,
                journey: _journey,
                onValueChanged: _setValue,
                onAddCollectionItem: (collection) =>
                    _addCollectionItem(context, collection),
                onEditCollectionItem: (collection, index) =>
                    _editCollectionItem(context, collection, index),
                onRemoveCollectionItem: _removeCollectionItem,
                onCaptureCollectionItem: _captureCollectionItem,
              ),
          ],
        ),
      ),
    );
  }

  void _showFormDetails(BuildContext context) {
    showAppBottomSheet<void>(
      context,
      title: feature.title,
      child: Text(feature.objective),
    );
  }
}

class _AuditExportJourney extends StatelessWidget {
  const _AuditExportJourney({required this.kind});

  final AuditExportKind kind;

  @override
  Widget build(BuildContext context) {
    return AppAuditExportPanel(
      filename: kind == AuditExportKind.estoque
          ? 'auditoria-estoque'
          : 'auditoria-pecuaria',
      rows: switch (kind) {
        AuditExportKind.estoque => _stockAuditRows,
        AuditExportKind.pecuaria => _livestockAuditRows,
      },
      downloadFile: true,
      onExport: (_) {},
    );
  }
}

const _stockAuditRows = <Map<String, String>>[
  {
    'data': '2026-08-16 08:42',
    'usuário': 'João Oliveira',
    'ação': 'Batida registrada',
    'entidade': 'Ração engorda',
    'quantidade': '1.000 kg',
  },
  {
    'data': '2026-08-15 17:18',
    'usuário': 'Maria Souza',
    'ação': 'Estoque ajustado',
    'entidade': 'Sal mineral',
    'quantidade': '120 kg',
  },
  {
    'data': '2026-08-14 14:05',
    'usuário': 'Carlos Dias',
    'ação': 'Entrada confirmada',
    'entidade': 'Milho moído',
    'quantidade': '4.500 kg',
  },
];

const _livestockAuditRows = <Map<String, String>>[
  {
    'data': '2026-08-16 09:15',
    'usuário': 'Maria Souza',
    'ação': 'Diagnóstico registrado',
    'entidade': 'Lote Matrizes 01',
    'resultado': '94 prenhes',
  },
  {
    'data': '2026-08-15 16:20',
    'usuário': 'João Oliveira',
    'ação': 'Transferência concluída',
    'entidade': 'RFID 982000123456120',
    'resultado': 'Lote 42',
  },
  {
    'data': '2026-08-14 11:30',
    'usuário': 'Carlos Dias',
    'ação': 'Pesagem registrada',
    'entidade': 'Lote Recria 02',
    'resultado': '318 kg médio',
  },
];

/// Abertura da função dentro da folha: o objetivo em uma linha.
///
/// As chips de perfil ("Operação"/"Administração") e de status ("Funcional no
/// protótipo") já tinham saído daqui — a primeira repetia o ambiente em que a
/// pessoa entrou, a segunda é informação de desenvolvimento. Os detalhes de
/// fonte/premissa também são internos e não aparecem na jornada. Agora o título
/// e o voltar também saíram: viraram a barra superior fixa do padrão global,
/// acima da folha.
class _FeatureIntroduction extends StatelessWidget {
  const _FeatureIntroduction({required this.feature});

  final FeatureDefinition feature;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature.objective, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _RecordsList extends StatefulWidget {
  const _RecordsList({
    super.key,
    required this.feature,
    required this.records,
    required this.canCreate,
    required this.onCreate,
    required this.canEdit,
    required this.onEdit,
  });

  final FeatureDefinition feature;
  final List<PrototypeRecord> records;
  final bool canCreate;
  final VoidCallback onCreate;

  /// Perfil operacional em funcionalidade editável: a visualização do
  /// registro ganha a ação "Editar" no cabeçalho. Administração, ou uma
  /// funcionalidade sem campo próprio, mantém a ficha somente leitura.
  final bool canEdit;
  final ValueChanged<PrototypeRecord> onEdit;

  @override
  State<_RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends State<_RecordsList> {
  static const _pageSize = 5;
  // fidelidade-esteira: gatilho de "carregar mais" a 200px do fim da
  // rolagem — perto o bastante para o próximo lote já estar pronto quando a
  // pessoa chega ao fim visível, sem disparar no primeiro pixel de rolagem.
  static const _loadMoreThreshold = 200.0;
  late final TextEditingController _searchController;
  var _query = '';
  var _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() {
    _query = value;
    _visibleCount = _pageSize;
  });

  /// Sem paginação (fidelidade-esteira: "a busca ao deslizar para baixo vai
  /// trazendo mais registros"). Chamado de fora (`_MappedFeatureJourneyState`,
  /// via `GlobalKey`): esta lista nasce sem `Scrollable` próprio — é só mais
  /// um item da `ListView` real, um nível acima — e notificação de rolagem
  /// borbulha só para ANCESTRAIS de quem a dispara, nunca para baixo.
  void maybeLoadMore(ScrollMetrics metrics) {
    final filteredCount = _filteredRecords().length;
    if (_visibleCount >= filteredCount) return;
    if (metrics.pixels >= metrics.maxScrollExtent - _loadMoreThreshold) {
      setState(
        () =>
            _visibleCount = (_visibleCount + _pageSize).clamp(0, filteredCount),
      );
    }
  }

  List<PrototypeRecord> _filteredRecords() {
    final records = _recordsWithMinimumSample(widget.feature, widget.records);
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where((record) {
          final searchable = [
            record.title,
            record.description,
            ...record.details.keys,
            ...record.details.values,
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final records = _recordsWithMinimumSample(widget.feature, widget.records);
    final query = _query.trim().toLowerCase();
    final filteredRecords = _filteredRecords();
    final visibleRecords = filteredRecords.sublist(
      0,
      _visibleCount.clamp(0, filteredRecords.length),
    );

    // fidelidade-esteira: padrão de listagens — a folha já é branca
    // (`sheetColor` em `MappedFeatureScreen`) e cada linha usa
    // `AppMenuItemSurface.subtle` (cinza, sem sombra) para se destacar
    // contra ela — o inverso do que valia antes desta esteira (linhas
    // brancas sobre folha cinza), pedido explícito do usuário.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: AppSectionTitle(child: Text('Registros'))),
            AppChip(child: Text('${records.length}')),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        AppFormField(
          label: 'Buscar registros',
          child: AppTextInput(
            controller: _searchController,
            placeholder: 'Nome, situação ou detalhe',
            prefixIcon: const AppIcon(AppIcons.aiSearch),
            onChanged: _setQuery,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        if (filteredRecords.isEmpty)
          // banco-real (correção de regressão): a busca (`dbec5b7`)
          // trocou a mensagem de vazio por uma única, genérica — sem
          // diferenciar "a busca não achou nada" (`records` existe,
          // só o filtro zerou) de "não há registro nenhum". A segunda
          // precisa continuar dizendo a verdade por perfil (criar vs.
          // somente leitura vs. genérico), senão uma consulta
          // somente leitura sem dado sincronizado passa a impressão
          // de que o app perdeu o cadastro. Ver
          // `mapped_feature_screen_test.dart`, "Áreas mostra estado
          // vazio honesto...".
          AppEmptyState(
            icon: query.isNotEmpty ? AppIcons.search : AppIcons.clipboardCheck,
            title: widget.feature.emptyLabel ?? 'Nenhum registro encontrado',
            description: query.isNotEmpty
                ? 'Ajuste a busca para encontrar outro cadastro.'
                : widget.canCreate
                ? 'Use a ação abaixo para criar o primeiro registro desta rotina.'
                : widget.feature.readOnly
                ? 'O cadastro desta rotina é feito no sistema web. Assim que sincronizar, os registros aparecem aqui.'
                : 'Os registros operacionais desta sessão aparecerão aqui.',
          )
        else
          for (var index = 0; index < visibleRecords.length; index++) ...[
            AppMenuItem(
              icon: AppIcons.fileCheck2,
              label: visibleRecords[index].title,
              description: visibleRecords[index].description,
              surface: AppMenuItemSurface.subtle,
              showShadow: false,
              trailing: AppChip(
                tone:
                    visibleRecords[index].status ==
                        PrototypeRecordStatus.scheduled
                    ? AppChipTone.blue
                    : AppChipTone.brand,
                child: Text(_statusLabel(visibleRecords[index].status)),
              ),
              onTap: () => _showRecord(context, visibleRecords[index]),
            ),
            if (index < visibleRecords.length - 1)
              const SizedBox(height: AppSpacing.space2),
          ],
        if (visibleRecords.length < filteredRecords.length) ...[
          const SizedBox(height: AppSpacing.space3),
          const _SlideForMoreHint(),
        ],
        // O CTA "novo registro" agora é o rodapé flutuante fixo
        // (`AppActionBar` em `MappedFeatureScreen`) — não some ao rolar a
        // listagem, nem precisa da folga inline que este espaço reservava.
        if (widget.canCreate) const SizedBox(height: AppSpacing.space4),
      ],
    );
  }

  String _statusLabel(PrototypeRecordStatus status) => switch (status) {
    PrototypeRecordStatus.active => 'Ativo',
    PrototypeRecordStatus.completed => 'Concluído',
    PrototypeRecordStatus.scheduled => 'Programado',
  };

  /// Visualização do registro em tela cheia. Era folha inferior: o campo
  /// tinha 85% da viewport para ler um registro que pode ter uma dúzia de
  /// linhas, e a saída era um botão "Fechar" no fim de uma rolagem curta.
  /// Agora abre como tela funda — o dado usa a altura inteira e o retorno é o
  /// voltar do cabeçalho, o mesmo gesto de qualquer outra tela.
  ///
  /// Os campos aparecem como o próprio controle do cadastro (desabilitado,
  /// com o valor gravado dentro) — não como uma lista de texto rótulo/valor à
  /// parte. Quando o cadastro de origem declarou etapas, [_recordFieldGroups]
  /// separa os campos de volta pelas mesmas etapas do preenchimento e a tela
  /// vira abas ([_RecordFieldTabs]) — a régua que orientou quem preencheu
  /// orienta também quem lê depois.
  void _showRecord(BuildContext context, PrototypeRecord record) {
    final fieldGroups = _recordFieldGroups(widget.feature, record);

    showAppDetailPage<void>(
      context,
      title: record.title,
      actionIcon: widget.canEdit ? AppIcons.pencil : null,
      actionLabel: widget.canEdit ? 'Editar' : null,
      onAction: widget.canEdit
          ? () {
              Navigator.of(context).pop();
              widget.onEdit(record);
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fieldGroups != null)
            _RecordFieldTabs(groups: fieldGroups)
          else
            ..._recordFieldWidgets(
              widget.feature,
              record,
              fields: widget.feature.fields,
              sectionNames: widget.feature.sections,
            ),
        ],
      ),
    );
  }
}

/// Dica de rolagem infinita (fidelidade-esteira: "a busca ao deslizar para
/// baixo vai trazendo mais registros" — sem paginação). Espelha o rótulo e o
/// chevron centralizados da referência.
class _SlideForMoreHint extends StatelessWidget {
  const _SlideForMoreHint();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      children: [
        AppIcon(
          AppIcons.chevronUp,
          size: AppSize.iconXs,
          color: semantic.fgMuted,
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          'Deslize para exibir mais',
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
      ],
    );
  }
}

/// Um controle do cadastro (`_FeatureFieldControl`), desabilitado e
/// pré-preenchido com o valor gravado do registro — a leitura reaproveita o
/// mesmo widget que o preenchimento usou, em vez de uma linha de texto solta.
Widget _disabledRecordField(FeatureField field, String value) {
  return _FeatureFieldControl(
    field: field,
    value: value,
    isRequired: false,
    enabled: false,
    onChanged: (_) {},
  );
}

/// O registro salvo não guarda os itens de uma coleção um a um — só o resumo
/// que [buildPrototypeRecordDraft] compõe (contagem + títulos, ver
/// `_resumoColecao` em `functional_journey_engine.dart`). A visualização
/// mostra esse resumo dentro do mesmo tipo de campo do cadastro (uma área de
/// texto desabilitada) para continuar parecendo parte do formulário, mesmo
/// sem poder reabrir cada item individualmente.
Widget _disabledRecordCollection(FeatureCollection collection, String value) {
  return AppFormField(
    label: collection.name,
    child: AppTextarea(
      initialValue: value,
      enabled: false,
      minLines: 1,
      maxLines: 4,
    ),
  );
}

/// Monta os controles desabilitados de um grupo de campos/coleções do
/// registro, na ordem declarada — pulando o que ficou em branco (campo
/// opcional não respondido, coleção sem item lançado).
///
/// Uma consulta somente leitura (`feature.fields`/`sections` vazios — não há
/// cadastro para espelhar) ainda pode ter `record.details` preenchido pelo
/// dado demonstrativo/sincronizado. Sem [FeatureField] para saber o tipo do
/// controle, essas sobras viram campo de texto desabilitado (o mesmo padrão
/// do resto da tela) — sintetiza um [FeatureField] só com `id`/`label`, que
/// cai no caso `text` do switch de [_FeatureFieldControl]. Continua sem
/// aparecer como `AppReviewList`: uma consulta sem cadastro não deixa de
/// seguir o mesmo modelo de campo desabilitado só por não ter [FeatureField]
/// declarado.
///
/// [includeLeftover] só vale para a chamada única (sem etapas — `fields`/
/// `sectionNames` já são os da funcionalidade inteira). Por etapa
/// ([_recordFieldGroups]), cada chamada só enxerga os campos *daquela* etapa;
/// tratar como "sobra" o que pertence às outras etapas vazaria, por exemplo,
/// o valor de "Marcação" dentro da aba "Identificação". A invariante de
/// catálogo (todo campo aparece em exatamente uma etapa) garante que, somadas
/// todas as etapas, nada fica de fora — então ali a sobra é sempre vazia.
List<Widget> _recordFieldWidgets(
  FeatureDefinition feature,
  PrototypeRecord record, {
  required List<FeatureField> fields,
  required List<String> sectionNames,
  bool includeLeftover = true,
}) {
  final widgets = <Widget>[];
  final consumedLabels = <String>{};

  for (final field in fields) {
    consumedLabels.add(field.label);
    final value = record.details[field.label];
    if (value == null || value.trim().isEmpty) continue;
    if (widgets.isNotEmpty) {
      widgets.add(const SizedBox(height: AppSpacing.space4));
    }
    // Resolve value→label para campos com selectOptions/colorPalette (o
    // registro guarda o valor emitido; aqui exibe o rótulo humano).
    widgets.add(_disabledRecordField(field, featureFieldDisplay(field, value)));
  }
  for (final sectionName in sectionNames) {
    consumedLabels.add(sectionName);
    final collection = feature.collectionByName(sectionName);
    final value = record.details[sectionName];
    if (collection == null || value == null || value.trim().isEmpty) continue;
    if (widgets.isNotEmpty) {
      widgets.add(const SizedBox(height: AppSpacing.space4));
    }
    widgets.add(_disabledRecordCollection(collection, value));
  }

  if (includeLeftover) {
    for (final entry in record.details.entries) {
      if (consumedLabels.contains(entry.key)) continue;
      if (entry.value.trim().isEmpty) continue;
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.space4));
      }
      widgets.add(
        _disabledRecordField(
          FeatureField(id: entry.key, label: entry.key),
          entry.value,
        ),
      );
    }
  }

  return widgets;
}

/// Os controles desabilitados de uma etapa do cadastro original, sob uma aba
/// de [_RecordFieldTabs].
class _RecordFieldGroup {
  const _RecordFieldGroup({required this.label, required this.children});

  /// Rótulo da aba — o título da etapa ([FeatureFormStep.title]).
  final String label;
  final List<Widget> children;
}

/// Reagrupa os campos do registro pelas etapas do cadastro de origem, para
/// alimentar [_RecordFieldTabs]. `null` quando a funcionalidade não declara
/// etapas: aí quem chama usa a lista única, como sempre.
///
/// A etapa de revisão ([isFeatureReviewStep]) nunca vira grupo — não tem
/// campo nem coleção própria, é só a tela de conferência do preenchimento.
/// Uma etapa cujos campos ficaram todos em branco (opcionais não
/// respondidos) também não vira aba vazia: só entra grupo com conteúdo.
List<_RecordFieldGroup>? _recordFieldGroups(
  FeatureDefinition feature,
  PrototypeRecord record,
) {
  if (feature.steps.isEmpty) return null;

  final groups = <_RecordFieldGroup>[];
  for (var index = 0; index < feature.steps.length; index++) {
    if (isFeatureReviewStep(feature, index)) continue;

    final children = _recordFieldWidgets(
      feature,
      record,
      fields: featureStepFields(feature, index),
      sectionNames: featureStepSections(feature, index),
      includeLeftover: false,
    );
    if (children.isNotEmpty) {
      groups.add(
        _RecordFieldGroup(
          label: feature.steps[index].title,
          children: children,
        ),
      );
    }
  }
  return groups.isEmpty ? null : groups;
}

/// Abas por etapa do cadastro original, cada uma com os controles reais
/// (desabilitados) daquela etapa.
class _RecordFieldTabs extends StatefulWidget {
  const _RecordFieldTabs({required this.groups});

  final List<_RecordFieldGroup> groups;

  @override
  State<_RecordFieldTabs> createState() => _RecordFieldTabsState();
}

class _RecordFieldTabsState extends State<_RecordFieldTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    if (groups.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, groups.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSegmentedTabs(
          labels: [for (final group in groups) group.label],
          selectedIndex: index,
          onChanged: (next) => setState(() => _index = next),
        ),
        const SizedBox(height: AppSpacing.space4),
        ...groups[index].children,
      ],
    );
  }
}

List<PrototypeRecord> _recordsWithMinimumSample(
  FeatureDefinition feature,
  List<PrototypeRecord> records,
) {
  const minimumRecords = 6;
  // banco-real (correção de regressão): uma consulta somente leitura sem
  // nenhum registro sincronizado precisa continuar genuinamente vazia — é
  // o único jeito de mostrar o aviso honesto de que o cadastro vem do
  // sistema web, em vez de fabricar 6 registros fingindo que já
  // sincronizou algo que nunca existiu nesta sessão. Ver
  // `mapped_feature_screen_test.dart`, "Áreas mostra estado vazio
  // honesto...".
  if (records.isEmpty && feature.readOnly) return records;
  if (records.length >= minimumRecords) return records;

  final samples = List<PrototypeRecord>.of(records);
  for (var index = samples.length; index < minimumRecords; index++) {
    final number = index + 1;
    final status = PrototypeRecordStatus
        .values[index % PrototypeRecordStatus.values.length];
    samples.add(
      PrototypeRecord(
        id: '${feature.id}-sample-$number',
        title: '${feature.title} · Registro $number',
        description: 'Fazenda Agro Pillathi',
        status: status,
        details: {
          'Fazenda': 'Fazenda Agro Pillathi',
          'Situação': switch (status) {
            PrototypeRecordStatus.active => 'Ativo',
            PrototypeRecordStatus.completed => 'Concluído',
            PrototypeRecordStatus.scheduled => 'Programado',
          },
          'Atualização': '$number dia${number == 1 ? '' : 's'} atrás',
        },
      ),
    );
  }
  return samples;
}

class _FeatureForm extends StatelessWidget {
  const _FeatureForm({
    required this.feature,
    required this.journey,
    required this.onValueChanged,
    required this.onAddCollectionItem,
    required this.onEditCollectionItem,
    required this.onRemoveCollectionItem,
    required this.onCaptureCollectionItem,
  });

  final FeatureDefinition feature;
  final FunctionalJourneyController journey;
  final void Function(String fieldId, String value) onValueChanged;
  final ValueChanged<FeatureCollection> onAddCollectionItem;
  final void Function(FeatureCollection collection, int index)
  onEditCollectionItem;
  final void Function(String group, int index) onRemoveCollectionItem;
  final void Function(String collectionName, String fieldId, String value)
  onCaptureCollectionItem;

  @override
  Widget build(BuildContext context) {
    final simulationTarget = feature.simulationTargetField;
    final simulationCollectionName = feature.simulationCollectionName;
    final stepIndex = journey.stepIndex;
    final step = journey.currentStep;
    final visibleFields = featureStepFields(
      feature,
      stepIndex,
    ).where((field) => field.id != simulationTarget).toList(growable: false);
    final sections = featureStepSections(feature, stepIndex);
    final isReview = isFeatureReviewStep(feature, stepIndex);
    // A simulação de hardware acompanha o campo-alvo, que por invariante de
    // catálogo vive na primeira etapa — repetir o simulador em cada etapa
    // convidaria a capturar duas vezes o mesmo brinco.
    final simulation = journey.isFirstStep ? feature.simulation : null;
    // fidelidade-esteira (onda 13): quando a captura empilha numa coleção, o
    // simulador nunca fica "pronto" com um valor parado na tela — cada
    // leitura já sai direto para a lista, e o campo-alvo (`identificacao`)
    // não existe mais em `feature.fields`/`journey.form.values`.
    final simulationValue =
        simulation == null || simulationCollectionName != null
        ? null
        : journey.form.values[simulationTarget ?? '_hardware'] ?? '';
    final simulationError = journey.form.attempted
        ? featureSimulationError(feature, journey.form)
        : null;
    final simulationCollection = simulationCollectionName == null
        ? null
        : feature.collectionByName(simulationCollectionName);
    final simulationFieldLabel = simulationTarget == null
        ? null
        : (simulationCollection?.fields ?? feature.fields)
              .firstWhere((field) => field.id == simulationTarget)
              .label;
    final simulationFieldPlaceholder = simulationTarget == null
        ? null
        : (simulationCollection?.fields ?? feature.fields)
              .firstWhere((field) => field.id == simulationTarget)
              .placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (simulation != null) ...[
          AppHardwareSimulator(
            kind: _simulationKind(simulation),
            value: simulationValue,
            error: simulationError,
            multiCapture: simulationCollectionName != null,
            manualEntryLabel: simulationFieldLabel,
            manualEntryPlaceholder: simulationFieldPlaceholder,
            onCapture: (value) => simulationCollectionName != null
                ? onCaptureCollectionItem(
                    simulationCollectionName,
                    simulationTarget ?? '_hardware',
                    value,
                  )
                : onValueChanged(simulationTarget ?? '_hardware', value),
          ),
          if (visibleFields.isNotEmpty || sections.isNotEmpty)
            const SizedBox(height: AppSpacing.space4),
        ],
        // Sem `AppCard` em volta dos campos: a folha branca do
        // `AppPageScaffold` já é a superfície do cadastro. O cartão interno
        // duplicava a superfície — branco sobre branco com margem lateral
        // própria —, encolhia a largura útil dos campos e fazia o branco
        // terminar antes da base da tela.
        if (visibleFields.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionTitle(child: Text(step?.title ?? 'Dados do registro')),
              if (step?.hint case final hint?) ...[
                const SizedBox(height: AppSpacing.space1),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpacing.space4),
              for (var index = 0; index < visibleFields.length; index++) ...[
                _FeatureFieldControl(
                  field: visibleFields[index],
                  value: journey.form.values[visibleFields[index].id] ?? '',
                  isRequired: isFeatureFieldRequired(
                    feature,
                    visibleFields[index],
                    journey.form.values,
                  ),
                  error: _fieldError(feature, visibleFields[index], journey),
                  onChanged: (value) =>
                      onValueChanged(visibleFields[index].id, value),
                ),
                if (index < visibleFields.length - 1)
                  const SizedBox(height: AppSpacing.space4),
              ],
            ],
          ),
        if (sections.isNotEmpty) ...[
          if (visibleFields.isNotEmpty || simulation != null)
            const SizedBox(height: AppSpacing.space4),
          // Seção da folha, não cartão: campos, itens vinculados e revisão são
          // três blocos da mesma superfície branca, separados por título e
          // espaço. Empilhar cartões brancos sobre folha branca só multiplica
          // planos de leitura sem separar nada.
          AppFormField(
            label: 'Itens vinculados',
            // fidelidade-campos (onda 0): coleção `min:1` no contrato real
            // agora aparece como campo obrigatório de verdade — antes toda
            // coleção era opcional e um protocolo sem etapa nenhuma podia
            // ser salvo. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
            required: sections.any(
              effectiveRequiredSections(feature, journey.form.values).contains,
            ),
            error: journey.form.attempted
                ? _sectionError(feature, journey, sections)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < sections.length; index++) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.space4),
                  if (feature.collectionByName(sections[index])
                      case final collection?)
                    AppCollectionList(
                      name: collection.name,
                      items: [
                        for (final item in journey.form.itemsOf(
                          collection.name,
                        ))
                          AppCollectionItemView(
                            title: collectionItemTitle(collection, item),
                            subtitle: collectionItemSubtitle(collection, item),
                          ),
                      ],
                      onAdd: () => onAddCollectionItem(collection),
                      onEdit: collection.fields.isEmpty
                          ? null
                          : (item) => onEditCollectionItem(collection, item),
                      onRemove: (item) =>
                          onRemoveCollectionItem(collection.name, item),
                    ),
                ],
              ],
            ),
          ),
        ],
        if (isReview) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionTitle(child: Text(step?.title ?? 'Revisão')),
              if (step?.hint case final hint?) ...[
                const SizedBox(height: AppSpacing.space1),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpacing.space3),
              AppReviewList(
                items: _reviewItems(feature, journey),
                style: AppReviewStyle.inputCapsule,
              ),
              // Coleções na íntegra, item a item — mesma caixa da etapa de
              // preenchimento, só que sem "Adicionar" nem editar/remover
              // (pedido do usuário: a revisão é conferência, não edição).
              for (final collection in feature.collections)
                if (journey.form.itemsOf(collection.name) case final itens
                    when itens.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space4),
                  AppCollectionList(
                    name: collection.name,
                    items: [
                      for (final item in itens)
                        AppCollectionItemView(
                          title: collectionItemTitle(collection, item),
                          subtitle: collectionItemSubtitle(collection, item),
                        ),
                    ],
                  ),
                ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Erro do campo, exibido depois da primeira tentativa ou quando já há valor.
String? _fieldError(
  FeatureDefinition feature,
  FeatureField field,
  FunctionalJourneyController journey,
) {
  final value = journey.form.values[field.id] ?? '';
  if (!journey.form.attempted && value.isEmpty) return null;
  return featureFieldError(feature, field, journey.form.values);
}

/// Primeira coleção obrigatória vazia entre as visíveis nesta etapa.
String? _sectionError(
  FeatureDefinition feature,
  FunctionalJourneyController journey,
  List<String> sections,
) {
  for (final section in effectiveRequiredSections(
    feature,
    journey.form.values,
  )) {
    if (!sections.contains(section)) continue;
    if ((journey.form.groupCounts[section] ?? 0) < 1) {
      return 'Adicione ao menos um item em "$section".';
    }
  }
  return null;
}

/// O que a pessoa já respondeu nos campos simples, na ordem do catálogo. As
/// coleções ("Itens vinculados") não entram aqui — a revisão as mostra com o
/// próprio `AppCollectionList` somente leitura, item a item, em vez de um
/// resumo achatado em texto (ver o `for` de coleções no `build` acima).
List<AppReviewItem> _reviewItems(
  FeatureDefinition feature,
  FunctionalJourneyController journey,
) {
  final values = journey.form.values;
  return [
    for (final field in feature.fields)
      if ((values[field.id]?.trim() ?? '').isNotEmpty)
        AppReviewItem(label: field.label, value: values[field.id]!.trim()),
  ];
}

AppHardwareSimulationKind _simulationKind(HardwareSimulationKind kind) =>
    switch (kind) {
      HardwareSimulationKind.devices => AppHardwareSimulationKind.devices,
      HardwareSimulationKind.scale => AppHardwareSimulationKind.scale,
      HardwareSimulationKind.rfid => AppHardwareSimulationKind.rfid,
      HardwareSimulationKind.scanner => AppHardwareSimulationKind.scanner,
    };

/// Um controle de campo do catálogo. Recebe valor, erro e obrigatoriedade já
/// resolvidos porque serve dois contextos: o formulário do cadastro (onde eles
/// vêm do `FunctionalJourneyController`) e o formulário de **um item de
/// coleção** na folha inferior, que não tem jornada por trás.
class _FeatureFieldControl extends StatelessWidget {
  const _FeatureFieldControl({
    required this.field,
    required this.value,
    required this.isRequired,
    required this.onChanged,
    this.error,
    this.enabled = true,
  });

  final FeatureField field;
  final String value;
  final bool isRequired;
  final String? error;
  final ValueChanged<String> onChanged;

  /// `false` na visualização de um registro já gravado: o mesmo controle do
  /// cadastro, com o valor gravado dentro, desabilitado — não uma lista de
  /// texto à parte. Ver `_recordFieldGroups`/`_recordFieldWidgets`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: field.label,
      required: isRequired,
      error: error,
      child: switch (field.type) {
        FeatureFieldType.select => AppFormSelect(
          value: value.isEmpty ? null : value,
          placeholder: 'Selecione',
          options: field.selectOptions.isNotEmpty
              ? [
                  for (final option in field.selectOptions)
                    AppFormSelectOption(
                      value: option.value,
                      label: option.label,
                    ),
                ]
              : [
                  for (final option in field.options)
                    AppFormSelectOption(value: option, label: option),
                ],
          enabled: enabled,
          onChanged: (next) => onChanged(next ?? ''),
        ),
        // fidelidade-esteira: todo campo de domínio massivo (lote, produto,
        // armazém, centro de custo...) é dropdown com busca em dock, não
        // select simples — `AppSearchSelect` em vez de `AppFormSelect`.
        FeatureFieldType.searchSelect => IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: AppSearchSelect(
              value: value.isEmpty ? null : value,
              label: field.label,
              options: field.selectOptions.isNotEmpty
                  ? [
                      for (final option in field.selectOptions)
                        AppSearchSelectOption(
                          value: option.value,
                          label: option.label,
                        ),
                    ]
                  : [
                      for (final option in field.options)
                        AppSearchSelectOption(value: option, label: option),
                    ],
              onChanged: onChanged,
            ),
          ),
        ),
        FeatureFieldType.textarea => AppTextarea(
          initialValue: value,
          placeholder: field.placeholder,
          enabled: enabled,
          onChanged: onChanged,
        ),
        FeatureFieldType.number => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          invalid: error != null,
          enabled: enabled,
          onChanged: onChanged,
        ),
        // Inteiro: teclado sem casas decimais; a validação do motor recusa
        // valores não-inteiros (ex. `mileage`/hodômetro do SupplyRequest).
        FeatureFieldType.integer => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder,
          keyboardType: TextInputType.number,
          invalid: error != null,
          enabled: enabled,
          onChanged: onChanged,
        ),
        FeatureFieldType.date => AppDateInput(
          initialValue: value.isEmpty ? null : value,
          invalid: error != null,
          enabled: enabled,
          onChanged: onChanged,
        ),
        FeatureFieldType.color => AppColorInput(
          initialValue: value.isEmpty ? null : value,
          palette: field.colorPalette.isEmpty
              ? null
              : [
                  for (final option in field.colorPalette)
                    AppColorOption(value: option.value, label: option.label),
                ],
          invalid: error != null,
          enabled: enabled,
          onChanged: onChanged,
        ),
        // fidelidade-esteira (onda 15): switch de verdade — `value` guarda
        // 'true'/'false' como qualquer outro campo (o motor só conhece
        // `Map<String, String>`), não um booleano nativo.
        FeatureFieldType.boolean => Align(
          alignment: Alignment.centerLeft,
          child: AppToggleSwitch(
            checked: value == 'true',
            onChanged: enabled
                ? (checked) => onChanged(checked.toString())
                : (_) {},
            label: field.label,
            disabled: !enabled,
          ),
        ),
        FeatureFieldType.text || null => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder,
          invalid: error != null,
          enabled: enabled,
          onChanged: onChanged,
        ),
      },
    );
  }
}
