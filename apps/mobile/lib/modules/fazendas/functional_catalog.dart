// Fonte funcional Flutter do AGRO365.
//
// Portado mecanicamente em 16/08/2026 do catálogo React congelado no commit
// 960fe54. A partir da M1, mudanças funcionais entram primeiro neste contrato
// Dart; o catálogo React permanece apenas como evidência histórica até M13.

enum FeatureProfile { administration }

enum FeatureStatus { ready, mapped, hardware }

// fidelidade-contrato (re-auditoria 3ª avaliação): `color` é uma paleta
// FECHADA (`AppColorInput` com `colorPalette`) — a API valida com
// `Rule::enum` (`AreaColor` em `/areas`, `MarkingColorEnum` em `/markings`),
// então hex livre daria 422. A onda 11 tinha lido o dump de produção (150+
// hex em repouso) como "seletor livre", mas isso é dado acumulado, não o
// contrato de escrita novo. Ver [areaColorPalette]/[markingColorPalette].
// fidelidade-esteira (onda 15): `boolean` é um switch de verdade
// (`AppToggleSwitch`), não mais simulado com `select` Sim/Não —
// `has_lot`/`is_equipment`/`is_enabled`/`control_stock`/`allow_pointing` em
// `consulta-produtos` são a primeira aplicação real.
// fidelidade-esteira: `searchSelect` é um `select` com busca (`AppSearchSelect`)
// em vez de dropdown simples (`AppFormSelect`) — todo campo de Lote usa este
// tipo, nunca `select` puro nem texto livre (pedido explícito do usuário).
enum FeatureFieldType {
  text,
  number,
  // fidelidade-contrato (re-auditoria 3ª avaliação): `integer` distingue o
  // número inteiro (ex. `mileage`/hodômetro no `SupplyRequest`) do decimal
  // (`number`) — só dígitos, sem casas decimais.
  integer,
  date,
  select,
  searchSelect,
  textarea,
  color,
  boolean,
}

enum HardwareSimulationKind { devices, scale, rfid, scanner }

enum AuditExportKind { estoque, pecuaria }

class FeatureField {
  const FeatureField({
    required this.id,
    required this.label,
    this.type,
    this.isRequired = false,
    this.placeholder,
    this.options = const [],
    this.colorPalette = const [],
    this.selectOptions = const [],
  });

  final String id;
  final String label;
  final FeatureFieldType? type;
  final bool isRequired;
  final String? placeholder;
  final List<String> options;

  /// Opções value/label de um `select`/`searchSelect` cujo VALOR emitido
  /// difere do rótulo exibido — espelho de um enum backed da API (ex.
  /// `WeaningType` 1/2, `AnimalIdentificationMode` single/no_id,
  /// `type_payment` código ≤2). Vazio mantém [options] (value == label). O
  /// `state` guarda o valor; a exibição resolve o rótulo via
  /// [featureFieldDisplay].
  final List<({String value, String label})> selectOptions;

  /// Paleta fechada de um campo `FeatureFieldType.color`. Quando não-vazia,
  /// o campo só aceita estas cores (espelho de um enum de cor da API, ex.
  /// `AreaColor`/`MarkingColorEnum`) e submete o `value` hex EXATO — vazia
  /// mantém o comportamento de hex livre.
  final List<({String value, String label})> colorPalette;
}

/// Rótulo de exibição de um valor armazenado: resolve
/// [FeatureField.selectOptions]/[FeatureField.colorPalette] (value → label)
/// quando o valor emitido difere do rótulo. Fora esses casos, devolve o
/// próprio valor. O `state` sempre guarda o valor (para submissão/round-trip);
/// só a apresentação usa o rótulo.
String featureFieldDisplay(FeatureField field, String value) {
  for (final option in field.selectOptions) {
    if (option.value == value) return option.label;
  }
  for (final option in field.colorPalette) {
    if (option.value == value) return option.label;
  }
  return value;
}

/// Paleta fechada de `Area` — espelho EXATO de `App\Enums\AreaColor`
/// (`GB.Cerne.Api/app/Enums/AreaColor.php`, 14 cores, hex minúsculo).
/// `AreaRequest::rules()` valida `color` com `Rule::enum(AreaColor)`, logo
/// hex livre (o antigo `AppColorInput` sem paleta) dava 422. Valores verbatim
/// — NÃO normalizar case.
const List<({String value, String label})> areaColorPalette = [
  (value: '#ffffff', label: 'Branco'),
  (value: '#0074d9', label: 'Azul'),
  (value: '#000000', label: 'Preto'),
  (value: '#2ecc40', label: 'Verde'),
  (value: '#ffdc00', label: 'Amarelo'),
  (value: '#ff4136', label: 'Vermelho'),
  (value: '#aaaaaa', label: 'Cinza'),
  (value: '#dddddd', label: 'Cinza Claro'),
  (value: '#7fdbff', label: 'Azul Claro'),
  (value: '#001f3f', label: 'Azul Escuro'),
  (value: '#39cccc', label: 'Turquesa'),
  (value: '#3d9970', label: 'Verde Escuro'),
  (value: '#01ff70', label: 'Verde Claro'),
  (value: '#ff851b', label: 'Laranja'),
];

