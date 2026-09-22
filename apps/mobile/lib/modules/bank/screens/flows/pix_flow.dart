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

class _Destino {
  const _Destino({
    required this.nome,
    required this.chave,
    required this.tipoChave,
    this.inicial,
  });

  final String nome;
  final String chave;
  final String tipoChave;
  final String? inicial;
}

enum _Step { chave, valor, revisao, done }

/// Fluxo Pix completo mockado: chave → valor → revisão → sucesso. Espelha
/// `PixFlow.tsx`.
class PixFlow extends ConsumerStatefulWidget {
  const PixFlow({super.key, required this.onExit});

  /// Sair do fluxo (voltar ao hub de Pagamentos).
  final VoidCallback onExit;

  @override
  ConsumerState<PixFlow> createState() => _PixFlowState();
}

class _PixFlowState extends ConsumerState<PixFlow> {
  _Step _step = _Step.chave;
  final _chaveManualController = TextEditingController();
  _Destino? _destino;
  final _valorController = TextEditingController();
  final _mensagemController = TextEditingController();
  String _valor = '';
  String _mensagem = '';

  @override
  void dispose() {
    _chaveManualController.dispose();
    _valorController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  double get _valorNum => parseReais(_valor);
  bool get _valorValido => _valorNum > 0;

  void _selecionarContato(PixContato c) {
    setState(() {
      _destino = _Destino(
        nome: c.nome,
        chave: c.chave,
        tipoChave: c.tipoChave,
        inicial: c.inicial,
      );
      _step = _Step.valor;
    });
  }

  void _continuarManual() {
    setState(() {
      _destino = _Destino(
        nome: 'Nova chave Pix',
        chave: _chaveManualController.text.trim(),
        tipoChave: 'Chave Pix',
      );
      _step = _Step.valor;
    });
  }

  void _reset() {
    setState(() {
      _step = _Step.chave;
      _chaveManualController.clear();
      _destino = null;
      _valorController.clear();
      _mensagemController.clear();
      _valor = '';
      _mensagem = '';
    });
  }

  void _back() {
    if (_step == _Step.valor) {
      setState(() => _step = _Step.chave);
    } else if (_step == _Step.revisao) {
      setState(() => _step = _Step.valor);
    } else {
      widget.onExit();
    }
  }

  /// Índice 1-based na régua de [AppStepProgress] — a mesma peça do
  /// `Cadastro steps` global, em vez do rótulo de texto solto no cabeçalho.
  int get _stepNumber => switch (_step) {
    _Step.chave => 1,
    _Step.valor => 2,
    _Step.revisao => 3,
    _Step.done => 3,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;

    // ---- Sucesso ----
    if (_step == _Step.done && _destino != null) {
      final destino = _destino!;
      return AppSuccessPanel(
        title: 'Pix enviado',
        description: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: AppTypography.md,
              color: semantic.fgMuted,
            ),
            children: [
              TextSpan(
                text: formatBRL(_valorNum),
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              const TextSpan(text: ' para '),
              TextSpan(
                text: destino.nome,
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              const TextSpan(
                text: '. O comprovante fica disponível no extrato.',
              ),
            ],
          ),
        ),
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
              onPressed: () => context.go('/bank/extrato'),
              child: const Text('Ver extrato'),
            ),
            const SizedBox(height: AppSpacing.space2),
            AppButton(
              variant: AppButtonVariant.ghost,
              fullWidth: true,
              onPressed: _reset,
              child: const Text('Fazer novo Pix'),
            ),
          ],
        ),
      );
    }

    // ---- Passo 1: chave ----
    if (_step == _Step.chave) {
      return BankFlowShell(
        title: 'Pix',
        onBack: _back,
        totalSteps: 3,
        currentStep: _stepNumber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionTitle(child: Text('Enviar para uma chave')),
            const SizedBox(height: AppSpacing.space2),
            AppFormField(
              label: 'Chave Pix',
              hint: 'CPF/CNPJ, e-mail, telefone ou chave aleatória',
              child: AppTextInput(
                controller: _chaveManualController,
                placeholder: 'Digite ou cole a chave',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppButton(
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              rightIcon: const AppIcon(
                AppIcons.arrowRight,
                size: AppSize.iconSm,
              ),
              onPressed: _chaveManualController.text.trim().isEmpty
                  ? null
                  : _continuarManual,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: AppSpacing.space6),
            const AppSectionTitle(child: Text('Contatos frequentes')),
            const SizedBox(height: AppSpacing.space2),
            for (final c in pixContatos) ...[
              AppCard(
                variant: AppCardVariant.inset,
                interactive: true,
                onTap: () => _selecionarContato(c),
                child: Row(
                  children: [
                    AppAvatar(name: c.nome, initials: c.inicial),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.md,
                              fontWeight: AppTypography.weightSemibold,
                              color: semantic.fgDefault,
                            ),
                          ),
                          Text(
                            '${c.tipoChave} · ${c.chave}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.xs,
                              color: semantic.fgMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconSmPlus,
                      color: semantic.accentDefault,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
          ],
        ),
      );
    }

    // ---- Passo 2: valor ----
    if (_step == _Step.valor && _destino != null) {
      final destino = _destino!;
      return BankFlowShell(
        title: 'Pix',
        onBack: _back,
        totalSteps: 3,
        currentStep: _stepNumber,
        primaryLabel: 'Revisar',
        onPrimary: () => setState(() => _step = _Step.revisao),
        primaryDisabled: !_valorValido,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              variant: AppCardVariant.inset,
              child: Row(
                children: [
                  AppAvatar(name: destino.nome, initials: destino.inicial),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          destino.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.md,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          '${destino.tipoChave} · ${destino.chave}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            AppFormField(
              label: 'Valor do Pix',
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: semantic.borderDefault),
                borderRadius: BorderRadius.circular(AppRadius.mdPlus),
                color: semantic.bgSubtle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo disponível',
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                  Text(
                    balanceHidden ? '••••••' : ContaOrigem.saldo,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppFormField(
              label: 'Mensagem (opcional)',
              child: AppTextarea(
                controller: _mensagemController,
                placeholder: 'Ex.: pagamento de insumos',
                onChanged: (v) => setState(() => _mensagem = v),
              ),
            ),
          ],
        ),
      );
    }

    // ---- Passo 3: revisão ----
    if (_step == _Step.revisao && _destino != null) {
      final destino = _destino!;
      return BankFlowShell(
        title: 'Revisar Pix',
        onBack: _back,
        totalSteps: 3,
        currentStep: _stepNumber,
        primaryLabel: 'Confirmar Pix',
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
                    AppIcons.zap,
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
                Text(
                  'Pix para ${destino.nome}',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: semantic.fgMuted,
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
                  const _ResumoRow(label: 'De', value: ContaOrigem.label),
                  const SizedBox(height: AppSpacing.space3),
                  _ResumoRow(label: 'Para', value: destino.nome),
                  const SizedBox(height: AppSpacing.space3),
                  _ResumoRow(label: destino.tipoChave, value: destino.chave),
                  if (_mensagem.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space3),
                    _ResumoRow(label: 'Mensagem', value: _mensagem.trim()),
                  ],
                  const SizedBox(height: AppSpacing.space3),
                  const _ResumoRow(label: 'Quando', value: 'Agora'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            const AppBanner(
              icon: AppIcon(AppIcons.info, size: AppSize.iconXs),
              child: Text(
                'O Pix é processado na hora, 24/7. Confira os dados antes de confirmar.',
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
