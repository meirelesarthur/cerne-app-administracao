import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../../../design/generated/app_layout.dart';

class _FaqItem {
  const _FaqItem({required this.pergunta, required this.resposta});

  final String pergunta;
  final String resposta;
}

const List<_FaqItem> _faq = [
  _FaqItem(
    pergunta: 'Quanto tempo leva a análise de uma proposta?',
    resposta:
        'Em média, de 2 a 5 dias úteis após o envio de todos os documentos solicitados.',
  ),
  _FaqItem(
    pergunta: 'Posso simular mais de uma linha de crédito?',
    resposta:
        'Sim. Use o simulador na Home do módulo Crédito para comparar valores e prazos entre as linhas disponíveis.',
  ),
  _FaqItem(
    pergunta: 'O que acontece se um documento estiver pendente?',
    resposta:
        'A proposta permanece em análise até o envio. Verifique a lista de documentos na tela de detalhe da proposta.',
  ),
  _FaqItem(
    pergunta: 'Como acompanho as parcelas de um contrato ativo?',
    resposta:
        'Acesse Crédito → Contratos para ver o progresso de pagamento, a próxima parcela e o saldo devedor.',
  ),
];

/// Tela "Ajuda" do módulo Crédito: perguntas frequentes + contato com o
/// gerente. Espelha `AjudaScreen.tsx`.
class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Ajuda')),
        const SizedBox(height: AppSpacing.space6),
        for (final item in _faq)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.pergunta,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    item.resposta,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const AppBanner(
          icon: AppIcon(AppIcons.messageCircle, size: AppSize.iconXs),
          child: Text(
            'Não encontrou o que precisava? Fale com seu gerente de relacionamento.',
          ),
        ),
      ],
    );
  }
}
