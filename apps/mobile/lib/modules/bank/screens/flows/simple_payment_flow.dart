import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design/generated/app_spacing.dart';
import '../../../../design/generated/app_typography.dart';
import '../../../../design/theme/app_theme_extension.dart';
import '../../../../mocks/bank_mocks.dart';
import '../../../../shell/state/shell_store.dart';
import '../../../../ui/ui.dart';
import '../../components/bank_flow_shell.dart';
import 'package:cerne_app/modules/bank/lib/currency.dart';
import 'package:cerne_app/design/generated/app_radius.dart';
import '../../../../design/generated/app_layout.dart';

enum PaymentKind { boleto, transferir, cobrar }

class _Meta {
  const _Meta({
    required this.title,
    required this.icon,
    required this.confirm,
    required this.successTitle,
  });

  final String title;
  final AppIconData icon;
  final String confirm;
  final String successTitle;
}

const Map<PaymentKind, _Meta> _meta = {
  PaymentKind.boleto: _Meta(
    title: 'Pagar boleto',
    icon: AppIcons.scanLine,
    confirm: 'Confirmar pagamento',
    successTitle: 'Pagamento agendado',
  ),
  PaymentKind.transferir: _Meta(
    title: 'Transferir',
    icon: AppIcons.arrowLeftRight,
    confirm: 'Confirmar transferência',
    successTitle: 'Transferência enviada',
  ),
  PaymentKind.cobrar: _Meta(
    title: 'Cobrar via Pix',
    icon: AppIcons.handCoins,
    confirm: 'Gerar cobrança',
    successTitle: 'Cobrança criada',
  ),
};

enum _Step { form, revisao, done }

/// Fluxos de boleto/transferência/cobrança: formulário → revisão → sucesso.
/// Espelha `SimplePaymentFlow.tsx`.
class SimplePaymentFlow extends ConsumerStatefulWidget {
  const SimplePaymentFlow({
    super.key,
    required this.kind,
    required this.onExit,
  });

  final PaymentKind kind;

  /// Sair do fluxo (voltar ao hub de Pagamentos).
  final VoidCallback onExit;

  @override
  ConsumerState<SimplePaymentFlow> createState() => _SimplePaymentFlowState();
}

class _SimplePaymentFlowState extends ConsumerState<SimplePaymentFlow> {
  _Step _step = _Step.form;

  final _linhaController = TextEditingController();
  String _linha = '';
  String? _banco;
  final _agenciaController = TextEditingController();
  String _agencia = '';
  final _contaController = TextEditingController();
  String _conta = '';
  final _nomeController = TextEditingController();
  String _nome = '';
  final _valorController = TextEditingController();
  String _valor = '';
  final _descricaoController = TextEditingController();
  String _descricao = '';

