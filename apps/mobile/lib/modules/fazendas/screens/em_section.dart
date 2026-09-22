import 'package:flutter/material.dart';

import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';

/// Placeholder de seção interna ainda não construída — espelha `EmSection.tsx`.
/// Usado pelos dispatchers-stub (`admin/admin_dashboard.dart`,
/// `operacional/campo_flow.dart`) até as Fases 3/4 (outros processos) entregarem
/// as telas reais.
///
/// Segue o mesmo arquétipo de tela funda do padrão global — barra superior sobre
/// o canvas, folha de conteúdo abaixo — para que a ausência de uma tela não
/// pareça um erro de renderização.
class EmSection extends StatelessWidget {
  const EmSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubPageHeader(title: title),
        const Expanded(
          child: AppContentSheet(
            child: Center(
              child: AppEmptyState(
                icon: AppIcons.construction,
                title: 'Em desenvolvimento',
                description:
                    'Esta tela será construída na próxima fase da esteira.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
