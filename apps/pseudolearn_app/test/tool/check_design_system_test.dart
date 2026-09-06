import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../../tool/check_design_system.dart';

Directory _fixture(String name, Map<String, String> files) {
  final dir = Directory.systemTemp.createTempSync('design_system_$name');
  addTearDown(() => dir.deleteSync(recursive: true));
  files.forEach((relative, contents) {
    final file = File(p.join(dir.path, relative));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
  });
  return dir;
}

const String _tokensWithBundledFamily = '''
enum AppFontRole { ui, code }

final class TypographyTokens {
  static const Map<AppFontRole, String?> bundledFamilies = <AppFontRole, String?>{
    AppFontRole.ui: 'Ghost Sans',
    AppFontRole.code: null,
  };
}
''';

void main() {
  group('Design system checker', () {
    final packageRoot = Directory.current.path;

    test('Package code passes all design system checks cleanly', () {
      final violations = checkDesignSystem(packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: a bundled family absent from pubspec fails', () {
      final dir = _fixture('font_absent', {
        'lib/presentation/theme/tokens/typography.dart': _tokensWithBundledFamily,
        'pubspec.yaml': 'name: probe\nflutter:\n  uses-material-design: true\n',
      });

      final violations = checkBundledFonts(dir.path);
      expect(violations, hasLength(1));
      expect(violations.single.rule, 'bundled_font_missing');
    });

    test('Negative fixture: a declared font file missing on disk fails', () {
      final dir = _fixture('font_file_missing', {
        'lib/presentation/theme/tokens/typography.dart': _tokensWithBundledFamily,
        'pubspec.yaml': 'name: probe\n'
            'flutter:\n'
            '  fonts:\n'
            '    - family: Ghost Sans\n'
            '      fonts:\n'
            '        - asset: assets/fonts/GhostSans-Regular.ttf\n',
      });

      final violations = checkBundledFonts(dir.path);
      expect(violations, hasLength(1));
      expect(violations.single.rule, 'bundled_font_missing');
    });

    test('Negative fixture: a raw spacing literal fails', () {
      final dir = _fixture('spacing', {
        'lib/presentation/bad_spacing.dart': '''
import 'package:flutter/widgets.dart';

Widget build() => const Padding(
      padding: EdgeInsets.only(top: 48),
      child: SizedBox(height: 13),
    );
''',
      });

      final violations = checkSpacingLiterals(dir.path);
      expect(violations, hasLength(2));
      expect(violations.every((v) => v.rule == 'spacing_literal'), isTrue);
    });

    test('A named EdgeInsets constructor is inspected, not only the unnamed one', () {
      final dir = _fixture('spacing_named', {
        'lib/presentation/named.dart': 'const a = EdgeInsets.symmetric(horizontal: 7);\n',
      });

      expect(checkSpacingLiterals(dir.path), hasLength(1));
    });

    test('Spacing built from tokens passes', () {
      final dir = _fixture('spacing_ok', {
        'lib/presentation/good.dart': '''
const a = EdgeInsets.all(SpacingTokens.space4);
const b = SizedBox(height: SpacingTokens.space2);
''',
      });

      expect(checkSpacingLiterals(dir.path), isEmpty);
    });

    test('Negative fixture: a second DesignCanvas fails', () {
      final dir = _fixture('canvas', {
        'lib/composition/root.dart': 'final a = DesignCanvas(child: child);\n',
        'lib/presentation/shell/other.dart': 'final b = DesignCanvas(child: child);\n',
      });

      final violations = checkSingleCanvas(dir.path);
      expect(violations, hasLength(2));
      expect(violations.first.rule, 'canvas_not_unique');
    });

    test('The checker actually sees the real DesignCanvas site', () {
      final dir = _fixture('canvas_probe', {
        'lib/composition/root.dart': File(
          p.join(packageRoot, 'lib/composition/cubit_scope.dart'),
        ).readAsStringSync(),
        'lib/presentation/shell/extra.dart': 'final b = DesignCanvas(child: child);\n',
      });

      expect(checkSingleCanvas(dir.path), isNotEmpty);
    });

    test('A single DesignCanvas passes', () {
      final dir = _fixture('canvas_ok', {
        'lib/composition/root.dart': 'final a = DesignCanvas(child: child);\n',
      });

      expect(checkSingleCanvas(dir.path), isEmpty);
    });
  });
}
