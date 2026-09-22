import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'field_capsule.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

/// Uma cor de uma paleta fechada — `value` é o hex EXATO aceito pelo
/// contrato (case preservado, ex. `#FF99FF`), `label` é o rótulo humano.
/// Espelha um `case` de enum de cor da API (ex. `AreaColor`,
/// `MarkingColorEnum`); a fonte canônica dos valores vive no catálogo de
/// domínio, esta é só a forma de transporte para o componente.
class AppColorOption {
  const AppColorOption({required this.value, required this.label});

  /// Hex verbatim do enum — NUNCA normalizado (nem `.toUpperCase()`), senão
  /// o `Rule::enum` da API rejeita com 422.
  final String value;
  final String label;
}

/// Campo de cor do catálogo, em dois modos:
///
/// - **Livre** (padrão, [palette] == null): swatch circular com preview ao
///   vivo + campo de texto com prefixo `#` e máscara hexadecimal. Aceita
///   qualquer hex, emitido sempre com `#` e maiúsculo. Usado onde a coluna
///   é `varchar` livre sem validação de conjunto.
/// - **Fechado** ([palette] != null): seletor de paleta fixa — o toque abre
///   uma lista de swatches rotulados e emite o `value` EXATO da opção
///   escolhida (case preservado). Usado onde a API valida a cor contra um
///   enum fechado (`Rule::enum`), ex. `cadastrar-area` (`AreaColor`) e
///   `marcacao` (`MarkingColorEnum`) — hex livre daria 422.
///
/// Mesma cápsula (`AppFieldCapsule`) dos demais campos de `ui/`, Lei 1/2 do
/// CLAUDE.md — o modo fechado é uma extensão por prop do componente
/// compartilhado, não uma cópia.
class AppColorInput extends StatefulWidget {
  const AppColorInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.invalid = false,
    this.enabled = true,
    this.focusNode,
    this.palette,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       ),
       assert(
         palette == null || controller == null,
         'Modo fechado (palette) não usa controller de texto livre.',
       );

  final TextEditingController? controller;

  /// Valor inicial em hex, com ou sem `#` (ex. `f6c23e` ou `#f6c23e`). No modo
  /// fechado, deve casar com o `value` de uma opção de [palette] (case exato).
  final String? initialValue;

  /// Disparado com a cor escolhida. No modo livre, o hex de 6 dígitos sempre
  /// com `#` e maiúsculo (ex. `#F6C23E`). No modo fechado, o `value` verbatim
  /// da opção da paleta (case preservado).
  final ValueChanged<String>? onChanged;
  final bool invalid;
  final bool enabled;
  final FocusNode? focusNode;

  /// Quando não-nulo, ativa o modo fechado: o campo só aceita as cores desta
  /// paleta e emite o `value` exato da opção escolhida.
  final List<AppColorOption>? palette;

  /// Predefinições de atalho na grade do swatch — reaproveita a paleta 500
  /// do design system (`AppColors`), sem inventar hex fora dos tokens
  /// gerados. O campo aceita qualquer hex digitado; isto é um atalho, não o
  /// domínio (Lei 3 do CLAUDE.md — nenhuma cor nova aqui, só reuso).
  static const List<Color> presets = [
    AppColors.brand500,
    AppColors.red500,
    AppColors.amber500,
    AppColors.blue500,
    AppColors.neutral800,
    AppColors.neutral500,
    AppColors.brand700,
    AppColors.red700,
    AppColors.amber700,
    AppColors.blue700,
    AppColors.neutral400,
    AppColors.neutral200,
  ];

  @override
  State<AppColorInput> createState() => _AppColorInputState();
}

