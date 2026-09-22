import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../design/generated/app_layout.dart';

/// Simulação de uma tela de launcher Android — disponível como uma etapa
/// opcional antes da seleção de ambiente. Área de trabalho com um único ícone
/// funcional ("CERNE App", que abre a pasta com CERNE ADM/CERNE Operação — ver
/// [CerneAppFolderPage]) e um dock decorativo, para deixar visualmente clara a
/// separação entre os dois ambientes.
///
/// Barra de status, relógio e ícones do dock são só decoração — mock fixo,
/// sem hora real nem qualquer integração nativa (Lei "Limites do protótipo").
class AndroidHomePage extends StatelessWidget {
  const AndroidHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.5, 0.82],
                colors: [
                  AppComponentColors.loginHeroScrimFrom,
                  AppComponentColors.loginHeroScrimMid,
                  AppComponentColors.loginHeroScrimTo,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _AndroidStatusBar(),
                const Spacer(flex: 2),
                AppAppIconTile(
                  icon: AppIcons.layoutGrid,
                  label: 'CERNE App',
                  onTap: () => context.go('/desktop/cerne-app'),
                ),
                const Spacer(flex: 3),
                const AppPageDots(count: 3, active: 0),
                const SizedBox(height: AppSpacing.space5),
                const _AndroidDock(),
                const SizedBox(height: AppSpacing.space5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de status decorativa — hora fixa (protótipo, sem relógio real) +
/// ícones de sinal/wifi/bateria, mesmo padrão visual de um Android real.
class _AndroidStatusBar extends StatelessWidget {
  const _AndroidStatusBar();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final iconColor = semantic.fgInverse;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '09:41',
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: iconColor,
            ),
          ),
          Row(
            children: [
              AppIcon(AppIcons.signal, size: AppSize.iconXs, color: iconColor),
              const SizedBox(width: AppSpacing.space2),
              AppIcon(AppIcons.wifi, size: AppSize.iconXs, color: iconColor),
              const SizedBox(width: AppSpacing.space2),
              AppIcon(AppIcons.battery, size: AppSize.iconXs, color: iconColor),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dock inferior — 4 apps decorativos de um Android real (Telefone, Câmera,
/// Mensagens, Navegador). Não fazem nada ao toque — mesmo padrão já usado em
/// "Esqueceu a senha?" do login (ação fora do escopo do protótipo).
class _AndroidDock extends StatelessWidget {
  const _AndroidDock();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: semantic.inkBg.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadius.xl3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppAppIconTile(
              icon: AppIcons.phone,
              label: 'Telefone',
              size: AppAppIconTileSize.small,
              showLabel: false,
            ),
            AppAppIconTile(
              icon: AppIcons.camera,
              label: 'Câmera',
              size: AppAppIconTileSize.small,
              showLabel: false,
            ),
            AppAppIconTile(
              icon: AppIcons.messageCircle,
              label: 'Mensagens',
              size: AppAppIconTileSize.small,
              showLabel: false,
            ),
            AppAppIconTile(
              icon: AppIcons.globe,
              label: 'Navegador',
              size: AppAppIconTileSize.small,
              showLabel: false,
            ),
          ],
        ),
      ),
    );
  }
}
