import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/prototype_session_store.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Login do Shell (mock, sem autenticação real) — espelha `Login.tsx`: arte de
/// campo em tela cheia como fundo fixo, véu escuro só no topo para a marca
/// clara, e cartão de boas-vindas com o formulário flutuando sobre a arte.
/// O CERNE ADM tem um ambiente único: o botão "Entrar" abre sempre a sessão de
/// Administração, no hub Banking. Não há escolha de perfil nesta tela.
///
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _manterConectado = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Entrar toca a abertura da marca (como no CERNE desktop) e só depois
  /// abre a sessão — assim o redirecionamento do login não corta a splash.
  Future<void> _loginAs(UserAccessProfile profile) async {
    await showAppSplash(context, tagline: 'Gestão das fazendas');
    if (!mounted) return;
    ref.read(prototypeSessionProvider.notifier).loginAs(profile);
    context.go(profile.landingRoute);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arte de fundo integral — fixa; o conteúdo rola por cima.
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.4, 0.68],
                colors: [
                  AppComponentColors.loginHeroScrimFrom,
                  AppComponentColors.loginHeroScrimMid,
                  AppComponentColors.loginHeroScrimTo,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bloco da marca sobre a arte.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space6,
                      AppSpacing.space10,
                      AppSpacing.space6,
                      AppSpacing.space10,
                    ),
                    child: Column(
                      children: [
                        const AppBrandLogo(
                          variant: AppBrandLogoVariant.onDark,
                          height: AppSpacing.space10,
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            'O agro inteiro em um só app: fazendas, banco, crédito e mercado.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: semantic.fgInverse.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cartão do formulário flutuando sobre a arte.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      0,
                      AppSpacing.space5,
                      AppSpacing.space8,
                    ),
                    child: AppCard(
                      variant: AppCardVariant.glass,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppHeading(
                                  child: Text('Bem-vindo de volta!'),
                                ),
                                const SizedBox(height: AppSpacing.space1),
                                Text(
                                  'Preencha suas credenciais para acessar',
                                  style: TextStyle(color: semantic.fgMuted),
                                ),
                              ],
                            ),
                          ),
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
                          const SizedBox(height: AppSpacing.space2),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.space1,
                                ),
                                // Recuperação automática fora do escopo do
                                // protótipo: em vez de um link morto, diz o
                                // que fazer.
                                child: AppButton(
                                  variant: AppButtonVariant.link,
                                  onPressed: () => showAppHelpSheet(
                                    context,
                                    title: 'Esqueceu a senha?',
                                    text:
                                        'Peça a redefinição ao administrador '
                                        'do GB CERNE na sua empresa. Ele envia '
                                        'uma senha provisória para o seu '
                                        'e-mail.',
                                  ),
                                  child: const Text('Esqueceu a senha?'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppCheckbox(
                                checked: _manterConectado,
                                onChanged: (v) =>
                                    setState(() => _manterConectado = v),
                                label: 'Manter conectado',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space5),
                          AppButton(
                            fullWidth: true,
                            size: AppButtonSize.lg,
                            onPressed: () =>
                                _loginAs(UserAccessProfile.administration),
                            child: const Text(
                              'ENTRAR',
                              semanticsLabel: 'Entrar',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      0,
                      AppSpacing.space5,
                      AppSpacing.space6,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'GB CERNE · Superapp corporativo do agronegócio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgInverse.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        AppButton(
                          variant: AppButtonVariant.onDark,
                          fullWidth: true,
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('Tour pelo app'),
                        ),
                        // Indicação do ambiente — informação de protótipo, fora
                        // do card de login: fica no rodapé, na mesma voz
                        // discreta da assinatura acima do tour.
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          'Acesso administrativo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgInverse.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