class _AppColorInputState extends State<AppColorInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: _strip(widget.initialValue));
  FocusNode? _internalFocusNode;
  bool _focused = false;

  /// Modo fechado: valor atualmente selecionado, verbatim (case preservado).
  String? _selectedValue;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  static String _strip(String? hex) {
    if (hex == null) return '';
    return hex.replaceFirst('#', '').toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  Color? get _parsedColor {
    final digits = _controller.text;
    if (digits.length != 6) return null;
    final value = int.tryParse(digits, radix: 16);
    if (value == null) return null;
    // `Color(0x...)` literal é proibido pelo teste de integridade de tokens
    // (M11) — aqui não é uma cor de design hardcoded, é o parse de um hex
    // digitado pela pessoa, então o ARGB é montado em variável.
    const opaqueAlpha = 0xFF000000;
    return Color(opaqueAlpha | value);
  }

  void _setHex(String digits) {
    final upper = digits.toUpperCase();
    _controller.value = TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
    if (upper.length == 6) widget.onChanged?.call('#$upper');
  }

  Future<void> _openPresets() async {
    if (!widget.enabled) return;
    final picked = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) =>
          const _ColorPresetSheet(presets: AppColorInput.presets),
    );
    if (picked == null || !mounted) return;
    final hex = picked.toARGB32().toRadixString(16).substring(2).toUpperCase();
    _setHex(hex);
  }

  Future<void> _openClosedPalette() async {
    if (!widget.enabled) return;
    final picked = await showModalBottomSheet<AppColorOption>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) => _ClosedPaletteSheet(
        options: widget.palette!,
        selectedValue: _selectedValue,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedValue = picked.value);
    // Emite o `value` EXATO da opção — nunca normaliza case (senão 422).
    widget.onChanged?.call(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.palette != null) return _buildClosed(context);
    final inputColors = appInputColors(context);
    final swatchColor = _parsedColor;

    return AppFieldCapsule(
      focused: _focused,
      invalid: widget.invalid,
      leading: GestureDetector(
        onTap: _openPresets,
        child: Container(
          width: AppSize.iconMd,
          height: AppSize.iconMd,
          decoration: BoxDecoration(
            color: swatchColor ?? AppColors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: swatchColor == null
                  ? inputColors.placeholder
                  : AppColors.neutral0,
              width: 1.5,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '#',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.xl,
              color: widget.enabled ? inputColors.muted : inputColors.placeholder,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              onChanged: _setHex,
              enabled: widget.enabled,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(6),
                _UpperCaseTextFormatter(),
              ],
              cursorColor: inputColors.focus,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.xl,
                color: widget.enabled ? inputColors.foreground : inputColors.muted,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'F6C23E',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.xl,
                  color: inputColors.placeholder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosed(BuildContext context) {
    final inputColors = appInputColors(context);
    final swatchColor = _hexToColor(_selectedValue);

    AppColorOption? selected;
    for (final option in widget.palette!) {
      if (option.value == _selectedValue) {
        selected = option;
        break;
      }
    }

    return GestureDetector(
      onTap: _openClosedPalette,
      behavior: HitTestBehavior.opaque,
      child: AppFieldCapsule(
        invalid: widget.invalid,
        leading: Container(
          width: AppSize.iconMd,
          height: AppSize.iconMd,
          decoration: BoxDecoration(
            color: swatchColor ?? AppColors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: swatchColor == null
                  ? inputColors.placeholder
                  : AppColors.neutral0,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected?.label ?? 'Selecionar cor',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.xl,
                  color: selected == null
                      ? inputColors.placeholder
                      : (widget.enabled
                            ? inputColors.foreground
                            : inputColors.muted),
                ),
              ),
            ),
            AppIcon(
              AppIcons.chevronDown,
              size: AppSize.iconSm,
              color: inputColors.placeholder,
            ),
          ],
        ),
      ),
    );
  }
}

/// Converte um hex `#RRGGBB` (qualquer case) para `Color`, sem literal
/// `Color(0x...)` (proibido pelo teste de integridade de tokens, M11) — o
/// ARGB é montado em variável a partir do hex digitado/escolhido.
Color? _hexToColor(String? hex) {
  if (hex == null) return null;
  final digits = hex.replaceFirst('#', '');
  if (digits.length != 6) return null;
  final value = int.tryParse(digits, radix: 16);
  if (value == null) return null;
  const opaqueAlpha = 0xFF000000;
  return Color(opaqueAlpha | value);
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Grade de atalho aberta pelo toque no swatch — não é o domínio do campo
/// (que aceita qualquer hex), só um acesso rápido às cores mais comuns da
/// paleta do design system.
class _ColorPresetSheet extends StatelessWidget {
  const _ColorPresetSheet({required this.presets});

  final List<Color> presets;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.space4),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: [
            for (final color in presets)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: AppSize.iconMd * 1.5,
                  height: AppSize.iconMd * 1.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral200),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lista de seleção do modo fechado — cada linha é um swatch rotulado da
/// paleta do contrato; tocar devolve a opção (com o `value` hex verbatim).
class _ClosedPaletteSheet extends StatelessWidget {
  const _ClosedPaletteSheet({required this.options, this.selectedValue});

  final List<AppColorOption> options;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.space4),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              InkWell(
                onTap: () => Navigator.of(context).pop(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space3,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppSize.iconMd,
                        height: AppSize.iconMd,
                        decoration: BoxDecoration(
                          color: _hexToColor(option.value) ??
                              AppColors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.neutral200),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.xl,
                            color: inputColors.foreground,
                          ),
                        ),
                      ),
                      if (option.value == selectedValue)
                        AppIcon(
                          AppIcons.check,
                          size: AppSize.iconSm,
                          color: inputColors.focus,
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

/// Use-cases da galeria (F2.5).
WidgetbookComponent buildColorInputWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ColorInput',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppColorInput(),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(initialValue: '#f6c23e'),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(invalid: true),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(enabled: false, initialValue: '#22C55E'),
                SizedBox(height: AppSpacing.space4),
                // Modo fechado: paleta fixa (espelho de um enum de cor da API).
                AppColorInput(
                  initialValue: '#4caf50',
                  palette: [
                    AppColorOption(value: '#ffee58', label: 'Amarelo'),
                    AppColorOption(value: '#4caf50', label: 'Verde'),
                    AppColorOption(value: '#FF69B4', label: 'Rosa Pink'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
