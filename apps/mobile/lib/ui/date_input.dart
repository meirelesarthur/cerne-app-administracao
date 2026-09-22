import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'field_capsule.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

/// Campo de data do catálogo — padrão global do produto: digitação livre com
/// máscara automática `DD/MM/AAAA` **e** um atalho de calendário (ícone à
/// direita) que abre o `showDatePicker` do Material, estilizado pelo
/// `datePickerTheme` do tema ativo (`buildAppTheme`, Lei 3 do CLAUDE.md — nada
/// aqui redecora cor/raio localmente).
///
/// Substitui o uso de `AppTextInput` com `placeholder: 'AAAA-MM-DD'` nos
/// campos `FeatureFieldType.date` do catálogo funcional
/// (`mapped_feature_screen.dart`) — mesma API de `initialValue`/`onChanged`
/// para ser um drop-in.
class AppDateInput extends StatefulWidget {
  const AppDateInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.invalid = false,
    this.enabled = true,
    this.focusNode,
    this.firstDate,
    this.lastDate,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       );

  final TextEditingController? controller;

  /// Valor inicial já no formato `DD/MM/AAAA`.
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool invalid;
  final bool enabled;
  final FocusNode? focusNode;

  /// Limites do calendário. Padrão generoso (1900 até 20 anos à frente) —
  /// cadastros de animal cobrem tanto ficha histórica quanto planejamento.
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<AppDateInput> createState() => _AppDateInputState();
}

class _AppDateInputState extends State<AppDateInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
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

  /// Só resolve para uma data quando os três grupos estão completos e formam
  /// um calendário válido — evita abrir o seletor numa data lixo enquanto a
  /// pessoa ainda está digitando.
  DateTime? get _parsedDate {
    final match = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})$',
    ).firstMatch(_controller.text);
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    final isValid =
        date.day == day && date.month == month && date.year == year;
    return isValid ? date : null;
  }

  String _format(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final now = DateTime.now();
    final firstDate = widget.firstDate ?? DateTime(1900);
    final lastDate = widget.lastDate ?? DateTime(now.year + 20);
    final initial = _parsedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate)
          ? firstDate
          : (initial.isAfter(lastDate) ? lastDate : initial),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Selecionar data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked == null || !mounted) return;
    final formatted = _format(picked);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    widget.onChanged?.call(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);

    return AppFieldCapsule(
      focused: _focused,
      invalid: widget.invalid,
      trailing: IconButton(
        onPressed: widget.enabled ? _openPicker : null,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: AppIcon(
          AppIcons.calendar,
          size: AppSize.iconMd,
          color: widget.enabled ? inputColors.muted : inputColors.placeholder,
        ),
        tooltip: 'Escolher no calendário',
      ),
      child: TextFormField(
        controller: _controller,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: const [_BrDateInputFormatter()],
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
          hintText: 'DD/MM/AAAA',
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

/// Máscara `DD/MM/AAAA`: filtra tudo que não é dígito e insere as barras nas
/// posições 2 e 4 conforme a pessoa digita, sem nunca deixar uma barra sobrar
/// no fim (o que empurraria o cursor e travaria o apagar).
class _BrDateInputFormatter extends TextInputFormatter {
  const _BrDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      final isGroupEnd = i == 1 || i == 3;
      final isLastChar = i == limited.length - 1;
      if (isGroupEnd && !isLastChar) buffer.write('/');
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Use-cases da galeria (F2.5).
WidgetbookComponent buildDateInputWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'DateInput',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDateInput(),
                SizedBox(height: AppSpacing.space4),
                AppDateInput(initialValue: '15/03/1998'),
                SizedBox(height: AppSpacing.space4),
                AppDateInput(invalid: true),
                SizedBox(height: AppSpacing.space4),
                AppDateInput(enabled: false, initialValue: '01/01/2024'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
