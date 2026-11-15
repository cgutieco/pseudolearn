import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../editor/syntax_category_color.dart';
import '../theme/app_theme.dart';

const int _sentinelBase = 0xFFFF0000;

final class FigureColorMapper extends ColorMapper {
  final List<Color> roles;

  const FigureColorMapper(this.roles);

  factory FigureColorMapper.of(AppThemeExtension theme) {
    final colors = theme.colors;
    final syntax = theme.syntax;
    return FigureColorMapper([
      colors.text.primary,
      colors.surfaces.defaultSurface,
      syntax.keywordStructured,
      syntax.keywordProcedural,
      syntax.keywordOop,
      syntax.literalNumber,
      syntax.literalText,
      syntax.literalBoolean,
      colors.severities.success.fg,
      colors.severities.error.fg,
      colors.text.tertiary,
      colors.severities.warning.fg,
      syntaxCategoryColor(HighlightCategory.type, syntax),
    ]);
  }

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final role = color.toARGB32() - _sentinelBase - 1;
    if (role < 0 || role >= roles.length) return color;
    return roles[role];
  }

  @override
  bool operator ==(Object other) =>
      other is FigureColorMapper &&
      other.roles.length == roles.length &&
      _sameRoles(other.roles);

  bool _sameRoles(List<Color> others) {
    for (var index = 0; index < roles.length; index++) {
      if (roles[index] != others[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(roles);
}
