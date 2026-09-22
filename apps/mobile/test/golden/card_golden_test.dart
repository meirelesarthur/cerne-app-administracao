import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/card.dart';

import 'golden_helpers.dart';

void main() {
  goldenTest(
    'AppCard — variantes e temas',
    fileName: 'app_card',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final variant in AppThemeVariant.values)
          for (final cardVariant in AppCardVariant.values)
            GoldenTestScenario(
              name: '${variant.name}_${cardVariant.name}',
              child: SizedBox(
                width: 220,
                child: themedGolden(
                  variant,
                  AppCard(
                    variant: cardVariant,
                    child: const Text('Conteúdo do card'),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
