import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_anatomy.dart';
import '../../../domain/model/reference/reference_token.dart';
import '../../components/typography/app_text.dart';
import '../../editor/syntax_category_color.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';

const double _labelMaxWidth = 168;

final class ReferenceAnatomyView extends StatelessWidget {
  final List<ReferenceAnatomyPart> parts;
  final ValueChanged<String> onOpenSection;

  const ReferenceAnatomyView({
    super.key,
    required this.parts,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: _AnatomyBody(parts: parts, onOpenSection: onOpenSection),
    );
  }
}

final class _AnatomyBody extends StatelessWidget {
  final List<ReferenceAnatomyPart> parts;
  final ValueChanged<String> onOpenSection;

  const _AnatomyBody({required this.parts, required this.onOpenSection});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppLocalizations.of(context)!.referenceAnatomyLabel,
          variant: AppTextVariant.overline,
          color: AppThemeExtension.of(context).colors.text.tertiary,
        ),
        const SizedBox(height: SpacingTokens.space2),
        Wrap(
          spacing: SpacingTokens.space3,
          runSpacing: SpacingTokens.space3,
          children: [
            for (final part in parts)
              _AnatomyPartView(part: part, onOpenSection: onOpenSection),
          ],
        ),
      ],
    );
  }
}

final class _AnatomyPartView extends StatelessWidget {
  final ReferenceAnatomyPart part;
  final ValueChanged<String> onOpenSection;

  const _AnatomyPartView({required this.part, required this.onOpenSection});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnatomyCode(tokens: part.tokens),
        const SizedBox(height: SpacingTokens.space1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _labelMaxWidth),
          child: ReferenceRunsText(
            runs: part.label,
            onOpenSection: onOpenSection,
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
        ),
      ],
    );
  }
}

final class _AnatomyCode extends StatelessWidget {
  final List<ReferenceToken> tokens;

  const _AnatomyCode({required this.tokens});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colors.borders.strong,
            width: BorderMetricsTokens.widthEmphasis,
          ),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [for (final token in tokens) _tokenSpan(token, theme)],
        ),
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

TextSpan _tokenSpan(ReferenceToken token, AppThemeExtension theme) {
  final category = token.category;
  return TextSpan(
    text: token.text,
    style: category == null
        ? null
        : TextStyle(color: syntaxCategoryColor(category, theme.syntax)),
  );
}
