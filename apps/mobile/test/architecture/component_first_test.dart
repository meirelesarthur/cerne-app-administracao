import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _dartFiles(Directory directory) sync* {
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _relative(File file) => file.path
    .replaceFirst('${Directory.current.path}${Platform.pathSeparator}', '')
    .replaceAll('\\', '/');

String _withoutComments(String source) {
  final withoutBlocks = source.replaceAllMapped(
    RegExp(r'/\*[\s\S]*?\*/'),
    (match) => List.filled(match.group(0)!.split('\n').length, '').join('\n'),
  );
  return withoutBlocks.replaceAll(RegExp(r'//[^\r\n]*'), '');
}

int _lineAt(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

void main() {
  group('M10 — arquitetura Component-First', () {
    test('proíbe controles Flutter crus fora do catálogo UI', () {
      final forbidden = RegExp(
        r'\b(?:InkWell|GestureDetector|InkResponse|ElevatedButton|FilledButton|OutlinedButton|TextButton|IconButton|TextFormField|TextField|DropdownButton|Checkbox|Switch|Stepper)\s*\(',
      );
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        if (relative.startsWith('lib/ui/')) continue;
        final source = _withoutComments(file.readAsStringSync());
        for (final match in forbidden.allMatches(source)) {
          violations.add('$relative:${_lineAt(source, match.start)}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Controles interativos visíveis devem ser encapsulados em lib/ui: '
            '${violations.join(', ')}',
      );
    });

    test('proíbe imports diretos de componentes fora do barrel ui.dart', () {
      final directImport = RegExp(
        r'''import\s+['"][^'"]*/ui/(?!ui\.dart)[^'"]+['"]''',
      );
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        if (relative.startsWith('lib/ui/')) continue;
        final source = file.readAsStringSync();
        for (final match in directImport.allMatches(source)) {
          violations.add('$relative:${_lineAt(source, match.start)}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Consuma o catálogo público por lib/ui/ui.dart: '
            '${violations.join(', ')}',
      );
    });

    test('a iconografia entra pelo catálogo, nunca pelo pacote', () {
      // A migração para Hugeicons (docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md) só se
      // sustenta se o pacote ficar atrás de `AppIcon`: é ele que aplica o traço
      // 1.2 e o único ponto onde trocar de família custaria uma linha.
      final lucide = RegExp(r'''package:lucide_icons_flutter/''');
      final hugeicons = RegExp(r'''package:hugeicons/''');
      final residual = <String>[];
      final leaked = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        final source = file.readAsStringSync();
        for (final match in lucide.allMatches(source)) {
          residual.add('$relative:${_lineAt(source, match.start)}');
        }
        if (relative == 'lib/ui/app_icon.dart') continue;
        for (final match in hugeicons.allMatches(source)) {
          leaked.add('$relative:${_lineAt(source, match.start)}');
        }
      }

      expect(
        residual,
        isEmpty,
        reason:
            'lucide_icons_flutter saiu do projeto na E5: ${residual.join(', ')}',
      );
      expect(
        leaked,
        isEmpty,
        reason:
            'Só lib/ui/app_icon.dart importa package:hugeicons; o resto consome '
            'AppIcon/AppIcons: ${leaked.join(', ')}',
      );
    });

    test('todo widget público possui caso registrado no Widgetbook', () {
      final barrel = File('lib/ui/ui.dart').readAsStringSync();
      final widgetbook = File('lib/widgetbook_app.dart').readAsStringSync();
      final exports = RegExp(
        r"export '([^']+\.dart)';",
      ).allMatches(barrel).map((match) => match.group(1)!).toList();
      final missingBuilders = <String>[];
      final missingRegistrations = <String>[];

      for (final exportedPath in exports) {
        final componentSource = File('lib/ui/$exportedPath').readAsStringSync();
        final builder = RegExp(
          r'WidgetbookComponent\s+(build\w+WidgetbookComponent)\s*\(',
        ).firstMatch(componentSource)?.group(1);
        if (builder == null) {
          missingBuilders.add(exportedPath);
        } else if (!widgetbook.contains('$builder()')) {
          missingRegistrations.add('$exportedPath:$builder');
        }
      }

      expect(
        missingBuilders,
        isEmpty,
        reason:
            'Widgets públicos sem builder do Widgetbook: '
            '${missingBuilders.join(', ')}',
      );
      expect(
        missingRegistrations,
        isEmpty,
        reason:
            'Builders ausentes de lib/widgetbook_app.dart: '
            '${missingRegistrations.join(', ')}',
      );
    });
  });
}
