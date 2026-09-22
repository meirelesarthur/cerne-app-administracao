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

bool _containsNumericLiteral(String source) =>
    RegExp(r'(^|[^A-Za-z0-9_.])\d+(?:\.\d+)?').hasMatch(source);

void main() {
  group('M11 — integridade dos tokens Flutter', () {
    test('proíbe cores, fontes, raios e sombras literais fora do gerado', () {
      final forbidden = RegExp(
        r'\bColors\.[A-Za-z]+|\bColor\(\s*0x|\bColor\.from(?:ARGB|RGBO)\s*\(|fontSize\s*:\s*-?\d|fontFamily\s*:\s*["\u0027]|\bFontWeight\.(?:normal|bold|w[1-9]00)|BorderRadius\.circular\(\s*-?\d|Radius\.circular\(\s*-?\d|\bBoxShadow\s*\(',
      );
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        if (relative.startsWith('lib/design/generated/')) continue;
        final source = _withoutComments(file.readAsStringSync());
        for (final match in forbidden.allMatches(source)) {
          violations.add('$relative:${_lineAt(source, match.start)}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Valores visuais devem consumir AppColors/AppTypography/AppRadius/'
            'AppShadows: ${violations.join(', ')}',
      );
    });

    test('proíbe espaçamento literal em insets e gaps de eixo único', () {
      final edgeInsets = RegExp(
        r'EdgeInsets\.(?:all|only|symmetric)\(([\s\S]*?)\)',
      );
      final sizedBox = RegExp(r'SizedBox\(([\s\S]*?)\)');
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        if (relative.startsWith('lib/design/generated/')) continue;
        final source = _withoutComments(file.readAsStringSync());

        for (final match in edgeInsets.allMatches(source)) {
          if (_containsNumericLiteral(match.group(1)!)) {
            violations.add('$relative:${_lineAt(source, match.start)}');
          }
        }
        for (final match in sizedBox.allMatches(source)) {
          final body = match.group(1)!;
          final axes = RegExp(
            r'\b(?:width|height)\s*:',
          ).allMatches(body).length;
          if (!body.contains('child:') &&
              axes == 1 &&
              _containsNumericLiteral(body)) {
            violations.add('$relative:${_lineAt(source, match.start)}');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Insets e gaps devem consumir AppSpacing: ${violations.join(', ')}',
      );
    });

    test('animações visuais consomem AppMotion', () {
      final visualDuration = RegExp(
        r'duration\s*:\s*(?:const\s+)?Duration\s*\(',
      );
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final relative = _relative(file);
        if (relative.startsWith('lib/design/generated/')) continue;
        final source = _withoutComments(file.readAsStringSync());
        for (final match in visualDuration.allMatches(source)) {
          final prefix = source.substring(0, match.start);
          final constructorStart = prefix.lastIndexOf('SimulatedLoad(');
          final constructorEnd = prefix.lastIndexOf(');');
          if (constructorStart > constructorEnd) continue;
          violations.add('$relative:${_lineAt(source, match.start)}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Durações de animação devem consumir AppMotion: ${violations.join(', ')}',
      );
    });

    test('Outfit e cabeçalhos de geração permanecem obrigatórios', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final theme = File('lib/design/theme/app_theme.dart').readAsStringSync();
      expect(pubspec, contains('family: Outfit'));
      expect(theme, contains('fontFamily: AppTypography.fontFamily'));

      final generated = Directory('lib/design/generated');
      final files = _dartFiles(generated).toList();
      expect(files, hasLength(7));
      for (final file in files) {
        expect(
          file.readAsStringSync(),
          startsWith('// GERADO AUTOMATICAMENTE'),
          reason: '${_relative(file)} perdeu o cabeçalho de geração.',
        );
      }
    });
  });
}
