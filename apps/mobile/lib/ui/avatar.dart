import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Avatar.tsx` — círculo de identificação com iniciais do usuário.
enum AppAvatarSize { sm, md, lg }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.initials,
    this.size = AppAvatarSize.md,
  });

  final String name;
  final String? initials;
  final AppAvatarSize size;

  /// `lg` é o avatar do cabeçalho de saudação do padrão global (Figma
  /// 54349:2374): 48 px com as iniciais em 18 px.
  double get _diameter => switch (size) {
    AppAvatarSize.sm => AppSpacing.space8,
    AppAvatarSize.md => AppSpacing.space10,
    AppAvatarSize.lg => AppSpacing.space12,
  };

  double get _fontSize => switch (size) {
    AppAvatarSize.sm => AppTypography.xs,
    AppAvatarSize.md => AppTypography.sm,
    AppAvatarSize.lg => AppTypography.xlPlus,
  };

  /// Deriva iniciais a partir dos 2 primeiros nomes de [name], em maiúsculas.
  static String deriveInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final displayInitials = initials ?? deriveInitials(name);

    return Semantics(
      image: true,
      label: name,
      child: Container(
        width: _diameter,
        height: _diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: semantic.bgSubtle,
          border: Border.all(color: semantic.borderSubtle),
        ),
        child: ExcludeSemantics(
          child: Text(
            displayInitials,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgMuted,
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildAvatarWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Avatar',
    useCases: [
      WidgetbookUseCase(
        name: 'Tamanhos',
        builder: (context) => const Center(
          child: Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAvatar(name: 'Maria Souza', size: AppAvatarSize.sm),
              AppAvatar(name: 'João Pereira'),
              AppAvatar(name: 'Ana Lima', size: AppAvatarSize.lg),
              AppAvatar(name: 'Carlos', initials: 'C+'),
            ],
          ),
        ),
      ),
    ],
  );
}
