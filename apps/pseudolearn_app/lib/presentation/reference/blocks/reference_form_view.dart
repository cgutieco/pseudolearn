import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_form.dart';
import '../../components/typography/app_text.dart';
import '../../editor/help/help_code_views.dart';
import '../../editor/syntax_category_color.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'reference_code_frame.dart';

final class ReferenceFormView extends StatelessWidget {
  final List<List<ReferenceFormSegment>> lines;

  const ReferenceFormView({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final spans = <InlineSpan>[];
    for (final (index, line) in lines.indexed) {
      if (index > 0) spans.add(const TextSpan(text: '\n'));
      spans.addAll(line.map((segment) => _segmentSpan(segment, theme)));
    }
    return ReferenceCodeFrame(
      label: AppLocalizations.of(context)!.referenceFormLabel,
      child: Text.rich(
        TextSpan(children: spans),
        style: resolveAppTextStyle(
          context,
          AppTextVariant.codeEditor,
          color: theme.syntax.ink,
        ),
        softWrap: false,
      ),
    );
  }
}

InlineSpan _segmentSpan(ReferenceFormSegment segment, AppThemeExtension theme) {
  return switch (segment) {
    ReferenceFormToken(:final token) => TextSpan(
      text: token.text,
      style: token.category == null
          ? null
          : TextStyle(
              color: syntaxCategoryColor(token.category!, theme.syntax),
            ),
    ),
    ReferenceFormSlot(:final label) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: HelpSlotChip(label: label),
    ),
    ReferenceFormOptional(:final mark) => TextSpan(
      text: mark,
      style: TextStyle(color: theme.colors.text.tertiary),
    ),
  };
}
