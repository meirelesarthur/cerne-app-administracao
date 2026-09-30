import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/shell_store.dart';

/// Voltar das subtelas do Perfil. `maybePop` passa pelo `AppLeaveGuard`
/// (pergunta antes de descartar alterações); sem tela anterior (link direto,
/// recarga), volta ao Perfil.
Future<void> voltarParaPerfil(BuildContext context) async {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    await navigator.maybePop();
    return;
  }
  GoRouter.maybeOf(context)?.go('/perfil');
}

/// Informações pessoais — bloco "Dados pessoais" do Perfil: foto, nome
/// editável e e-mail de acesso somente leitura.
///
/// Protótipo frontend: "Alterar foto" simula a escolha de um arquivo (como
/// `AppFileUpload`) e salvar só atualiza o nome no `shellStoreProvider`, em
/// memória.
class InformacoesPessoaisPage extends ConsumerStatefulWidget {
  const InformacoesPessoaisPage({super.key});

  @override
  ConsumerState<InformacoesPessoaisPage> createState() =>
      _InformacoesPessoaisPageState();
}

class _InformacoesPessoaisPageState
    extends ConsumerState<InformacoesPessoaisPage> {
  late final TextEditingController _nome;

  /// Foto escolhida e ainda não salva.
  String? _fotoPendente;
  String? _erroNome;
  bool _salvo = false;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: ref.read(shellStoreProvider).user.name)
      ..addListener(_onNomeChanged);
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _onNomeChanged() => setState(() {
    _salvo = false;
    if (_nome.text.trim().isNotEmpty) _erroNome = null;
  });

  bool _temAlteracoes(UserProfile user) =>
      _nome.text.trim() != user.name || _fotoPendente != null;

  void _alterarFoto() => setState(() {
    _fotoPendente = 'foto-perfil.jpg';
    _salvo = false;
  });

  void _descartar(UserProfile user) {
    _nome.text = user.name;
    setState(() {
      _fotoPendente = null;
      _erroNome = null;
    });
  }

  void _salvar() {
    if (_nome.text.trim().isEmpty) {
      setState(() => _erroNome = 'Informe o nome.');
      return;
    }
    ref.read(shellStoreProvider.notifier).updateUserName(_nome.text);
    setState(() {
      _fotoPendente = null;
      _salvo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final user = ref.watch(shellStoreProvider).user;
    final dirty = _temAlteracoes(user);

    return AppPageScaffold(
      title: 'Informações pessoais',
      onBack: () => voltarParaPerfil(context),
      hasUnsavedChanges: dirty,
      actionBar: AppActionBar(
        primaryLabel: 'Salvar alterações',
        onPrimary: dirty ? _salvar : null,
        secondaryLabel: 'Descartar alterações',
        onSecondary: dirty ? () => _descartar(user) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_salvo) ...[
            const AppBanner(
              tone: AppBannerTone.success,
              child: Text('Alterações salvas.'),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          const AppSectionTitle(child: Text('Dados pessoais')),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              AppAvatar(
                name: user.name,
                initials: user.initials,
                size: AppAvatarSize.lg,
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton(
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      onPressed: _alterarFoto,
                      child: const Text('Alterar foto'),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      _fotoPendente == null
                          ? 'JPG, PNG, WebP ou GIF — até 5 MB.'
                          : '$_fotoPendente selecionada',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Nome',
            required: true,
            error: _erroNome,
            child: AppTextInput(
              controller: _nome,
              invalid: _erroNome != null,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'E-mail',
            hint: 'O e-mail de acesso não pode ser alterado nesta tela.',
            child: AppTextInput(
              // A chave troca o campo se o e-mail mudar — `initialValue` só é
              // lido na criação.
              key: ValueKey(user.email),
              initialValue: user.email,
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
