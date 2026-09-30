import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../ui/ui.dart';
import 'informacoes_pessoais_page.dart' show voltarParaPerfil;

/// Segurança — troca da senha de acesso: senha atual, nova senha e
/// confirmação.
///
/// Protótipo frontend: não há backend para conferir a senha atual, então a
/// tela valida só o formulário (obrigatórios, mínimo de 6 caracteres, nova
/// diferente da atual e confirmação igual) e simula o sucesso.
class SegurancaPage extends StatefulWidget {
  const SegurancaPage({super.key});

  @override
  State<SegurancaPage> createState() => _SegurancaPageState();
}

class _SegurancaPageState extends State<SegurancaPage> {
  static const _minimo = 6;

  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmacao = TextEditingController();

  String? _erroAtual;
  String? _erroNova;
  String? _erroConfirmacao;
  bool _alterada = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_atual, _nova, _confirmacao]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _atual.dispose();
    _nova.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_alterada && _preenchido) setState(() => _alterada = false);
  }

  bool get _preenchido =>
      _atual.text.isNotEmpty ||
      _nova.text.isNotEmpty ||
      _confirmacao.text.isNotEmpty;

  void _alterarSenha() {
    final atual = _atual.text;
    final nova = _nova.text;
    final confirmacao = _confirmacao.text;

    setState(() {
      _erroAtual = atual.isEmpty ? 'Informe a senha atual.' : null;
      _erroNova = nova.isEmpty
          ? 'Informe a nova senha.'
          : nova.length < _minimo
          ? 'A nova senha precisa ter ao menos $_minimo caracteres.'
          : nova == atual
          ? 'A nova senha deve ser diferente da atual.'
          : null;
      _erroConfirmacao = confirmacao.isEmpty
          ? 'Confirme a nova senha.'
          : confirmacao != nova
          ? 'As senhas não coincidem.'
          : null;
    });

    if (_erroAtual != null || _erroNova != null || _erroConfirmacao != null) {
      return;
    }

    _atual.clear();
    _nova.clear();
    _confirmacao.clear();
    setState(() => _alterada = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Segurança',
      onBack: () => voltarParaPerfil(context),
      hasUnsavedChanges: _preenchido,
      actionBar: AppActionBar(
        primaryLabel: 'Alterar senha',
        onPrimary: _alterarSenha,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_alterada) ...[
            const AppBanner(
              tone: AppBannerTone.success,
              child: Text('Senha alterada com sucesso.'),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          AppFormField(
            label: 'Senha atual',
            required: true,
            error: _erroAtual,
            child: AppTextInput(
              controller: _atual,
              obscureText: true,
              invalid: _erroAtual != null,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Nova senha',
            required: true,
            error: _erroNova,
            hint: 'Mínimo $_minimo caracteres, diferente da senha atual.',
            child: AppTextInput(
              controller: _nova,
              obscureText: true,
              invalid: _erroNova != null,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Confirmar nova senha',
            required: true,
            error: _erroConfirmacao,
            child: AppTextInput(
              controller: _confirmacao,
              obscureText: true,
              invalid: _erroConfirmacao != null,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _alterarSenha(),
            ),
          ),
        ],
      ),
    );
  }
}
