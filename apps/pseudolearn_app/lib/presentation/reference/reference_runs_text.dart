import 'package:flutter/material.dart';
import '../../domain/model/reference/reference_run.dart';
import '../components/typography/app_text.dart';
import '../editor/help/help_code_views.dart';
import '../theme/app_theme.dart';
import 'reference_code_pill.dart';
import 'reference_link_text.dart';

final class ReferenceRunsText extends StatelessWidget {
  final List<ReferenceRun> runs;
  final AppTextVariant variant;
  final ValueChanged<String> onOpenSection;
  final Color? color;

  const ReferenceRunsText({
    super.key,
    required this.runs,
    required this.onOpenSection,
    this.variant = AppTextVariant.bodyDefault,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final style = resolveAppTextStyle(
      context,
      variant,
      color: color ?? theme.colors.text.primary,
    );
    return Text.rich(
      TextSpan(children: referenceRunSpans(runs, theme, onOpenSection)),
      style: style,
    );
  }
}

List<InlineSpan> referenceRunSpans(
  List<ReferenceRun> runs,
  AppThemeExtension theme,
  ValueChanged<String> onOpenSection,
) {
  return runs.map((run) => _span(run, theme, onOpenSection)).toList();
}

InlineSpan _span(
  ReferenceRun run,
  AppThemeExtension theme,
  ValueChanged<String> onOpenSection,
) {
  return switch (run) {
    ReferenceTextRun(:final text, :final emphasis) => TextSpan(
      text: text,
      style: _emphasisStyle(emphasis),
    ),
    ReferenceTermRun(:final text) => TextSpan(
      text: text,
      style: TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: theme.colors.text.tertiary,
      ),
    ),
    ReferenceDefinitionRun(:final text) => TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: theme.syntax.keywordStructured,
      ),
    ),
    _ => _embedded(run, onOpenSection),
  };
}

TextStyle? _emphasisStyle(ReferenceEmphasis emphasis) => switch (emphasis) {
  ReferenceEmphasis.none => null,
  ReferenceEmphasis.strong => const TextStyle(fontWeight: FontWeight.w600),
  ReferenceEmphasis.italic => const TextStyle(fontStyle: FontStyle.italic),
};

InlineSpan _embedded(ReferenceRun run, ValueChanged<String> onOpenSection) {
  return switch (run) {
    ReferenceCodeRun(:final tokens) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: ReferenceCodePill(tokens: tokens),
    ),
    ReferenceSlotRun(:final text) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: HelpSlotChip(label: text),
    ),
    ReferenceLinkRun(:final sectionId, :final text) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: ReferenceLinkText(
        text: text,
        onTap: () => onOpenSection(sectionId),
      ),
    ),
    ReferenceSpecLinkRun(:final sectionId, :final text) => _link(
      text,
      () => onOpenSection(sectionId),
    ),
    ReferenceLessonLinkRun(:final lessonId, :final text) => _link(
      text,
      () => onOpenSection('$lessonLinkPrefix$lessonId'),
    ),
    _ => TextSpan(text: run.plainText),
  };
}

const String lessonLinkPrefix = 'ruta:';

InlineSpan _link(String text, VoidCallback onTap) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: ReferenceLinkText(text: text, onTap: onTap),
);
