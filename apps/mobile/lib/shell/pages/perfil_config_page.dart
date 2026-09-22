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
/// avatar + progresso do cadastro, seguido de seções rotuladas ("Conta",
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
                                AppButton(
                                  variant: AppButtonVariant.link,
                                  onPressed: () => context.go('/perfil'),
                                  child: const Text('Ver perfil completo'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    // fidelidade-esteira: mesma linguagem de "Evolua seu
                    // crédito" da home administrativa (fração + barra +
                    // próximo passo) — não o anel da referência, para manter
                    // um único idioma de "progresso de cadastro" no app.
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Perfil completo',
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  fontWeight: AppTypography.weightMedium,
                                  color: semantic.fgDefault,
                                ),
                              ),
                              Text(
                                '75%',
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  fontWeight: AppTypography.weightSemibold,
                                  color: semantic.accentDefault,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          const AppProgressBar(value: 75),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            'Complete seus dados para liberar todos os recursos.',
                            style: TextStyle(
                              fontSize: AppTypography.xs,
                              color: semantic.fgMuted,
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
                      onTap: () => context.go('/perfil'),
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
                      onTap: () => context.go('/notificacoes'),
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
                    // Sem tela própria no protótipo ainda — sinalizado com a
                    // tag "Em breve" em vez de fingir um destino real (Limites
                    // do protótipo, CLAUDE.md).
                    const AppMenuItem(
                      icon: AppIcons.shieldCheck,
                      label: 'Segurança',
                      description: 'PIN, biometria e sessões',
                      showShadow: false,
                      trailing: AppTag(child: Text('Em breve')),
                    ),
                    const SizedBox(height: AppSpacing.space2),
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
                        // Volta para a seleção de ambiente — simula "fechar o
                        // app", reforçando a separação entre CERNE ADM e CERNE
                        // Operação.
                        context.go('/desktop/cerne-app');
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
