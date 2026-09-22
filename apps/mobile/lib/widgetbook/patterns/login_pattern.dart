import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../../design/generated/app_layout.dart';

/// Padrão de tela "Login" (Widgetbook → Padrões).
///
/// Documenta, de forma viva e autocontida, a composição já usada em
/// `shell/pages/login_page.dart`: cartão flutuando sobre um fundo, campos de
/// e-mail/senha, checkbox de sessão e botão primário de largura total — só
/// com componentes de `ui/ui.dart` e tokens, sem Riverpod/go_router reais.
/// Serve de referência para qualquer tela de acesso futura (ex.: login de um
/// módulo isolado ou recuperação de senha).
class _LoginPatternExample extends StatefulWidget {
  const _LoginPatternExample();

  @override
  State<_LoginPatternExample> createState() => _LoginPatternExampleState();
}

class _LoginPatternExampleState extends State<_LoginPatternExample> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _manterConectado = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exemplo de padrão — sem autenticação real.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      color: semantic.bgCanvas,
      padding: const EdgeInsets.all(AppSpacing.space6),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.space16,
                height: AppSpacing.space16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantic.accentSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: AppIcon(
                  AppIcons.sprout,
                  size: AppSize.iconXxl,
                  color: semantic.accentDefault,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              const AppHeading(child: Text('Bem-vindo!')),
              const SizedBox(height: AppSpacing.space6),
              AppFormField(
                label: 'E-mail',
                child: AppTextInput(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  placeholder: 'seu@email.com',
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppFormField(
                label: 'Senha',
                child: AppTextInput(
                  controller: _senhaController,
                  obscureText: true,
                  placeholder: 'Digite sua senha',
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppCheckbox(
                    checked: _manterConectado,
                    onChanged: (v) => setState(() => _manterConectado = v),
                    label: 'Manter conectado',
                  ),
                  AppButton(
                    variant: AppButtonVariant.link,
                    onPressed: () {},
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: () => _submit(context),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildLoginPatternWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Login',
    useCases: [
      WidgetbookUseCase(
        name: 'Exemplo',
        builder: (context) => const _LoginPatternExample(),
      ),
    ],
  );
}
