import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/document_heading.dart';
import '../../../components/typography/app_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class DocumentHeadingsNav extends StatelessWidget {
  final List<DocumentHeading> headings;
  final ValueChanged<int> onSelectHeading;

  const DocumentHeadingsNav({
    super.key,
    required this.headings,
    required this.onSelectHeading,
  });

  @override
  Widget build(BuildContext context) {
    if (headings.isEmpty) return const SizedBox.shrink();

    final theme = AppThemeExtension.of(context);

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: SpacingTokens.space3),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: headings.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.space2),
        itemBuilder: (context, index) {
          final heading = headings[index];
          return _HeadingChip(
            heading: heading,
            theme: theme,
            onTap: () => onSelectHeading(heading.blockIndex),
          );
        },
      ),
    );
  }
}

final class _HeadingChip extends StatelessWidget {
  final DocumentHeading heading;
  final AppThemeExtension theme;
  final VoidCallback onTap;

  const _HeadingChip({
    required this.heading,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.space3,
          vertical: SpacingTokens.space1,
        ),
        decoration: BoxDecoration(
          color: theme.colors.surfaces.subtle,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
          border: Border.all(
            color: theme.colors.borders.subtle,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: AppText(
          heading.text,
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
      ),
    );
  }
}