/// Paleta fechada de `Marking` — espelho EXATO de `App\Enums\MarkingColorEnum`
/// (`GB.Cerne.Api/app/Enums/MarkingColorEnum.php`, 16 cores). Case É
/// SIGNIFICATIVO: 5 valores são MAIÚSCULOS (`#FF99FF`, `#FF69B4`, `#FBE7A1`,
/// `#00008B`, `#003366`) e `Rule::enum(MarkingColorEnum)` faz match exato de
/// string — normalizar case quebra a submissão (422). Distinta de
/// [areaColorPalette]: `/markings` NÃO usa `AreaColor`.
const List<({String value, String label})> markingColorPalette = [
  (value: '#ffee58', label: 'Amarelo'),
  (value: '#81d4fa', label: 'Azul claro'),
  (value: '#e0e0e0', label: 'Branco'),
  (value: '#a1887f', label: 'Marrom'),
  (value: '#212121', label: 'Preto'),
  (value: '#ec407a', label: 'Rosa'),
  (value: '#8e24aa', label: 'Roxo'),
  (value: '#4caf50', label: 'Verde'),
  (value: '#d32f2f', label: 'Vermelho'),
  (value: '#FF99FF', label: 'Rosa Claro'),
  (value: '#FF69B4', label: 'Rosa Pink'),
  (value: '#FBE7A1', label: 'Palha'),
  (value: '#00008B', label: 'Azul Escuro'),
  (value: '#003366', label: 'Azul Marinho'),
  (value: '#f75900', label: 'Laranja'),
  (value: '#0072c0', label: 'Azul Royal'),
];

/// Uma coleção de itens de um cadastro — `items[]`, `products[]`,
/// `identifications[]` e companhia no contrato real.
///
/// Antes da onda 8 uma coleção era só um nome numa lista de `String`, e o
/// motor genérico a tratava como contador: "Adicionar" incrementava um número
/// e nada mais. Servia para documentar que a coleção existe, não para
/// registrar o que ela contém — e as coleções são justamente o conteúdo real
/// de vários cadastros (a agenda do protocolo, os animais diagnosticados, os
/// insumos consumidos no manejo).
///
/// Com [fields] preenchido, cada "Adicionar" abre um formulário de item e a
/// linha entra na lista com os dados verdadeiros. Sem [fields], o
/// comportamento antigo de contador é preservado — é o caso das duas "seções"
/// de `processamentos`, que são rótulos de agrupamento, não coleções.
class FeatureCollection {
  const FeatureCollection({
    required this.name,
    this.itemLabel,
    this.fields = const [],
    this.isRequired = false,
    this.titleField,
    this.subtitleFields = const [],
  });

  /// Nome da coleção, como aparece na tela e no contrato ("Insumos").
  final String name;

  /// Título do formulário de um item ("Insumo"). Ausente, a tela usa [name].
  final String? itemLabel;

  /// Campos de **um item**. Vazio = coleção-contador (comportamento anterior).
  final List<FeatureField> fields;

  /// A coleção é `min:1` no contrato: salvar sem nenhum item não registra
  /// nada e o backend recusa.
  final bool isRequired;

  /// Campo que titula a linha da lista. Ausente, usa o primeiro de [fields].
  final String? titleField;

  /// Campos que compõem o resumo da linha, na ordem, separados por " · ".
  final List<String> subtitleFields;
}

/// Uma etapa do formulário longo — o arquétipo `Cadastro steps` do Figma
/// (`54349:1990`), que até aqui só existia nos fluxos dedicados de campo
/// (`FlowShell.totalSteps`) e não no motor genérico de cadastros.
///
/// Cada etapa nomeia um subconjunto dos [FeatureDefinition.fields] (por `id`)
/// e/ou das [FeatureDefinition.sections] (por nome). Uma etapa **sem** campos e
/// sem coleções é a etapa de revisão: a tela mostra ali o que foi preenchido,
/// antes de salvar.
///
/// Invariante conferida em `functional_catalog_test.dart`: quando uma
/// funcionalidade declara etapas, todo campo visível e toda coleção aparecem em
/// exatamente uma etapa — nada pode ficar inalcançável.
class FeatureFormStep {
  const FeatureFormStep({
    required this.title,
    this.fields = const [],
    this.sections = const [],
    this.hint,
  });

  /// Título da etapa, exibido no lugar de "Dados do registro".
  final String title;

  /// `id`s de [FeatureField] desta etapa, na ordem de exibição.
  final List<String> fields;

  /// Nomes de coleção ([FeatureDefinition.sections]) desta etapa.
  final List<String> sections;

  /// Uma linha de orientação sob o título — o que a pessoa precisa ter em mãos
  /// para vencer a etapa.
  final String? hint;
}

class FeatureDefinition {
  const FeatureDefinition({
    required this.id,
    required this.profile,
    required this.group,
    required this.title,
    required this.objective,
    required this.status,
    this.existingRoute,
    this.fields = const [],
    this.collections = const [],
    this.capabilities = const [],
    this.primaryAction,
    this.emptyLabel,
    this.sourceDetail,
    this.listMode = false,
    this.readOnly = false,
    this.dataSourceId,
    this.createAction,
    this.recordTitleField,
    this.recordDescriptionFields = const [],
    this.simulation,
    this.simulationTargetField,
    this.simulationCollectionName,
    this.successTitle,
    this.successDescription,
    this.auditExport,
    this.steps = const [],
  });

  final String id;
  final FeatureProfile profile;
  final String group;
  final String title;
  final String objective;
  final FeatureStatus status;
  final String? existingRoute;
  final List<FeatureField> fields;

  /// Coleções de itens da funcionalidade (onda 8). Ver [FeatureCollection].
  final List<FeatureCollection> collections;

  /// Nomes das coleções, na ordem — a forma como o resto do app sempre leu
  /// esta informação (etapas, motor, testes congelados). Derivado de
  /// [collections] desde a onda 8, para que exista uma fonte só.
  List<String> get sections => [
    for (final collection in collections) collection.name,
  ];

  /// Coleções `min:1` no contrato real.
  List<String> get requiredSections => [
    for (final collection in collections)
      if (collection.isRequired) collection.name,
  ];

  FeatureCollection? collectionByName(String name) {
    for (final collection in collections) {
      if (collection.name == name) return collection;
    }
    return null;
  }

