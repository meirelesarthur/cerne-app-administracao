/// Tipos do domínio do módulo Fazendas (ex-Cerne) — espelha `src/modules/fazendas/types.ts`.
/// Dados mockados no protótipo.
library;

class Farm {
  const Farm({
    required this.id,
    required this.name,
    required this.city,
    required this.uf,
  });

  final String id;
  final String name;
  final String city;
  final String uf;
}

/// Espelha `ActivityStatus`.
enum ActivityStatus { andamento, concluida, autorizada, atrasada }

/// Espelha `Activity['kind']`.
enum ActivityKind { pesagem, evento, nfe, venda, insumo, arracoamento }

class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final ActivityStatus status;
  final String time;
  final ActivityKind kind;
}

/// Item da fila de sincronização offline (spec §3.2/§6.9).
class SyncItem {
  const SyncItem({
    required this.id,
    required this.label,
    required this.detail,
    required this.kind,
  });

  final String id;
  final String label;
  final String detail;
  final ActivityKind kind;
}
