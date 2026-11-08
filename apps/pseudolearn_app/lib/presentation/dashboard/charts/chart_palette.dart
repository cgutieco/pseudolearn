import 'package:flutter/widgets.dart';
import '../../theme/app_theme.dart';

final class ChartPalette {
  final Color lessons;
  final Color exercises;
  final Color concepts;
  final Color creations;
  final Color track;
  final Color accent;

  const ChartPalette({
    required this.lessons,
    required this.exercises,
    required this.concepts,
    required this.creations,
    required this.track,
    required this.accent,
  });

  factory ChartPalette.of(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return ChartPalette(
      lessons: colors.actions.primary.bgDefault,
      exercises: colors.severities.success.fg,
      concepts: colors.severities.info.fg,
      creations: colors.severities.warning.fg,
      track: colors.surfaces.subtle,
      accent: colors.text.link,
    );
  }
}
