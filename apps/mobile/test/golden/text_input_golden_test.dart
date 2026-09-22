import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/text_input.dart';

import 'golden_helpers.dart';

void main() {
  goldenTest(
    'AppTextInput — estados e temas',
    fileName: 'app_text_input',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final variant in AppThemeVariant.values) ...[
          GoldenTestScenario(
            name: '${variant.name}_placeholder',
            child: SizedBox(
              width: 240,
              child: themedGolden(
                variant,
                const AppTextInput(placeholder: 'Digite aqui'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${variant.name}_invalid',
            child: SizedBox(
              width: 240,
              child: themedGolden(
                variant,
                const AppTextInput(
                  initialValue: 'valor inválido',
                  invalid: true,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${variant.name}_disabled',
            child: SizedBox(
              width: 240,
              child: themedGolden(
                variant,
                const AppTextInput(
                  initialValue: 'desabilitado',
                  enabled: false,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