  final List<String> capabilities;
  final String? primaryAction;
  final String? emptyLabel;
  final String? sourceDetail;
  final bool listMode;
  // banco-real (onda 1): torna explícito que uma funcionalidade é consulta —
  // sem virar edição em campo — mesmo mantendo `fields` preenchidos. Antes,
  // a única forma de virar consulta era esvaziar `fields`, o que jogaria fora
  // a documentação dos campos reais do sistema mapeados no banco (valiosa
  // para quando o backend for ligado). Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  final bool readOnly;
  final String? dataSourceId;
  final String? createAction;
  final String? recordTitleField;
  final List<String> recordDescriptionFields;
  final HardwareSimulationKind? simulation;
  final String? simulationTargetField;

  // fidelidade-esteira (onda 13): `animal_transfer_animal_farm` no dump é
  // pivô puro (`animal_id`, `transfer_animal_farm_id`) — o contrato real
  // aceita destino por animal, não um destino único para o lote inteiro.
  // Quando preenchido, a captura de hardware (RFID/scanner) não sobrescreve
  // mais um campo escalar de [simulationTargetField]: ela empilha um item
  // nesta coleção, com [simulationTargetField] como o `id` do campo do item
  // que recebe o valor capturado. Só `transferencia-animal` usa isto hoje.
  final String? simulationCollectionName;
  final String? successTitle;
  final String? successDescription;
  final AuditExportKind? auditExport;

  /// Etapas do formulário (fidelidade-campos, onda 0). Vazio = formulário de
  /// rolagem única, comportamento anterior. Preenchido, o motor genérico passa
  /// a paginar o cadastro e a validar etapa a etapa — usado só nos formulários
  /// longos, onde a rolagem única escondia o fim do preenchimento. Ver
  /// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
  final List<FeatureFormStep> steps;

}

// banco-real: única fonte de nomes de produto para todo o catálogo — espelha
// o cadastro real de `consulta-produtos` (fonte: `products`, 543.983 linhas no
// dump gbcerne). Todo campo "produto"/"matéria-prima" abaixo busca aqui; só a
// tela Produtos cria um item novo em campo livre. Ver
// docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
const catalogoProdutos = <String>[
  'Ração Engorda 18%',
  'Sal Mineral Proteinado',
  'Vacina Aftosa',
  'Vermífugo Injetável',
  'Diesel S10',
  'Semente de Braquiária',
  'Fertilizante NPK 20-05-20',
  'Filtro de óleo — trator',
];

// Onda 8 — domínios compartilhados pelos **itens** de coleção. Mesmo critério
// de `catalogoProdutos` acima: quando o mesmo domínio real aparece em mais de
// uma coleção (unidade de medida, armazém, centro de custo, modo de
// identificação animal), ele mora num lugar só. Ver
// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 8.
const catalogoUnidades = <String>['kg', 't', 'L', 'Saco', 'Unidade'];

const catalogoArmazens = <String>['Armazém A', 'Depósito B', 'Farmácia'];

const catalogoCentrosCusto = <String>[
  'Centro Agrícola',
  'Centro Pecuária',
  'Centro Frota',
];

const catalogoResponsaveis = <String>[
  'João Oliveira',
  'Maria Souza',
  'Carlos Dias',
];

const catalogoIdentificacaoAnimal = <String>[
  'Brinco',
  'RFID',
  'SISBOV',
  'Tatuagem',
];

const catalogoCategoriasAnimais = <String>[
  'Bezerro',
  'Novilha',
  'Vaca',
  'Boi',
];

const catalogoEquipamentos = <String>[
  'Trator John Deere 6110',
  'Colheitadeira CR7',
  'Caminhão Boiadeiro',
  'Pulverizador',
  'Grade Aradora',
];

// fidelidade-campos (onda 9 — re-auditoria 11/09): `stock_uuid` é o lote de
// estoque de um produto já recebido (o `ItemEstoque` do módulo Armazém), não
// o produto em si — `produto`/`materia-prima` seguem apontando para
// `catalogoProdutos`. Compartilhado por `pastagens.inputs[]`,
// `sanitario.items[]` e `monta-natural.simplified_animals[]`. Ver
// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 9.
const catalogoItensEstoque = <String>[
  'Ração Engorda 18% — Lote 2026-07-A',
  'Sal Mineral Proteinado — Lote 2026-06-C',
  'Vermífugo Injetável — Lote 2026-05-B',
  'Diesel S10 — Lote 2026-08-A',
];

// fidelidade-contrato (onda 3): categoria C da re-auditoria de 14/09 — o
// contrato exige UUID de catálogo (`exists` tenant-scoped) onde o protótipo
// captura texto livre. Sem persistência real, o protótipo não tem UUID de
// verdade; a correção é de forma — texto livre vira `select` sobre um
// domínio real, mesmo critério de `catalogoItensEstoque` acima. Compartilhado
// por `desmama`, `apartacao` e `transferencia-animal` (só
// lote-atual/novo-lote — a identificação do animal continua texto: é o
// campo-alvo da simulação de RFID). Ver
// docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 3.
const catalogoLotes = <String>[
  'Lote Recria 02',
  'Lote Engorda 05',
  'Lote Matrizes 01',
  'Lote Receptoras 03',
];

// fidelidade-contrato (re-auditoria pós-fix): catálogos fechados para FKs que
// ainda eram texto livre — dropdown de conjunto conhecido em vez de campo
// aberto. O valor emitido segue sendo o rótulo (③ uuid×rótulo só some com
// persistência), mas o campo deixa de aceitar texto arbitrário.
const catalogoAreas = <String>[
  'Talhão 01',
  'Talhão 02',
  'Talhão 03',
  'Pasto Norte',
  'Pasto Sul',
  'Reserva Legal',
];
const catalogoModulos = <String>[
  'Módulo A',
  'Módulo B',
  'Módulo C',
];
const catalogoEstacoesMonta = <String>[
  'Estação 2025/2026',
  'Estação 2026/2027',
];
const catalogoTouros = <String>[
  'Touro Nelore 4210',
  'Touro Angus 1180',
  'Touro Brahman 3055',
];

// Compartilhado por `compras-animais` (fornecedor e vendedor).
const catalogoFornecedores = <String>[
  'Fazenda Boa Vista',
  'Corretora Campo Alto',
  'Central de Genética Boa Vista',
  'Fazenda São Pedro',
  'Agropecuária Vale Verde',
];

