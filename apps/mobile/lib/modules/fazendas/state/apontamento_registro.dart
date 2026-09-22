import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Apontamento já lançado — o que `ApontamentoFlow` grava ao salvar. Guarda
/// os mesmos 12 campos de cabeçalho do formulário (rótulos já resolvidos,
/// não os `value` de dropdown) mais a contagem de cada uma das 5 coleções,
/// para a consulta administrativa (`DashApontamentos`) mostrar exatamente o
/// que o cadastro perguntou — sem campos genéricos que não existem lá.
class ApontamentoRegistro {
  const ApontamentoRegistro({
    required this.id,
    required this.responsavel,
    required this.area,
    required this.operacao,
    required this.atividade,
    required this.data,
    required this.areaTotal,
    required this.areaUtilizada,
    required this.armazemProducao,
    required this.registradoEm,
    this.cultura,
    this.safra,
    this.armazemInsumo,
    this.descricao = '',
    this.maoDeObra = const [],
    this.maquinas = const [],
    this.insumos = const [],
    this.producoes = const [],
    this.ocorrencias = const [],
  });

  final String id;
  final String responsavel;
  final String area;
  final String operacao;
  final String atividade;
  final String data;
  final String areaTotal;
  final String areaUtilizada;
  final String armazemProducao;
  final DateTime registradoEm;

  final String? cultura;
  final String? safra;
  final String? armazemInsumo;
  final String descricao;

  /// Cada item já formatado para exibição (mesmo texto de `_ItemRow` no
  /// cadastro) — a listagem não recalcula rótulo de dropdown.
  final List<String> maoDeObra;
  final List<String> maquinas;
  final List<String> insumos;
  final List<String> producoes;
  final List<String> ocorrencias;

  int get totalLancamentos =>
      maoDeObra.length +
      maquinas.length +
      insumos.length +
      producoes.length +
      ocorrencias.length;
}

// Seeds demonstrativos — mesma premissa de protótipo das demais consultas
// (`sourceDetail` nas telas explica que é dado de sessão/demo).
final _seed = <ApontamentoRegistro>[
  ApontamentoRegistro(
    id: 'apt-seed-1',
    responsavel: 'João Oliveira',
    area: 'Talhão 01',
    operacao: 'Tratos Culturais',
    atividade: 'Aplicação de Herbicida',
    data: '10/09/2026',
    areaTotal: '42',
    areaUtilizada: '42',
    armazemProducao: 'Armazém A',
    cultura: 'Soja',
    safra: '2025/2026',
    armazemInsumo: 'Armazém A',
    descricao: 'Aplicação preventiva pós-chuva.',
    registradoEm: DateTime(2026, 9, 10, 16, 20),
    maoDeObra: const ['Tratorista: Carlos Dias — 1 dia-homem · R\$ 180'],
    maquinas: const ['Pulverizador — 3 hora · horímetro 210→213'],
    insumos: const ['Herbicida XPTO — 40 L · Armazém A'],
  ),
  ApontamentoRegistro(
    id: 'apt-seed-2',
    responsavel: 'Maria Souza',
    area: 'Talhão 02',
    operacao: 'Colheita',
    atividade: 'Colheita Mecanizada',
    data: '08/09/2026',
    areaTotal: '65',
    areaUtilizada: '65',
    armazemProducao: 'Depósito B',
    cultura: 'Milho',
    safra: '2025/2026',
    descricao: 'Colheita concluída sem intercorrências.',
    registradoEm: DateTime(2026, 9, 8, 18, 45),
    maoDeObra: const ['Operador de Máquinas: João Oliveira — 8 hora · R\$ 45'],
    maquinas: const ['Colheitadeira CR7 — 8 hora · horímetro 540→548'],
    producoes: const ['Milho — 3.900 sc'],
  ),
];

class ApontamentoRegistroState {
  const ApontamentoRegistroState({required this.registros});

  final List<ApontamentoRegistro> registros;

  ApontamentoRegistroState copyWith({List<ApontamentoRegistro>? registros}) {
    return ApontamentoRegistroState(registros: registros ?? this.registros);
  }
}

final apontamentoRegistroStoreProvider =
    NotifierProvider<ApontamentoRegistroStoreNotifier, ApontamentoRegistroState>(
      ApontamentoRegistroStoreNotifier.new,
    );

class ApontamentoRegistroStoreNotifier
    extends Notifier<ApontamentoRegistroState> {
  @override
  ApontamentoRegistroState build() {
    return ApontamentoRegistroState(registros: List.of(_seed));
  }

  void add(ApontamentoRegistro registro) {
    state = state.copyWith(registros: [registro, ...state.registros]);
  }
}
