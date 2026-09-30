import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../design/theme/theme_provider.dart';
import '../../ui/ui.dart';
import '../components/sub_page_header.dart';
import '../state/shell_store.dart';
import '../state/prototype_session_store.dart';

/// Perfil / Configurações do Shell — espelha `PerfilConfig.tsx`: hero `ink` com
/// avatar, nome e cargo, seguido de seções rotuladas ("Conta",
/// "Geral") no padrão de listagens do catálogo (linhas `subtle` sem sombra
/// sobre a folha branca). Conta + tema light/gbMode continuam funções do
/// Shell (aqui via `themeVariantProvider`).
class PerfilConfigPage extends ConsumerWidget {
  const PerfilConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final shell = ref.watch(shellStoreProvider);
    final user = shell.user;
    final profile = ref.watch(prototypeSessionProvider).profile;
    final isGbMode = ref.watch(themeVariantProvider) == AppThemeVariant.gbMode;
    final roleLabel = profile?.roleLabel ?? 'Sessão não iniciada';

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const SubPageHeader(title: 'Perfil'),
            Expanded(
              child: AppContentSheet(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space4,
                  ),
                  children: [
                    AppCard(
                      variant: AppCardVariant.ink,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: AppTypography.lg,
                                    fontWeight: AppTypography.weightSemibold,
                                    color: semantic.inkFg,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.half),
                                Text(
                                  '$roleLabel · GB CERNE',
                                  style: TextStyle(
                                    fontSize: AppTypography.sm,
                                    color: semantic.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    const AppSectionTitle(child: Text('Conta')),
                    const SizedBox(height: AppSpacing.space2),
                    AppMenuItem(
                      icon: AppIcons.user,
                      label: 'Informações pessoais',
                      description: 'Atualize seus dados cadastrais',
                      showShadow: false,
                      onTap: () => context.push('/perfil/informacoes-pessoais'),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    const AppSectionTitle(child: Text('Geral')),
                    const SizedBox(height: AppSpacing.space2),
                    AppMenuItem(
                      icon: AppIcons.bell,
                      label: 'Notificações',
                      description: 'Gerencie seus avisos',
                      showShadow: false,
                      trailing: shell.unreadCount > 0
                          ? AppBadge(child: Text('${shell.unreadCount}'))
                          : null,
                      onTap: () => context.push('/notificacoes'),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppMenuItem(
                      icon: isGbMode ? AppIcons.moon : AppIcons.sun,
                      label: 'Tema',
                      description: isGbMode
                          ? 'GB Mode (escuro)'
                          : 'Light (claro)',
                      showShadow: false,
                      onTap: () =>
                          ref.read(themeVariantProvider.notifier).toggle(),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppMenuItem(
                      icon: AppIcons.shieldCheck,
                      label: 'Segurança',
                      description: 'Alterar senha de acesso',
                      showShadow: false,
                      onTap: () => context.push('/perfil/seguranca'),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    // Sem tela própria no protótipo ainda — sinalizado com a
                    // tag "Em breve" em vez de fingir um destino real (Limites
                    // do protótipo, CLAUDE.md).
                    const AppMenuItem(
                      icon: AppIcons.helpCircle,
                      label: 'Central de ajuda',
                      description: 'Fale com o suporte',
                      showShadow: false,
                      trailing: AppTag(child: Text('Em breve')),
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    AppMenuItem(
                      icon: AppIcons.logOut,
                      label: 'Sair',
                      tone: AppMenuItemTone.danger,
                      showShadow: false,
                      onTap: () {
                        ref.read(prototypeSessionProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