// fidelidade-esteira (onda 15): domínios novos da expansão fiscal de
// `consulta-produtos` — curadoria representativa (mesmo critério das listas
// acima), não o domínio federal/tributário inteiro. `group_uuid` é uma FK
// distinta de `category_uuid` (`categoria`, já existente): grupo é a
// classificação contábil/fiscal do produto, categoria é a classificação
// operacional (Nutrição, Sanitário...) já usada pelo resto do catálogo.
const catalogoGruposProdutos = <String>[
  'Insumo agropecuário',
  'Matéria-prima',
  'Peça e equipamento',
  'Combustível e lubrificante',
  'Produto acabado',
  // fidelidade-contrato (re-auditoria 3ª avaliação): o grupo "Produção"
  // (`GroupProduct::PRODUCTION_GROUP_ID`, seed 8, description = 'Produção')
  // é o que torna `cultivation_uuid`/`ncm_uuid` obrigatórios no
  // `ProductRequest`. Faltava na lista — sem ele o gate condicional nunca
  // dispararia. O rótulo precisa ser exatamente 'Produção' (usado pela
  // condição em functional_journey_engine.dart).
  'Produção',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): cultivos (lavouras) —
// destino de `cultivation_uuid` em `consulta-produtos`, required quando o
// grupo é 'Produção'. Lista mock por instância de cultivo (safra + área),
// análoga ao FK `cultivations` do contrato.
const catalogoCultivos = <String>[
  'Soja 2025/2026 — Talhão 01',
  'Milho 2ª safra 2025/2026 — Talhão 02',
  'Algodão 2025/2026 — Pivô Central',
  'Café 2025/2026 — Setor Sul',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): estágios reprodutivos de
