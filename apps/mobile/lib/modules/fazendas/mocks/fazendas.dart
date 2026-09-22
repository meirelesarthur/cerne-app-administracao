import '../types.dart';

/// Fazendas vinculadas ao usuário (multi-tenant, spec §3.5) — espelha
/// `src/modules/fazendas/mocks/fazendas.ts`.
const List<Farm> fazendas = [
  Farm(id: 'f1', name: 'Fazenda São Pedro', city: 'Barretos', uf: 'SP'),
  Farm(id: 'f2', name: 'Fazenda Santa Rita', city: 'Uberaba', uf: 'MG'),
  Farm(id: 'f3', name: 'Fazenda Boa Vista', city: 'Rio Verde', uf: 'GO'),
  Farm(id: 'f4', name: 'Fazenda Três Lagoas', city: 'Três Lagoas', uf: 'MS'),
  Farm(id: 'f5', name: 'Fazenda Vale do Sol', city: 'Sorriso', uf: 'MT'),
];
