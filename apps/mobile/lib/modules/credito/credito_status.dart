import '../../ui/ui.dart';
import 'mocks/credito_mocks.dart';

/// Rótulo e tom exibidos para cada [PropostaStatus] — espelha os mapas
/// `STATUS_LABEL`/`STATUS_TONE` repetidos em `CreditoHome.tsx`, `PropostasScreen.tsx`
/// e `PropostaDetalheScreen.tsx`. Centralizado aqui para não duplicar a regra
/// nas 3 telas do módulo Dart (Lei 2 — fonte única, aplicada dentro do módulo).
String propostaStatusLabel(PropostaStatus status) => switch (status) {
  PropostaStatus.analise => 'Em análise',
  PropostaStatus.aprovada => 'Aprovada',
  PropostaStatus.recusada => 'Recusada',
  PropostaStatus.contratada => 'Contratada',
};

AppChipTone propostaStatusTone(PropostaStatus status) => switch (status) {
  PropostaStatus.analise => AppChipTone.amber,
  PropostaStatus.aprovada => AppChipTone.brand,
  PropostaStatus.recusada => AppChipTone.red,
  PropostaStatus.contratada => AppChipTone.blue,
};
