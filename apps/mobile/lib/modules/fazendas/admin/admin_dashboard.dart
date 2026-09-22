import 'package:flutter/material.dart';

import '../screens/em_section.dart';
import 'dash_ativos.dart';
import 'dash_apontamentos.dart';
import 'dash_confinamento.dart';
import 'dash_consultas.dart';
import 'dash_ordem_servico.dart';
import 'dash_resultado.dart';
import 'dash_suprimentos.dart';
import 'dash_uso.dart';

/// Resolve o dashboard administrativo pelo `dashId` da rota
/// `/fazendas/dashboards/:dashId` (spec §4). Espelha `AdminDashboard.tsx`.
Widget buildAdminDashboard(String dashId) {
  return switch (dashId) {
    // `financeiro` e `pecuaria` continuam resolvendo: os dois painéis fundiram
    // em Resultado, e links antigos (favoritos, prints, docs) não podem cair
    // numa tela vazia. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
    'resultado' || 'financeiro' || 'pecuaria' => const DashResultado(),
    'confinamento' => const DashConfinamento(),
    'ativos' => const DashAtivos(),
    'suprimentos' => const DashSuprimentos(),
    'uso' => const DashUso(),
    'consultas' => const DashConsultas(),
    'ordem-servico' => const DashOrdemServico(),
    'apontamentos' => const DashApontamentos(),
    _ => const EmSection(title: 'Dashboard'),
  };
}
