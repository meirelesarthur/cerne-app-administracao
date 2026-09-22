import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'field_capsule.dart';

/// Espelha `Textarea.tsx` — campo multilinha (`rounded-2xl`), fundo sutil.
/// A altura mínima do React (`min-h-[96px]`) não tem token DTCG equivalente;
/// aqui ela é obtida via `minLines` (comportamento nativo do Flutter), não por
/// um valor de pixel hardcoded (Lei 3).
class AppTextarea extends StatelessWidget {
  const AppTextarea({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.minLines = 4,
    this.maxLines = 8,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final bool enabled;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);
    final radius = BorderRadius.circular(AppRadius.xl2);

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: AppTypography.xl,
        color: enabled ? inputColors.foreground : inputColors.muted,
      ),
      cursorColor: inputColors.focus,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputColors.fill,
        hintText: placeholder,
        hintStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.xl,
          color: inputColors.placeholder,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        border: border(AppColors.transparent),
        enabledBorder: border(AppColors.transparent),
        disabledBorder: border(AppColors.transparent),
        focusedBorder: border(inputColors.focus, width: 2),
      ),
    );
  }
}

WidgetbookComponent buildTextareaWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Textarea',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextarea(placeholder: 'Observações...'),
                SizedBox(height: AppSpacing.space4),
                AppTextarea(placeholder: 'Desabilitado', enabled: false),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
