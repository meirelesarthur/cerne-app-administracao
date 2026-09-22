import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/button.dart';

import 'golden_helpers.dart';

void main() {
  goldenTest(
    'AppButton — variantes e temas',
    fileName: 'app_button',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final variant in AppThemeVariant.values)
          for (final buttonVariant in AppButtonVariant.values)
            GoldenTestScenario(
              name: '${variant.name}_${buttonVariant.name}',
              child: themedGolden(
                variant,
                AppButton(
                  variant: buttonVariant,
                  onPressed: () {},
                  child: const Text('Botão'),
                ),
              ),
            ),
      ],
    ),
  );
}
