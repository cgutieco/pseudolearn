import 'dart:ui';
import 'color_primitives.dart';

final class AppSyntaxColors {
  final Color keywordStructured;
  final Color keywordProcedural;
  final Color keywordOop;
  final Color identifier;
  final Color literalNumber;
  final Color literalText;
  final Color literalBoolean;
  final Color ink;
  final Color comment;
  final Color invalid;

  const AppSyntaxColors({
    required this.keywordStructured,
    required this.keywordProcedural,
    required this.keywordOop,
    required this.identifier,
    required this.literalNumber,
    required this.literalText,
    required this.literalBoolean,
    required this.ink,
    required this.comment,
    required this.invalid,
  });

  const AppSyntaxColors.light()
      : keywordStructured = ColorPrimitives.blue800,
        keywordProcedural = ColorPrimitives.amber800,
        keywordOop = ColorPrimitives.rose800,
        identifier = ColorPrimitives.neutral900,
        literalNumber = ColorPrimitives.orange800,
        literalText = ColorPrimitives.green800,
        literalBoolean = ColorPrimitives.orange800,
        ink = ColorPrimitives.neutral700,
        comment = ColorPrimitives.neutral700,
        invalid = ColorPrimitives.red700;

  const AppSyntaxColors.dark()
      : keywordStructured = ColorPrimitives.blue300,
        keywordProcedural = ColorPrimitives.amber300,
        keywordOop = ColorPrimitives.rose300,
        identifier = ColorPrimitives.neutral200,
        literalNumber = ColorPrimitives.orange300,
        literalText = ColorPrimitives.green300,
        literalBoolean = ColorPrimitives.orange300,
        ink = ColorPrimitives.neutral400,
        comment = ColorPrimitives.neutral400,
        invalid = ColorPrimitives.red300;
}
