import 'app_icon.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'page_scaffold.dart';
import 'chip.dart';
import 'icon_button.dart';
import 'review_list.dart';
import 'transaction_list_item.dart';
import '../design/generated/app_layout.dart';

/// ID de operação mockado e determinístico (sem `DateTime.now()`) — protótipo,
/// espelha `operationId` de `TransactionDetailSheet.tsx`.
String _operationId(String id) =>
    'E9040088-2607-${id.toUpperCase().padLeft(6, '0')}-GBNK';

/// Comprovante bancário de uma transação, acionado pelo
/// `AppTransactionListItem` no hub Início, na Carteira, no GB Bank e no
/// extrato. No React (`TransactionDetailSheet.tsx`) é um wrapper controlado
/// (`transaction: TransactionItem | null` + `onClose`); em Flutter é uma
/// função — chamar `showAppTransactionDetailSheet(context, transaction: tx)`
/// a partir do `onTap` do item de lista.
///
/// Abre em **tela cheia** ([showAppDetailPage]), não mais como folha inferior:
/// o comprovante é a visualização mais longa do app (direção, valor, partes,
/// ID de operação, ações) e o teto de 85% da viewport obrigava a rolar um
/// container curto dentro de outra tela. O nome do arquivo continua por
/// compatibilidade com os 4 pontos de chamada e com o Widgetbook.
Future<void> showAppTransactionDetailSheet(
  BuildContext context, {
  required AppTransactionItem transaction,
  bool hidden = false,
}) {
  return showAppDetailPage<void>(
    context,
    title: 'Detalhe da transação',
    child: _TransactionDetailBody(transaction: transaction, hidden: hidden),
  );
}

/// Corpo do comprovante — extraído para `StatefulWidget` apenas pelo estado
/// local "copiado" (equivalente ao `useState`/`useEffect` do React).
class _TransactionDetailBody extends StatefulWidget {
  const _TransactionDetailBody({
    required this.transaction,
    required this.hidden,
  });

  final AppTransactionItem transaction;
  final bool hidden;

  @override
  State<_TransactionDetailBody> createState() => _TransactionDetailBodyState();
}

class _TransactionDetailBodyState extends State<_TransactionDetailBody> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyOpId(String opId) async {
    await Clipboard.setData(ClipboardData(text: opId));
    if (!mounted) return;
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final tx = widget.transaction;
    final isIn = tx.direction == AppTransactionDirection.income;
    final opId = _operationId(tx.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cabeçalho do comprovante: direção acessível + valor grande.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space1),
          child: Column(
            children: [
              Container(
                width: AppSpacing.space12,
                height: AppSpacing.space12,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  color: isIn ? semantic.accentSubtle : semantic.bgSubtle,
                ),
                child: AppIcon(
                  isIn ? AppIcons.arrowDownLeft : AppIcons.arrowUpRight,
                  size: AppSize.iconMd,
                  color: isIn ? semantic.accentDefault : semantic.fgMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              AppChip(
                tone: isIn ? AppChipTone.brand : AppChipTone.neutral,
                icon: AppIcon(
                  isIn ? AppIcons.arrowDownLeft : AppIcons.arrowUpRight,
                  size: AppSize.iconXs,
                ),
                child: Text(isIn ? 'Entrada' : 'Saída'),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                widget.hidden ? '••••••' : '${isIn ? '+' : '−'} ${tx.value}',
                style: TextStyle(
                  fontSize: AppTypography.xl4,
                  fontWeight: AppTypography.weightBold,
                  height: AppTypography.lineHeightTight,
                  color: isIn ? semantic.accentDefault : semantic.fgDefault,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                tx.time,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        // Ficha do comprovante — `AppReviewList`, fonte única dos campos de
        // leitura (Lei 2): cada campo é seu próprio cartão abafado. A
        // situação continua um `AppChip` à parte: não é texto, é estado.
        AppReviewList(
          items: [
            AppReviewItem(label: isIn ? 'De' : 'Para', value: tx.title),
            if (tx.subtitle != null)
              AppReviewItem(label: 'Descrição', value: tx.subtitle!),
            AppReviewItem(label: 'Data', value: tx.time),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        const _ReceiptRow(
          label: 'Situação',
          value: AppChip(tone: AppChipTone.brand, child: Text('Efetivada')),
        ),
        const SizedBox(height: AppSpacing.space4),

        // ID da operação — bloco copiável.
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            border: Border.all(color: semantic.borderDefault),
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ID DA OPERAÇÃO',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgSubtle,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Padding(
                      // mt-0.5 (2px) do React — valor fixo fora da escala de
                      // espaçamento, igual ao padrão de `chip.dart`.
                      padding: const EdgeInsets.only(top: AppSpacing.half),
                      child: Text(
                        opId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          fontWeight: AppTypography.weightSemibold,
                          letterSpacing: 0.4,
                          color: semantic.fgDefault,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              AppIconButton(
                icon: AppIcon(
                  _copied ? AppIcons.check : AppIcons.copy,
                  size: AppSize.iconSm,
                  color: _copied ? semantic.accentDefault : null,
                ),
                label: _copied ? 'ID copiado' : 'Copiar ID da operação',
                variant: AppIconButtonVariant.solid,
                size: AppIconButtonSize.lg,
                onPressed: () => _copyOpId(opId),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        // Padrão honesto do protótipo.
        Text(
          'O comprovante oficial em PDF fica disponível no GB Bank web.',
          style: TextStyle(
            fontSize: AppTypography.sm,
            color: semantic.fgSubtle,
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
            textAlign: TextAlign.right,
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildTransactionDetailSheetWidgetbookComponent() {
  final sample = const AppTransactionItem(
    id: '1',
    title: 'Venda de soja — lote 42',
    subtitle: 'Cooperativa Central',
    time: '09:12',
    value: 'R\$ 12.400,00',
    direction: AppTransactionDirection.income,
  );

  return WidgetbookComponent(
    name: 'TransactionDetailSheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Aberto (via botão)',
        builder: (context) => Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showAppTransactionDetailSheet(context, transaction: sample),
              child: const Text('Abrir detalhe da transação'),
            ),
          ),
        ),
      ),
    ],
  );
}
