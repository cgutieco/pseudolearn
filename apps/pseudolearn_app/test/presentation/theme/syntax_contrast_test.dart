import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_primitives.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/editor_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/syntax_colors.dart';
import 'contrast_test.dart';

void main() {
  group('Syntax Highlighting Contrast Verifications (RFC 001 §1.6)', () {
    test('All syntax tokens meet >= 4.5:1 against the 4 editor backgrounds in light mode', () {
      const syntax = AppSyntaxColors.light();
      const editor = EditorColors.light();

      final backgrounds = <String, Color>{
        'surface': editor.surface,
        'lineActive': editor.lineActive,
        'lineExecution': editor.lineExecution,
        'selection': editor.selection,
      };

      final syntaxTokens = <String, Color>{
        'keywordStructured': syntax.keywordStructured,
        'keywordProcedural': syntax.keywordProcedural,
        'keywordOop': syntax.keywordOop,
        'identifier': syntax.identifier,
        'literalNumber': syntax.literalNumber,
        'literalText': syntax.literalText,
        'literalBoolean': syntax.literalBoolean,
        'ink': syntax.ink,
        'comment': syntax.comment,
        'invalid': syntax.invalid,
      };

      for (final bgEntry in backgrounds.entries) {
        for (final tokenEntry in syntaxTokens.entries) {
          final ratio = contrastRatio(tokenEntry.value, bgEntry.value);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Light mode token "${tokenEntry.key}" on background "${bgEntry.key}" failed with ratio $ratio (min 4.5)',
          );
        }
      }
    });

    test('All syntax tokens meet >= 4.5:1 against the 4 editor backgrounds in dark mode', () {
      const syntax = AppSyntaxColors.dark();
      const editor = EditorColors.dark();

      final backgrounds = <String, Color>{
        'surface': editor.surface,
        'lineActive': editor.lineActive,
        'lineExecution': editor.lineExecution,
        'selection': editor.selection,
      };

      final syntaxTokens = <String, Color>{
        'keywordStructured': syntax.keywordStructured,
        'keywordProcedural': syntax.keywordProcedural,
        'keywordOop': syntax.keywordOop,
        'identifier': syntax.identifier,
        'literalNumber': syntax.literalNumber,
        'literalText': syntax.literalText,
        'literalBoolean': syntax.literalBoolean,
        'ink': syntax.ink,
        'comment': syntax.comment,
        'invalid': syntax.invalid,
      };

      for (final bgEntry in backgrounds.entries) {
        for (final tokenEntry in syntaxTokens.entries) {
          final ratio = contrastRatio(tokenEntry.value, bgEntry.value);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Dark mode token "${tokenEntry.key}" on background "${bgEntry.key}" failed with ratio $ratio (min 4.5)',
          );
        }
      }
    });

    test('Negative fixture: low-contrast syntax token fails threshold check', () {
      const badSyntaxToken = ColorPrimitives.neutral200;
      const lightBg = ColorPrimitives.neutral0;
      final ratio = contrastRatio(badSyntaxToken, lightBg);
      expect(ratio, lessThan(4.5));
    });
  });
}
