import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../mocks/hub_apps.dart';

/// Catálogo completo de mini-apps — espelha `AppsScreen.tsx`. Ponto único de
/// descoberta: apps disponíveis + roadmap visível ("Em breve").
class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeading(
                level: AppHeadingLevel.h3,
                child: Text('Todos os apps'),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Um só lugar para toda a operação — do campo ao banco.',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        RiseIn(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Disponíveis')),
              const SizedBox(height: AppSpacing.space2),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 1.6,
                children: [
                  for (final app in hubApps)
                    AppMiniAppTile(
                      icon: app.icon,
                      name: app.name,
                      description: app.description,
                      badge: app.badge,
                      onTap: app.route != null
                          ? () => context.go(app.route!)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        RiseIn(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Em breve')),
              const SizedBox(height: AppSpacing.space2),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 1.6,
                children: [
                  for (final app in appsEmBreve)
                    AppMiniAppTile(
                      icon: app.icon,
                      name: app.name,
                      description: app.description,
                      badge: app.badge,
                      disabled: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
