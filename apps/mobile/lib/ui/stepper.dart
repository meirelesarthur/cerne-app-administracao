import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Stepper.tsx` — stepper numérico (quantidade), controlado
/// (`value`/`onChanged`), encapsulando os botões +/- e o campo numérico para
/// cumprir a Lei 1. Nome `AppStepper` (não `AppStep`) para não colidir com o
/// `Stepper` nativo do Material.
class AppStepper extends StatefulWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = double.infinity,
    this.step = 1,
    this.suffix,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final num min;
  final num max;
  final num step;
  final String? suffix;

  @override
  State<AppStepper> createState() => _AppStepperState();
}

class _AppStepperState extends State<AppStepper> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );

  String _format(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void didUpdateWidget(covariant AppStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = _format(widget.value);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  num _clamp(num v) => v.clamp(widget.min, widget.max);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    const height = AppSize.controlLg;

    Widget stepButton({
      required AppIconData icon,
      required String label,
      required VoidCallback? onTap,
    }) {
      return Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: AppSize.iconBtnMd,
            height: height,
            child: AppIcon(
              icon,
              size: AppSize.iconSm,
              color: onTap == null ? semantic.fgSubtle : semantic.fgMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          stepButton(
            icon: AppIcons.minus,
            label: 'Diminuir',
            onTap: widget.value <= widget.min
                ? null
                : () => widget.onChanged(_clamp(widget.value - widget.step)),
          ),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: semantic.borderDefault),
                  right: BorderSide(color: semantic.borderDefault),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.xl,
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (text) {
                        final parsed = num.tryParse(text.replaceAll(',', '.'));
                        widget.onChanged(_clamp(parsed ?? widget.min));
                      },
                    ),
                  ),
                  if (widget.suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.space2),
                      child: Text(
                        widget.suffix!,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.sm,
                          color: semantic.fgSubtle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          stepButton(
            icon: AppIcons.plus,
            label: 'Aumentar',
            onTap: widget.value >= widget.max
                ? null
                : () => widget.onChanged(_clamp(widget.value + widget.step)),
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildStepperWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Stepper',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const _StepperUseCase(),
      ),
    ],
  );
}

class _StepperUseCase extends StatefulWidget {
  const _StepperUseCase();

  @override
  State<_StepperUseCase> createState() => _StepperUseCaseState();
}

class _StepperUseCaseState extends State<_StepperUseCase> {
  num _qty = 3;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        child: AppStepper(
          value: _qty,
          onChanged: (v) => setState(() => _qty = v),
          max: 10,
          suffix: 'sc',
        ),
      ),
    );
  }
}
