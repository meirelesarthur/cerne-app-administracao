import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `ToggleSwitch.tsx` — interruptor on/off acessível (`role="switch"`).
/// Usa as métricas dedicadas de `AppSize.toggleTrack`/`toggleThumb` (já existentes
/// no design system para este componente) em vez de replicar os valores arbitrários
/// do Tailwind (`h-6 w-11`) do protótipo React.
class AppToggleSwitch extends StatelessWidget {
  const AppToggleSwitch({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.disabled = false,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;

  /// Rótulo acessível (equivalente ao `aria-label` do React) — obrigatório.
  final String label;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final trackHeight = AppSize.toggleThumb + AppSpacing.space2;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Semantics(
        toggled: checked,
        label: label,
        enabled: !disabled,
        child: Material(
          color: AppColors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: disabled ? null : () => onChanged(!checked),
            canRequestFocus: !disabled,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppSize.control,
              height: AppSize.control,
              child: Center(
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.easingInOut,
                  width: AppSize.toggleTrack,
                  height: trackHeight,
                  padding: const EdgeInsets.all(AppSpacing.space1),
                  decoration: BoxDecoration(
                    color: checked
                        ? semantic.accentDefault
                        : AppColors.neutral300,
                    borderRadius: BorderRadius.circular(trackHeight),
                  ),
                  child: AnimatedAlign(
                    duration: AppMotion.base,
                    curve: AppMotion.easingInOut,
                    alignment: checked
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: AppSize.toggleThumb,
                      height: AppSize.toggleThumb,
                      decoration: BoxDecoration(
                        color: semantic.bgSurface,
                        shape: BoxShape.circle,
                        boxShadow: semantic.shadowCard,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildToggleSwitchWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ToggleSwitch',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const _ToggleSwitchUseCase(),
      ),
    ],
  );
}

class _ToggleSwitchUseCase extends StatefulWidget {
  const _ToggleSwitchUseCase();

  @override
  State<_ToggleSwitchUseCase> createState() => _ToggleSwitchUseCaseState();
}

class _ToggleSwitchUseCaseState extends State<_ToggleSwitchUseCase> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: AppSpacing.space6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppToggleSwitch(
            checked: _on,
            onChanged: (v) => setState(() => _on = v),
            label: 'Notificações',
          ),
          const AppToggleSwitch(
            checked: true,
            onChanged: _noop,
            label: 'Desabilitado (ligado)',
            disabled: true,
          ),
          const AppToggleSwitch(
            checked: false,
            onChanged: _noop,
            label: 'Desabilitado (desligado)',
            disabled: true,
          ),
        ],
      ),
    );
  }

  static void _noop(bool _) {}
}
