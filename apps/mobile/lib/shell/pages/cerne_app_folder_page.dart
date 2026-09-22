import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Simula abrir a pasta "CERNE App" na tela inicial Android — neste repo ela
/// guarda um único app, o **CERNE ADM** (administração/gestão). As rotinas de
/// campo vivem no app irmão (CERNE Operação), fora deste projeto.
///
/// O ícone leva ao login existente (decisão já validada com o time — não pula
/// a etapa de login). Usa `context.push` (não `go`) — mantém esta tela na
/// pilha para o voltar (gesto/botão do sistema) retornar aqui em vez de pular
/// direto para a home Android.
class CerneAppFolderPage extends StatelessWidget {
  const CerneAppFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space2,
                    AppSpacing.space2,
                    AppSpacing.space5,
                    0,
                  ),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: const AppIcon(AppIcons.chevronLeft),
                        label: 'Voltar',
                        variant: AppIconButtonVariant.onDark,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                  ),
                  // Vidro fosco sobre a arte (Figma T003, node 6:52) — troca o
                  // bloco escuro translúcido anterior pelo mesmo `AppCard`
                  // glass do cartão de login (Lei 1/2: fonte única).
                  child: AppCard(
                    variant: AppCardVariant.glass,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppBrandLogo(),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          'Entrar no CERNE ADM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppAppIconTile(
                              icon: AppIcons.shieldCheck,
                              label: 'Administrativo',
                              tileColor: semantic.accentDefault,
                              iconColor: AppColors.neutral0,
                              labelColor: semantic.fgDefault,
                              onTap: () => context.push('/login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