// matriz (FK `category_matrices` de `category_matrice_id` em /animals). Lista
// mock por instância; o gate required_if (RN-6) fica como follow-up.
const catalogoEstagiosReprodutivos = <String>[
  'Novilha de reposição',
  'Matriz em serviço',
  'Matriz descarte',
  'Doadora',
  'Receptora',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): causas de perda/morte (FK
// `death_losses` de `cause_uuid`). Lista fechada mock — melhora sobre o texto
// livre (que nunca casaria no `exists`); o mapeamento para uuid é ③.
const catalogoCausasPerda = <String>[
  'Doença',
  'Predação',
  'Acidente',
  'Intoxicação',
  'Parto',
  'Causa desconhecida',
];

const catalogoNcm = <String>[
  '2309.90.90 — Preparações para alimentação animal',
  '3808.91.90 — Inseticidas',
  '3004.90.99 — Medicamentos veterinários',
  '2710.19.21 — Óleo diesel',
  '3105.20.10 — Adubos NPK',
];

const catalogoCategoriasFinanceiras = <String>[
  'Insumos agrícolas',
  'Insumos pecuários',
  'Manutenção e peças',
  'Combustíveis',
  'Ativo imobilizado',
];

// CST/CSOSN do Simples Nacional e do regime normal convivem na mesma coluna
// no dump (`products.cst_csosn`) — curadoria dos códigos mais comuns dos dois
// regimes, não a tabela CST completa.
const catalogoCstCsosn = <String>[
  '00 — Tributada integralmente',
  '20 — Com redução de base de cálculo',
  '40 — Isenta',
  '60 — ICMS cobrado por substituição tributária',
  '102 — Simples Nacional, sem permissão de crédito',
  '500 — ICMS cobrado anteriormente por ST (Simples Nacional)',
];

const catalogoCstPisCofins = <String>[
  '01 — Tributável, alíquota básica',
  '04 — Tributável, alíquota zero',
  '06 — Tributável, alíquota zero (monofásica)',
  '07 — Isenta',
  '08 — Sem incidência',
  '49 — Outras operações de saída',
];

const catalogoCstIpi = <String>[
  '00 — Entrada tributada com alíquota zero',
  '49 — Outras entradas',
  '50 — Saída tributada',
  '99 — Outras saídas',
];

const catalogoCfop = <String>[
  '5102 — Venda de mercadoria dentro do estado',
  '6102 — Venda de mercadoria fora do estado',
  '5101 — Venda de produção do estabelecimento',
  '6101 — Venda de produção fora do estado',
];

const catalogoOrigemMercadoria = <String>[
  '0 — Nacional',
  '1 — Estrangeira, importação direta',
  '2 — Estrangeira, adquirida no mercado interno',
  '3 — Nacional, conteúdo de importação acima de 40%',
  '5 — Nacional, conteúdo de importação até 40%',
];

// fidelidade-esteira (onda 15): campos da reforma tributária (IBS/CBS/IS) —
// muitos e recentes no dump; curadoria mínima só para não deixar o bloco
// vazio, sem pretensão de cobrir a tabela completa do novo regime.
const catalogoCstIbsCbs = <String>[
  '000 — Tributação integral',
  '200 — Alíquota reduzida',
  '400 — Imunidade',
  '800 — Suspensão',
];

const adminFeatures = <FeatureDefinition>[
  // Auditoria dos painéis (docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2):
  // `painel-pecuario` fundiu aqui. Os dois painéis mostravam o mesmo P&L e o
  // bloco produtivo da Pecuária estava desativado por falta de dado — dado que
  // existe em Confinamento e passou a ser servido por `lotacao-currais`.
  FeatureDefinition(
    id: 'painel-financeiro',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Resultado',
    objective:
        'Consolidar receita, custo, margem e posição financeira por período.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/resultado',
  ),
  FeatureDefinition(
    id: 'lotacao-currais',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Rebanho e confinamento',
    objective:
        'Supervisionar ocupação, desempenho do lote (GMD) e alertas dos currais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/confinamento',
  ),
  FeatureDefinition(
    id: 'suprimentos',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Suprimentos',
    objective: 'Comparar cotações e apoiar decisões de compra.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/suprimentos',
  ),
  FeatureDefinition(
    id: 'ativos',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Ativos e depreciação',
    objective: 'Acompanhar patrimônio, manutenção e valor residual.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/ativos',
  ),
  FeatureDefinition(
    id: 'analise-uso',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Adoção e governança',
    objective:
        'Supervisionar usuários ativos, utilização por fazenda e trilha de auditoria.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/uso',
  ),
  FeatureDefinition(
    id: 'consultas-gerenciais',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Consultas gerenciais',
    objective: 'Consultar lotes, estoque e pesagens sem permitir alterações.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/consultas/gerenciais',
  ),
  // TODO(banco-real): quando esta consulta ganhar filtro por tipo/classificação
  // de movimento, checar `stocks.type`/`stock_movements.classification` — sem
  // tabela de domínio no dump; hoje esta tela ainda não expõe esse filtro.
  // Ver docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
  FeatureDefinition(
    id: 'saldo-estoque',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Saldo de estoque',
    objective: 'Consultar o saldo disponível dos itens armazenados.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhum item de estoque encontrado.',
    sourceDetail:
        'Consulta demonstrativa consolidada por item e local de armazenamento.',
    listMode: true,
  ),
  // banco-real (onda 2): `products` é a maior tabela do dump gbcerne (543.983
  // linhas) e não tinha nenhuma tela própria — só aparecia embutida como select
  // em outras funcionalidades. Ver
  // docs/ajustes-banco-real/02-oportunidades-banco-real.md, seção 2.6.
  FeatureDefinition(
    id: 'consulta-produtos',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Produtos',
    objective:
        'Consultar e cadastrar o catálogo de produtos, categorias e custo médio.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhum produto encontrado para os filtros atuais.',
    sourceDetail:
        'Única tela que cria produto em campo livre — Formulações, Batida, Carga e Descarga '
        'buscam neste catálogo em vez de digitar o nome.',
    // banco-real: única superfície de criação de produto (campo livre). Todo
    // outro campo "produto" do catálogo busca em `catalogoProdutos` acima, em
    // vez de aceitar texto livre — fonte real: `products` (543.983 linhas).
    //
    // fidelidade-esteira (onda 15): expansão completa dos ~40 campos fiscais
    // do contrato de escrita real (`POST /products`, 72 colunas no dump),
    // fechando o que a onda 9 só documentou. Quatro `FeatureFieldType.boolean`
    // novos (`has-lot`/`is-equipment`/`is-enabled`/`control-stock`, os 4 dos
    // 6 required que são booleanos de verdade — `control_stock` é
    // `smallint`, mesma família) e `group-uuid`/`las-price`, os outros 2
    // required. `categoria`/`unidade` já eram `select` sobre um domínio
    // (Categoria C fechada antes desta onda); `group-uuid` é uma FK
    // **distinta** de categoria (classificação contábil/fiscal, não
    // operacional). Campos organizados em etapas (arquétipo `Cadastro
    // steps`), mesmo padrão dos fluxos dedicados — 39 campos numa rolagem só
    // esconderia o fim do formulário. Ver
    // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 15.
    fields: [
      FeatureField(
        id: 'nome-produto',
        label: 'Nome do produto',
        isRequired: true,
        placeholder: 'Ex.: Ração Engorda 18%',
      ),
      FeatureField(
        id: 'group-uuid',
        label: 'Grupo do produto',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoGruposProdutos,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `cultivation_uuid` é
      // `required_if` grupo = Produção no `ProductRequest`. Não é obrigatório
      // estático — a exigência condicional vive em
      // functional_journey_engine.dart (mesma via de `ncm-uuid`).
      FeatureField(
        id: 'cultivation-uuid',
        label: 'Cultivo (lavoura)',
        type: FeatureFieldType.searchSelect,
        options: catalogoCultivos,
      ),
      FeatureField(
        id: 'categoria',
        label: 'Categoria',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Nutrição',
          'Sanitário',
          'Combustível',
          'Agrícola',
          'Peça de equipamento',
        ],
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade de medida',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['kg', 't', 'L', 'unidade', 'saca', 'dose', 'frasco'],
      ),
      FeatureField(
        id: 'barcode',
        label: 'Código de barras',
        placeholder: 'EAN/GTIN',
      ),
      FeatureField(
        id: 'reference',
        label: 'Código de referência interno',
      ),
      FeatureField(
        id: 'active-principle',
        label: 'Princípio ativo',
        placeholder: 'Produtos sanitários/veterinários',
      ),
      // Estoque e controle — `has_lot`/`is_equipment`/`is_enabled`/
      // `control_stock` são os 4 required booleanos; `allow_pointing` é
      // opcional, mesma família de tipo (smallint no dump).
      FeatureField(
        id: 'has-lot',
        label: 'Controla lote',
        type: FeatureFieldType.boolean,
        isRequired: true,
      ),
      FeatureField(
        id: 'is-equipment',
        label: 'É equipamento',
        type: FeatureFieldType.boolean,
        isRequired: true,
      ),
      FeatureField(
        id: 'is-enabled',
        label: 'Produto ativo',
        type: FeatureFieldType.boolean,
        isRequired: true,
      ),
      FeatureField(
        id: 'control-stock',
        label: 'Controla estoque',
        type: FeatureFieldType.boolean,
        isRequired: true,
      ),
      FeatureField(
        id: 'allow-pointing',
        label: 'Permite apontamento',
        type: FeatureFieldType.boolean,
      ),
      FeatureField(
        id: 'default-warehouse-uuid',
        label: 'Armazém padrão',
        type: FeatureFieldType.searchSelect,
        options: catalogoArmazens,
      ),
      FeatureField(
        id: 'default-cost-center-uuid',
        label: 'Centro de custo padrão',
        type: FeatureFieldType.searchSelect,
        options: catalogoCentrosCusto,
      ),
      FeatureField(
        id: 'min-stock',
        label: 'Estoque mínimo',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'custo-medio',
        label: 'Custo médio (R\$)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'las-price',
        label: 'Último preço de compra (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'purchase-price',
        label: 'Preço de compra (R\$)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'market-price',
        label: 'Preço de mercado (R\$)',
        type: FeatureFieldType.number,
      ),
      // Tributação — NCM, CFOP, CST/CSOSN e percentuais de ICMS/PIS/COFINS/
      // IPI do regime tributário atual.
      FeatureField(
        id: 'ncm-uuid',
        label: 'NCM',
        type: FeatureFieldType.select,
        options: catalogoNcm,
      ),
      FeatureField(
        id: 'financial-category-uuid',
        label: 'Categoria financeira',
        type: FeatureFieldType.searchSelect,
        options: catalogoCategoriasFinanceiras,
      ),
      FeatureField(
        id: 'cfop-saida-interno',
        label: 'CFOP saída — dentro do estado',
        type: FeatureFieldType.select,
        options: catalogoCfop,
      ),
      FeatureField(
        id: 'cfop-saida-externo',
        label: 'CFOP saída — fora do estado',
        type: FeatureFieldType.select,
        options: catalogoCfop,
      ),
      FeatureField(
        id: 'cst-csosn',
        label: 'CST/CSOSN',
        type: FeatureFieldType.select,
        options: catalogoCstCsosn,
      ),
      FeatureField(
        id: 'cst-pis',
        label: 'CST PIS',
        type: FeatureFieldType.select,
        options: catalogoCstPisCofins,
      ),
      FeatureField(
        id: 'cst-cofins',
        label: 'CST COFINS',
        type: FeatureFieldType.select,
        options: catalogoCstPisCofins,
      ),
      FeatureField(
        id: 'cst-ipi',
        label: 'CST IPI',
        type: FeatureFieldType.select,
        options: catalogoCstIpi,
      ),
      FeatureField(
        id: 'perc-icms',
        label: '% ICMS',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'perc-pis',
        label: '% PIS',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'perc-cofins',
        label: '% COFINS',
        type: FeatureFieldType.number,
      ),
      FeatureField(id: 'perc-ipi', label: '% IPI', type: FeatureFieldType.number),
      FeatureField(
        id: 'origem',
        label: 'Origem da mercadoria',
        type: FeatureFieldType.select,
        options: catalogoOrigemMercadoria,
      ),
      FeatureField(
        id: 'cest',
        label: 'CEST',
        placeholder: '7 dígitos',
      ),
      // Reforma tributária (IBS/CBS/IS) — campos recentes e numerosos no
      // dump; curadoria mínima (`catalogoCstIbsCbs`), não a tabela completa
      // do novo regime. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 15.
      FeatureField(
        id: 'cst-ibs-cbs',
        label: 'CST IBS/CBS',
        type: FeatureFieldType.select,
        options: catalogoCstIbsCbs,
      ),
      FeatureField(
        id: 'perc-ibs-uf',
        label: '% IBS (UF)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'perc-ibs-mun',
        label: '% IBS (Município)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'perc-cbs',
        label: '% CBS',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'cst-is',
        label: 'CST Imposto Seletivo',
        type: FeatureFieldType.select,
        options: catalogoCstIbsCbs,
      ),
      FeatureField(
        id: 'perc-is',
        label: '% Imposto Seletivo',
        type: FeatureFieldType.number,
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Dados básicos',
        hint: 'Identificação do produto no catálogo.',
        fields: [
          'nome-produto',
          'group-uuid',
          'cultivation-uuid',
          'categoria',
          'unidade',
          'barcode',
          'reference',
          'active-principle',
        ],
      ),
      FeatureFormStep(
        title: 'Estoque e controle',
        hint: 'Como o produto se comporta no estoque e no apontamento.',
        fields: [
          'has-lot',
          'is-equipment',
          'is-enabled',
          'control-stock',
          'allow-pointing',
          'default-warehouse-uuid',
          'default-cost-center-uuid',
          'min-stock',
          'custo-medio',
          'las-price',
          'purchase-price',
          'market-price',
        ],
      ),
      FeatureFormStep(
        title: 'Tributação',
        hint: 'NCM, CFOP, CST/CSOSN e percentuais do regime atual.',
        fields: [
          'ncm-uuid',
          'financial-category-uuid',
          'cfop-saida-interno',
          'cfop-saida-externo',
          'cst-csosn',
          'cst-pis',
          'cst-cofins',
          'cst-ipi',
          'perc-icms',
          'perc-pis',
          'perc-cofins',
          'perc-ipi',
          'origem',
          'cest',
        ],
      ),
      FeatureFormStep(
        title: 'Reforma tributária',
        hint: 'Campos do IBS/CBS/Imposto Seletivo.',
        fields: [
          'cst-ibs-cbs',
          'perc-ibs-uf',
          'perc-ibs-mun',
          'perc-cbs',
          'cst-is',
          'perc-is',
        ],
      ),
      FeatureFormStep(title: 'Revisão'),
    ],
    primaryAction: 'Salvar produto',
    listMode: true,
    createAction: 'Novo produto',
    recordTitleField: 'nome-produto',
    recordDescriptionFields: ['categoria', 'unidade'],
  ),
  FeatureDefinition(
    id: 'areas',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Áreas cadastradas',
    objective: 'Consultar as áreas usadas pelos processos da fazenda.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhuma área encontrada para os filtros atuais.',
    sourceDetail:
        'A consulta usa os mesmos registros criados no ambiente operacional.',
    listMode: true,
    dataSourceId: 'cadastrar-area',
  ),
  // fidelidade-campos (onda 4): `lotes-reproducao` volta ao catálogo, mas do
  // lado administrativo e somente leitura. A avaliação de 360f0f8 continua
  // valendo — vincular lote à estação de monta é organização estrutural, não
  // execução de campo —, e a lacuna era outra: tirar do catálogo apagou
  // também a documentação do contrato `/breeding-batches`, que a auditoria de
  // fidelidade audita. Como consulta, o vínculo volta a ser visível no app sem
  // reabrir o cadastro no celular. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md,
  // Onda 4.
  FeatureDefinition(
    id: 'lotes-reproducao',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Lotes / reprodução',
    objective: 'Consultar lotes vinculados ao processo reprodutivo.',
    status: FeatureStatus.ready,
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // Os dois escalares required de `/breeding-batches` que faltavam.
      FeatureField(id: 'codigo', label: 'Código', isRequired: true),
      FeatureField(
        id: 'data',
        label: 'Data do vínculo',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-campos (onda 9 — re-auditoria 11/09): `description` é
      // required no POST de `/breeding-batches` e era o único required ainda
      // faltando desta leva — ficou de fora quando `codigo`/`data` entraram.
      FeatureField(id: 'descricao', label: 'Descrição', isRequired: true),
      FeatureField(
        id: 'estacao',
        label: 'Estação de monta',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoEstacoesMonta,
      ),
      // fidelidade-contrato (onda 4): o contrato real é `batch_uuids[]`
      // (array de UUID, min:1) — este escalar permanece só para título e
      // descrição do registro nesta consulta (remover exigiria redesenhar
      // `recordTitleField`, fora do escopo desta onda); a coleção abaixo
      // documenta a cardinalidade correta. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 4.
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'finalidade',
        label: 'Finalidade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Matrizes', 'Reprodutores', 'Receptoras', 'Novilhas'],
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
    ],
    // `batch_uuids[]` — o vínculo é com um ou mais lotes, não um escalar.
    collections: [
      FeatureCollection(
        name: 'Lotes vinculados',
        itemLabel: 'Lote',
        isRequired: true,
        titleField: 'lote',
        fields: [
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoLotes,
          ),
        ],
      ),
    ],
    emptyLabel: 'Nenhum lote vinculado à reprodução.',
    sourceDetail:
        'Consulta demonstrativa dos vínculos de lote e estação de monta.',
    listMode: true,
    recordTitleField: 'lote',
    recordDescriptionFields: ['finalidade', 'estacao', 'data'],
  ),
  FeatureDefinition(
    id: 'processamentos',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Processamentos pecuários',
    objective: 'Acompanhar rotinas pendentes e concluídas.',
    status: FeatureStatus.ready,
    collections: [
      FeatureCollection(name: 'Pendentes'),
      FeatureCollection(name: 'Concluídos'),
    ],
    emptyLabel: 'Nenhum processamento pendente.',
    listMode: true,
  ),
  // banco-real (onda 1): compra e venda de animais são decisão comercial/
  // financeira (fornecedor/cliente, valor, documento fiscal) — sobem do
  // operacional para o ADM, que só visualiza; a decisão desce como ordem
  // para o Operacional confirmar a execução, igual ao padrão `OrdemPendente`
  // já implementado em `confinamento/models.dart`. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  FeatureDefinition(
    id: 'compras-animais',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Compra de animais',
    objective: 'Consultar compras de animais registradas.',
    status: FeatureStatus.ready,
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // fidelidade-contrato (onda 3): `provider_uuid` é FK no contrato real
      // de `/movement-purchases` — texto livre não referencia nada. Vira
      // `select` sobre `catalogoFornecedores`, mesmo domínio de `vendedor`
      // abaixo. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 3.
      FeatureField(
        id: 'fornecedor',
        label: 'Fornecedor',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoFornecedores,
      ),
      FeatureField(
        id: 'data',
        label: 'Data da compra',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `especie` NÃO existe
      // no `MovementPurchaseRequest` — é premissa do protótipo (não-contratual)
      // para orientar a escolha de categoria/animal. O contrato ignora este
      // campo; mantido só como apoio de UI.
      FeatureField(
        id: 'especie',
        label: 'Espécie',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Bovino', 'Bubalino', 'Ovino'],
      ),
      // fidelidade-esteira (onda 10): `movement_purchases` (cabeçalho real,
      // dump) só tem campos de nota fiscal/pagamento — `categoria`,
      // `quantidade` e `valor-unitario` vivem apenas em
      // `item_movement_purchases` (coleção "Itens da compra", abaixo).
      // Nenhum dos três é o `recordTitleField` desta tela (`fornecedor`),
      // então nenhum permanece como escalar de cabeçalho.
      FeatureField(
        id: 'valor-total',
        label: 'Valor total (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria pós-fix): number (nota) é
      // sometimes|nullable no MovementPurchaseRequest — o app exigia a mais.
      FeatureField(
        id: 'documento',
        label: 'Nota / documento de origem',
      ),
      // fidelidade-campos (onda 5): `/movement-purchases` exige o bloco
      // financeiro inteiro de cabeçalho — forma de pagamento, total de
      // produtos, frete, outros valores e desconto — e nada disso existia. Sem
      // eles a consulta mostra um valor total que não se explica.
      // fidelidade-contrato (re-auditoria 3ª avaliação): type_payment é
      // string max:2 (código) — o rótulo ('À vista'…) estourava o max:2. O
      // campo emite um código ≤2 e exibe o rótulo (selectOptions).
      FeatureField(
        id: 'forma-pagamento',
        label: 'Forma de pagamento',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: '1', label: 'À vista'),
          (value: '2', label: 'Parcelado'),
          (value: '3', label: 'Permuta'),
          (value: '4', label: 'Boleto'),
        ],
      ),
      FeatureField(
        id: 'total-produtos',
        label: 'Total de produtos (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'frete',
        label: 'Frete (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'outros-valores',
        label: 'Outros valores (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'desconto',
        label: 'Desconto (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'vendedor',
        label: 'Vendedor',
        type: FeatureFieldType.searchSelect,
        options: catalogoFornecedores,
      ),
    ],
    // `items[]` traz categoria, quantidade, valor unitário, lote, pasto e
    // centro de custo de cada grupo comprado; `financial[]` é o
    // parcelamento. Duas coleções, nenhuma no protótipo.
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): items é
      // required|array|min:1 no MovementPurchaseRequest — trava ≥1.
      FeatureCollection(
        name: 'Itens da compra',
        itemLabel: 'Item da compra',
        isRequired: true,
        titleField: 'categoria',
        subtitleFields: ['quantidade', 'valor-unitario'],
        fields: [
          FeatureField(
            id: 'categoria',
            label: 'Categoria',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoCategoriasAnimais,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'valor-unitario',
            label: 'Valor unitário (R\$)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `items.*.amount` é required em `/movement-purchases` — o
          // subtotal do item, derivável de quantidade × valor unitário, mas
          // que o contrato exige explícito no envio.
          FeatureField(
            id: 'subtotal',
            label: 'Subtotal do item (R\$)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'lote',
            label: 'Lote de destino',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
          FeatureField(
            id: 'pasto',
            label: 'Pasto de destino',
          ),
          FeatureField(
            id: 'centro-custo',
            label: 'Centro de custo',
            type: FeatureFieldType.searchSelect,
            options: catalogoCentrosCusto,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Parcelas',
        itemLabel: 'Parcela',
        titleField: 'vencimento',
        subtitleFields: ['valor', 'forma'],
        fields: [
          FeatureField(
            id: 'vencimento',
            label: 'Vencimento',
            type: FeatureFieldType.date,
            isRequired: true,
          ),
          FeatureField(
            id: 'valor',
            label: 'Valor (R\$)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'forma',
            label: 'Forma',
            type: FeatureFieldType.select,
            options: [
              'Boleto',
              'Transferência',
              'Cheque',
              'Dinheiro',
            ],
          ),
        ],
      ),
    ],
    emptyLabel: 'Nenhuma compra de animais registrada.',
    sourceDetail:
        'O formulário não foi aberto; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    recordTitleField: 'fornecedor',
    recordDescriptionFields: ['especie', 'forma-pagamento', 'data'],
  ),
  // banco-real (onda 1): em Confinamento, "Vender Animais" já é exclusiva do
  // ADM — o catálogo geral ainda contradizia isso com `existingRoute` para
  // `/fazendas/campo/venda`, uma rota bloqueada para administração pela
  // política de acesso (`router/app_router.dart`, `redirectForSession`). A
  // rota saiu; a tela vira consulta pelo motor genérico, sem `fields`
  // documentados na fonte original (mesmo padrão de `minhas-os`). Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  FeatureDefinition(
    id: 'vendas',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Vendas',
    objective: 'Consultar vendas de animais registradas.',
    status: FeatureStatus.ready,
    readOnly: true,
    emptyLabel: 'Nenhuma venda registrada.',
    sourceDetail:
        'Consulta demonstrativa das vendas de animais registradas nesta sessão.',
    listMode: true,
  ),
  FeatureDefinition(
    id: 'exportar-log-estoque',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Exportar log de estoque',
    objective: 'Exportar registros de auditoria relacionados ao estoque.',
    status: FeatureStatus.ready,
    sourceDetail:
        'Período e formatos CSV/JSON são premissas funcionais do protótipo frontend.',
    auditExport: AuditExportKind.estoque,
  ),
  FeatureDefinition(
    id: 'exportar-log-pecuaria',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Exportar log da pecuária',
    objective: 'Exportar o histórico de eventos e movimentações do rebanho.',
    status: FeatureStatus.ready,
    sourceDetail:
        'Período e formatos CSV/JSON são premissas funcionais do protótipo frontend.',
    auditExport: AuditExportKind.pecuaria,
  ),
  // Espelha `minhas-os`, mas para o Administrativo: cria novas OS e tem as
  // duas ações que o perfil pode tomar enquanto uma OS não foi encerrada pelo
  // Operacional (avaliar, cancelar) — `admin/dash_ordem_servico.dart`, mesmo
  // painel (`ordem_servico/screens/ordem_servico_painel.dart`) da aba "OS"
  // própria da Administração (`ordem_servico_tab_screen.dart`).
  FeatureDefinition(
    id: 'consulta-os',
    profile: FeatureProfile.administration,
    group: 'Ordem de serviço',
    title: 'Ordem de Serviço',
    objective:
        'Consultar as ordens de serviço da fazenda, filtrar por data e status, '
        'criar uma nova OS, avaliar o andamento ou cancelar uma OS ainda não '
        'encerrada pelo Operacional.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/ordem-servico',
    emptyLabel: 'Nenhuma ordem de serviço registrada.',
    sourceDetail:
        'Consulta e criação demonstrativas de ordens de serviço registradas nesta sessão.',
    listMode: true,
  ),
  // Mesmo padrão de `consulta-os`: o cadastro (`ApontamentoFlow`) é
  // Operacional e tem fluxo dedicado (fora do motor genérico), então a
  // consulta administrativa também é `existingRoute` — os campos exibidos em
  // `DashApontamentos` são os mesmos 12 campos de cabeçalho + as 5 coleções
  // do cadastro (nenhum campo genérico à parte).
  FeatureDefinition(
    id: 'consulta-apontamentos',
    profile: FeatureProfile.administration,
    group: 'Ordem de serviço',
    title: 'Apontamentos agrícolas',
    objective:
        'Consultar os apontamentos agrícolas lançados pelo Operacional, com '
        'identificação, dados da operação e os recursos/produção/ocorrências '
        'registrados.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/apontamentos',
    emptyLabel: 'Nenhum apontamento registrado.',
    sourceDetail:
        'Consulta demonstrativa de todos os apontamentos registrados nesta sessão.',
    readOnly: true,
    listMode: true,
  ),
];

const allFeatures = <FeatureDefinition>[...adminFeatures];

FeatureDefinition? featureById(String id) {
  for (final feature in allFeatures) {
    if (feature.id == id) return feature;
  }
  return null;
}
