import 'package:flutter/material.dart';

import '../generated/app_colors.dart';
import '../generated/app_radius.dart';
import '../generated/app_typography.dart';
import 'app_theme_extension.dart';

/// As duas variantes de tema do protótipo React (`data-theme="light"|"gbMode"`).
/// Não é o `ThemeMode` do Flutter (light/dark/system) — `gbMode` é uma identidade de marca,
/// não um modo escuro genérico.
enum AppThemeVariant { light, gbMode }

/// Monta o `ThemeData` de uma variante a partir dos tokens gerados (F1.2) — nunca hardcoded.
ThemeData buildAppTheme(AppThemeVariant variant) {
  final semantic = variant == AppThemeVariant.light
      ? AppSemanticColors.light
      : AppSemanticColors.gbMode;
  final brightness = variant == AppThemeVariant.light
      ? Brightness.light
      : Brightness.dark;

  TextStyle outfit({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  final textTheme =
      (brightness == Brightness.light
              ? Typography.material2021().black
              : Typography.material2021().white)
          .copyWith(
            // Papéis medidos no Figma 54300-2458. Os slots do Material são o
            // endereço; os valores são os da referência, não os do Material.
            // saldo do cartão-herói (54300:16101)
            displayLarge: outfit(
              fontSize: AppTypography.xl4,
              fontWeight: AppTypography.weightBold,
              color: semantic.fgDefault,
            ),
            headlineMedium: outfit(
              fontSize: AppTypography.xl3,
              fontWeight: AppTypography.weightBold,
              color: semantic.fgDefault,
            ),
            // título de tela do cabeçalho de saudação (54349:2379)
            titleLarge: outfit(
              fontSize: AppTypography.xlPlus2,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
              height: AppTypography.lineHeightHeading,
            ),
            // título da top bar (54349:2084)
            titleMedium: outfit(
              fontSize: AppTypography.xlPlus,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgHeading,
              height: AppTypography.lineHeightHeading,
            ),
            // cabeçalho de seção (54349:3165)
            titleSmall: outfit(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgSection,
              height: AppTypography.lineHeightSection,
            ),
            // corpo e texto de input (54349:2016)
            bodyLarge: outfit(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.weightNormal,
              color: semantic.fgDefault,
            ),
            bodyMedium: outfit(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightNormal,
              color: semantic.fgMuted,
            ),
            // subtítulo de card (54349:3208)
            bodySmall: outfit(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightNormal,
              color: semantic.fgSecondary,
            ),
            // rótulo de ladrilho (54349:2433)
            labelLarge: outfit(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgDefault,
            ),
            // metadado (54335:584)
            labelMedium: outfit(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightNormal,
              color: semantic.fgSubtle,
            ),
            // badge de status (54300:16148)
            labelSmall: outfit(
              fontSize: AppTypography.xs2,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgMuted,
            ),
          );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: semantic.bgCanvas,
    canvasColor: semantic.bgCanvas,
    fontFamily: AppTypography.fontFamily,
    textTheme: textTheme,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: semantic.accentDefault,
      onPrimary: semantic.accentContrast,
      secondary: AppColors.brand500,
      onSecondary: semantic.accentContrast,
      error: AppColors.red600,
      onError: AppColors.neutral0,
      surface: semantic.bgSurface,
      onSurface: semantic.fgDefault,
    ),
    dividerColor: semantic.borderDefault,
    cardTheme: CardThemeData(
      color: semantic.bgSurface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: semantic.accentDefault,
        foregroundColor: semantic.accentContrast,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: semantic.bgSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: semantic.borderDefault),
      ),
    ),
    // Calendário do `AppDateInput` (`showDatePicker`): mesma superfície e raio
    // de modal do resto do app, com o dia/ano selecionado na cor de marca —
    // nenhuma tela ou componente sobrescreve isso localmente (Lei 2/3).
    datePickerTheme: DatePickerThemeData(
      backgroundColor: semantic.bgSurface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      headerBackgroundColor: semantic.accentDefault,
      headerForegroundColor: semantic.accentContrast,
      weekdayStyle: outfit(
        fontSize: AppTypography.sm,
        fontWeight: AppTypography.weightMedium,
        color: semantic.fgSubtle,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentContrast;
        if (states.contains(WidgetState.disabled)) return semantic.fgQuiet;
        return semantic.fgDefault;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentDefault;
        return AppColors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentContrast;
        return semantic.accentDefault;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentDefault;
        return AppColors.transparent;
      }),
      todayBorder: BorderSide(color: semantic.accentDefault),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentContrast;
        return semantic.fgDefault;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return semantic.accentDefault;
        return AppColors.transparent;
      }),
      rangePickerShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
    ),
    extensions: [semantic],
  );
}
