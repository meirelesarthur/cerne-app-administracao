// GERADO AUTOMATICAMENTE — não editar à mão.
// Fonte: tokens/tokens.json (DTCG) <- design/tokens.ts
// Pipeline: `npm run tokens:export` seguido de `npm run tokens:export:flutter`.
// Qualquer ajuste de valor deve entrar em design/tokens.ts (Lei 3/5 do CLAUDE.md).

import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 40);

  static const Duration revealMenuItemStagger = Duration(milliseconds: 30);

  static const Cubic easingIn = Cubic(0.4, 0, 1, 1);
  static const Cubic easingOut = Cubic(0, 0, 0.2, 1);
  static const Cubic easingInOut = Cubic(0.4, 0, 0.2, 1);
  static const Cubic easingSpring = Cubic(0.34, 1.56, 0.64, 1);
}
