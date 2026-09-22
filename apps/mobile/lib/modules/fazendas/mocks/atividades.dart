import '../types.dart';

/// Atividades recentes do rebanho/fazenda (spec §6.7) — espelha
/// `src/modules/fazendas/mocks/atividades.ts`.
const List<Activity> atividades = [
  Activity(
    id: 'a1',
    title: 'Pesagem do Lote 42',
    subtitle: 'São Pedro · 128 cabeças',
    status: ActivityStatus.concluida,
    time: 'há 12 min',
    kind: ActivityKind.pesagem,
  ),
  Activity(
    id: 'a2',
    title: 'Entrada NF-e #4471',
    subtitle: 'Insumos · Agropecuária Vale',
    status: ActivityStatus.andamento,
    time: 'há 40 min',
    kind: ActivityKind.nfe,
  ),
  Activity(
    id: 'a3',
    title: 'Venda de animais',
    subtitle: 'Frigorífico Central · 60 cab.',
    status: ActivityStatus.autorizada,
    time: 'há 2 h',
    kind: ActivityKind.venda,
  ),
  Activity(
    id: 'a4',
    title: 'Arraçoamento Curral 7',
    subtitle: 'Dieta Engorda · 1.200 kg',
    status: ActivityStatus.concluida,
    time: 'há 3 h',
    kind: ActivityKind.arracoamento,
  ),
  Activity(
    id: 'a5',
    title: 'Transferência de lote',
    subtitle: 'Lote 12 → Lote 19',
    status: ActivityStatus.atrasada,
    time: 'ontem',
    kind: ActivityKind.evento,
  ),
  Activity(
    id: 'a6',
    title: 'Aplicação de insumo',
    subtitle: 'Talhão 3 · Herbicida',
    status: ActivityStatus.concluida,
    time: 'ontem',
    kind: ActivityKind.insumo,
  ),
  Activity(
    id: 'a7',
    title: 'Nascimento registrado',
    subtitle: 'Matriz 208 · bezerro macho',
    status: ActivityStatus.concluida,
    time: '2 dias',
    kind: ActivityKind.evento,
  ),
  Activity(
    id: 'a8',
    title: 'Pesagem do Lote 19',
    subtitle: 'Santa Rita · 96 cabeças',
    status: ActivityStatus.concluida,
    time: '2 dias',
    kind: ActivityKind.pesagem,
  ),
];