  @override
  void dispose() {
    _linhaController.dispose();
    _agenciaController.dispose();
    _contaController.dispose();
    _nomeController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  double get _valorNum => parseReais(_valor);
  bool get _valorValido => _valorNum > 0;

  bool get _valid => switch (widget.kind) {
    PaymentKind.boleto => _linha.trim().length >= 6 && _valorValido,
    PaymentKind.transferir =>
      (_banco != null) &&
          _agencia.trim().isNotEmpty &&
          _conta.trim().isNotEmpty &&
          _valorValido,
    PaymentKind.cobrar => _valorValido,
  };

  String get _bancoLabel {
    for (final b in bancos) {
      if (b.value == _banco) return b.label;
    }
    return '';
  }

  void _reset() {
    setState(() {
      _step = _Step.form;
      _linhaController.clear();
      _linha = '';
      _banco = null;
      _agenciaController.clear();
      _agencia = '';
      _contaController.clear();
      _conta = '';
      _nomeController.clear();
      _nome = '';
      _valorController.clear();
      _valor = '';
      _descricaoController.clear();
      _descricao = '';
    });
  }

  void _back() {
    if (_step == _Step.revisao) {
      setState(() => _step = _Step.form);
    } else {
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;
    final meta = _meta[widget.kind]!;

    // ---- Sucesso ----
    if (_step == _Step.done) {
      final desc = switch (widget.kind) {
        PaymentKind.boleto => TextSpan(
          style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
          children: [
            const TextSpan(text: 'Pagamento de '),
            TextSpan(
              text: formatBRL(_valorNum),
              style: TextStyle(
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            const TextSpan(
              text:
                  ' agendado. O débito ocorre na conta na data de vencimento.',
            ),
          ],
        ),
        PaymentKind.transferir => TextSpan(
          style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
          children: [
            TextSpan(
              text: formatBRL(_valorNum),
              style: TextStyle(
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            TextSpan(
              text:
                  ' enviado para $_bancoLabel · Ag $_agencia · Conta $_conta.',
            ),
          ],
        ),
        PaymentKind.cobrar => TextSpan(
          style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
          children: [
            const TextSpan(text: 'Cobrança de '),
            TextSpan(
              text: formatBRL(_valorNum),
              style: TextStyle(
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            const TextSpan(
              text:
                  ' criada. O código Pix copia-e-cola fica disponível no GB Bank web para envio ao pagador.',
            ),
          ],
        ),
      };

      return AppSuccessPanel(
        title: meta.successTitle,
        description: RichText(text: desc),
        actions: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              fullWidth: true,
              onPressed: () => context.go('/bank'),
              child: const Text('Voltar ao Bank'),
            ),
            const SizedBox(height: AppSpacing.space2),
            AppButton(
              variant: AppButtonVariant.ghost,
              fullWidth: true,
              onPressed: _reset,
              child: const Text('Nova operação'),
            ),
          ],
        ),
      );
    }

    // ---- Revisão ----
    if (_step == _Step.revisao) {
      return BankFlowShell(
        title: meta.title,
        onBack: _back,
        totalSteps: 2,
        currentStep: 2,
        primaryLabel: meta.confirm,
        onPrimary: () => setState(() => _step = _Step.done),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.accentSubtle,
                  ),
                  child: AppIcon(
                    meta.icon,
                    size: AppSize.iconMd,
                    color: semantic.accentDefault,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  balanceHidden ? '••••••' : formatBRL(_valorNum),
                  style: TextStyle(
                    fontSize: AppTypography.xl4,
                    fontWeight: AppTypography.weightBold,
                    height: AppTypography.lineHeightTight,
                    color: semantic.fgDefault,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space5),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                border: Border.all(color: semantic.borderDefault),
                borderRadius: BorderRadius.circular(AppRadius.lgPlus),
                color: semantic.bgSubtle,
              ),
              child: Column(
                children: [
                  if (widget.kind == PaymentKind.boleto)
                    _ResumoRow(label: 'Linha digitável', value: _linha.trim()),
                  if (widget.kind == PaymentKind.transferir) ...[
                    const _ResumoRow(label: 'De', value: ContaOrigem.label),
                    const SizedBox(height: AppSpacing.space3),
                    _ResumoRow(label: 'Banco', value: _bancoLabel),
                    const SizedBox(height: AppSpacing.space3),
                    _ResumoRow(label: 'Agência', value: _agencia.trim()),
                    const SizedBox(height: AppSpacing.space3),
                    _ResumoRow(label: 'Conta', value: _conta.trim()),
                  ],
                  if (widget.kind == PaymentKind.cobrar)
                    _ResumoRow(
                      label: 'Pagador',
                      value: _nome.trim().isEmpty
                          ? 'Não informado'
                          : _nome.trim(),
                    ),
                  if (_descricao.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space3),
                    _ResumoRow(label: 'Descrição', value: _descricao.trim()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            const AppBanner(
              icon: AppIcon(AppIcons.info, size: AppSize.iconXs),
              child: Text(
                'Confira os dados antes de confirmar. Esta é uma operação simulada do protótipo.',
              ),
            ),
          ],
        ),
      );
    }

    // ---- Formulário ----
    return BankFlowShell(
      title: meta.title,
      onBack: _back,
      totalSteps: 2,
      currentStep: 1,
      primaryLabel: 'Revisar',
      onPrimary: () => setState(() => _step = _Step.revisao),
      primaryDisabled: !_valid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(child: Text('Dados da operação')),
          const SizedBox(height: AppSpacing.space4),
          if (widget.kind == PaymentKind.boleto) ...[
            AppFormField(
              label: 'Linha digitável',
              hint: 'Código de barras do boleto',
              child: AppTextInput(
                controller: _linhaController,
                keyboardType: TextInputType.number,
                placeholder:
                    '00000.00000 00000.000000 00000.000000 0 00000000000000',
                onChanged: (v) => setState(() => _linha = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          if (widget.kind == PaymentKind.transferir) ...[
            AppFormField(
              label: 'Banco de destino',
              child: AppFormSelect(
                options: [
                  for (final b in bancos)
                    AppFormSelectOption(value: b.value, label: b.label),
                ],
                value: _banco,
                placeholder: 'Selecione o banco',
                onChanged: (v) => setState(() => _banco = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Agência',
                    child: AppTextInput(
                      controller: _agenciaController,
                      keyboardType: TextInputType.number,
                      placeholder: '0001',
                      onChanged: (v) => setState(() => _agencia = v),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: AppFormField(
                    label: 'Conta',
                    child: AppTextInput(
                      controller: _contaController,
                      keyboardType: TextInputType.number,
                      placeholder: '00000-0',
                      onChanged: (v) => setState(() => _conta = v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          if (widget.kind == PaymentKind.cobrar) ...[
            AppFormField(
              label: 'Pagador (opcional)',
              child: AppTextInput(
                controller: _nomeController,
                placeholder: 'Nome de quem vai pagar',
                onChanged: (v) => setState(() => _nome = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          AppFormField(
            label: widget.kind == PaymentKind.cobrar
                ? 'Valor a cobrar'
                : 'Valor',
            error: _valor.isNotEmpty && !_valorValido
                ? 'Informe um valor maior que zero.'
                : null,
            child: AppTextInput(
              controller: _valorController,
              keyboardType: TextInputType.number,
              placeholder: '0,00',
              invalid: _valor.isNotEmpty && !_valorValido,
              onChanged: (v) => setState(() => _valor = v),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Descrição (opcional)',
            child: AppTextarea(
              controller: _descricaoController,
              placeholder: 'Identifique esta operação',
              onChanged: (v) => setState(() => _descricao = v),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoRow extends StatelessWidget {
  const _ResumoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        const SizedBox(width: AppSpacing.space3),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
        ),
      ],
    );
  }
}
