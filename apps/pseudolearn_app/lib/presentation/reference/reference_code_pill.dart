import 'package:flutter/material.dart';
import '../../domain/model/reference/reference_token.dart';
import '../components/typography/app_text.dart';
import '../editor/syntax_category_color.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';

final class ReferenceCodePill extends StatelessWidget {
  final List<ReferenceToken> tokens;

  const ReferenceCodePill({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: Text.rich(
        TextSpan(children: referenceTokenSpans(tokens, theme)),
        style: resolveAppTextStyle(
          context,
          AppTextVariant.codeInline,
          color: theme.syntax.ink,
        ),
      ),
    );
  }
}

List<InlineSpan> referenceTokenSpans(
  List<ReferenceToken> tokens,
  AppThemeExtension theme,
) {
  return tokens
      .map(
        (token) => TextSpan(
          text: token.text,
          style: token.category == null
              ? null
              : TextStyle(
                  color: syntaxCategoryColor(token.category!, theme.syntax),
                ),
        ),
      )
      .toList();
}
