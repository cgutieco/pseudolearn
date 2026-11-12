import 'package:material_ui/material_ui.dart';
import '../../../domain/model/analysis/highlight_span.dart';
import '../../../domain/model/help/help_form.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'help_code_spans.dart';

final class HelpCodeView extends StatelessWidget {
  final String source;
  final List<HighlightSpan> highlightSpans;

  const HelpCodeView({
    super.key,
    required this.source,
    this.highlightSpans = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return _CodeSurface(
      child: Text.rich(
        TextSpan(
          children: highlightedCodeSpans(
            source.trimRight(),
            highlightSpans,
            theme.syntax,
          ),
        ),
        style: resolveAppTextStyle(
          context,
          AppTextVariant.codeCaption,
          color: theme.syntax.ink,
        ),
        softWrap: false,
      ),
    );
  }
}

final class HelpFormView extends StatelessWidget {
  final List<HelpFormLine> lines;

  const HelpFormView({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final style = resolveAppTextStyle(
      context,
      AppTextVariant.codeCaption,
      color: theme.syntax.ink,
    );
    final spans = <InlineSpan>[];
    for (final (index, line) in lines.indexed) {
      if (index > 0) spans.add(const TextSpan(text: '\n'));
      spans.addAll(formLineSpans(line, theme.syntax, _slotChip));
    }
    return _CodeSurface(
      child: Text.rich(TextSpan(children: spans), style: style, softWrap: false),
    );
  }
}

InlineSpan _slotChip(String label) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
  child: HelpSlotChip(label: label),
);

final class HelpSlotChip extends StatelessWidget {
  final String label;

  const HelpSlotChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      ),
      child: AppText(
        '«$label»',
        variant: AppTextVariant.codeCaption,
        color: theme.colors.text.primary,
      ),
    );
  }
}

final class _CodeSurface extends StatelessWidget {
  final Widget child;

  const _CodeSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}
