import 'package:flutter/material.dart';
import '../../../../../domain/model/knowledge/content_block.dart';
import '../../../../components/typography/app_text.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens/component_metrics.dart';
import '../../../../theme/tokens/border_metrics.dart';
import '../../../../theme/tokens/spacing.dart';

final class HeadingBlockView extends StatelessWidget {
  final HeadingBlock block;

  const HeadingBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final variant = switch (block.level) {
      1 => AppTextVariant.heading1,
      2 => AppTextVariant.heading2,
      _ => AppTextVariant.heading3,
    };

    return Padding(
      padding: const EdgeInsets.only(
        top: SpacingTokens.space4,
        bottom: SpacingTokens.space2,
      ),
      child: AppText(
        block.text,
        variant: variant,
        color: theme.colors.text.primary,
      ),
    );
  }
}

final class ParagraphBlockView extends StatelessWidget {
  final ParagraphBlock block;

  const ParagraphBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space3),
      child: AppText(
        block.text,
        variant: AppTextVariant.bodyLarge,
        color: theme.colors.text.primary,
      ),
    );
  }
}

final class ListBlockView extends StatelessWidget {
  final ListBlock block;

  const ListBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.space4,
        bottom: SpacingTokens.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < block.items.length; i++)
            _ListItemView(
              index: i + 1,
              text: block.items[i],
              isOrdered: block.isOrdered,
            ),
        ],
      ),
    );
  }
}

final class _ListItemView extends StatelessWidget {
  final int index;
  final String text;
  final bool isOrdered;

  const _ListItemView({
    required this.index,
    required this.text,
    required this.isOrdered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final bullet = isOrdered ? '$index.' : '•';

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ComponentMetricsTokens.listBulletWidth,
            child: AppText(
              bullet,
              variant: AppTextVariant.bodyLarge,
              color: theme.colors.text.secondary,
            ),
          ),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodyLarge,
              color: theme.colors.text.primary,
            ),
          ),
        ],
      ),
    );
  }
}

final class QuoteBlockView extends StatelessWidget {
  final QuoteBlock block;

  const QuoteBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space3),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colors.borders.strong,
            width: BorderMetricsTokens.focusRingWidth,
          ),
        ),
      ),
      child: Text(
        block.text,
        style: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: theme.colors.text.secondary,
        ),
      ),
    );
  }
}
