import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import 'field_capsule.dart';

/// Espelha `TextInput.tsx` — campo-cápsula (Nova UI): pílula cheia (`rounded-full`),
/// fundo sutil, sem borda dura. Encapsula `TextFormField` para cumprir a Lei 1
/// (telas nunca usam `TextField`/`TextFormField` cru).
///
/// A cápsula (altura de 52px, fundo, raio e anel de foco) vem de
/// `AppFieldCapsule`; aqui só mora o editor de texto.
class AppTextInput extends StatefulWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.invalid = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? placeholder;

  /// Equivalente à prop `invalid` do React: borda vermelha sem bloquear a digitação.
  final bool invalid;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  /// O anel de foco agora é pintado pela cápsula (não mais pelo
  /// `focusedBorder` do decorator), então o campo precisa saber se está focado.
  FocusNode? _internalFocusNode;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(AppTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
      _handleFocusChange();
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _internalFocusNode?.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);

    return AppFieldCapsule(
      focused: _focused,
      invalid: widget.invalid,
      leading: widget.prefixIcon,
      trailing: widget.suffixIcon,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        cursorColor: inputColors.focus,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.xl,
          color: widget.enabled ? inputColors.foreground : inputColors.muted,
        ),
        decoration: InputDecoration(
          // Decorator sem nenhuma decoração: fundo, borda e altura são da
          // cápsula. Aqui ele é só o editor de texto.
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.placeholder,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.xl,
            color: inputColors.placeholder,
          ),
        ),
      ),
    );
  }
}

/// Use-cases da galeria (F2.5).
WidgetbookComponent buildTextInputWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'TextInput',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const _TextInputUseCase(),
      ),
    ],
  );
}

class _TextInputUseCase extends StatefulWidget {
  const _TextInputUseCase();

  @override
  State<_TextInputUseCase> createState() => _TextInputUseCaseState();
}

class _TextInputUseCaseState extends State<_TextInputUseCase> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextInput(
              controller: _controller,
              placeholder: 'Digite algo...',
            ),
            const SizedBox(height: AppSpacing.space4),
            const AppTextInput(placeholder: 'Campo inválido', invalid: true),
            const SizedBox(height: AppSpacing.space4),
            const AppTextInput(placeholder: 'Desabilitado', enabled: false),
          ],
        ),
      ),
    );
  }
}
