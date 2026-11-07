import 'package:flutter/material.dart';
import '../../domain/model/reference/reference_block.dart';
import '../../domain/model/reference/reference_run.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';

final class ReferenceContents extends StatelessWidget {
  final List<ReferenceHeading> headings;
  final ValueChanged<String> onSelect;

  const ReferenceContents({
    super.key,
    required this.headings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            AppLocalizations.of(context)!.referenceContents,
            variant: AppTextVariant.label,
            color: theme.colors.text.secondary,
          ),
          for (final heading in headings)
            ReferenceContentsTile(heading: heading, onSelect: onSelect),
        ],
      ),
    );
  }
}

final class ReferenceContentsTile extends StatelessWidget {
  final ReferenceHeading heading;
  final ValueChanged<String> onSelect;

  const ReferenceContentsTile({
    super.key,
    required this.heading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: AppText(
        heading.number,
        variant: AppTextVariant.caption,
        color: theme.colors.text.tertiary,
      ),
      title: AppText(
        plainTextOf(heading.runs),
        variant: AppTextVariant.bodySmall,
      ),
      onTap: () => onSelect(heading.id),
    );
  }
}

final class ReferenceContentsButton extends StatelessWidget {
  final ReferenceContents contents;

  const ReferenceContentsButton({super.key, required this.contents});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      right: SpacingTokens.space4,
      bottom: SpacingTokens.space4,
      child: FloatingActionButton.small(
        tooltip: l10n.referenceOpenContents,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SingleChildScrollView(
            child: ReferenceContents(
              headings: contents.headings,
              onSelect: (heading) {
                Navigator.of(sheetContext).pop();
                contents.onSelect(heading);
              },
            ),
          ),
        ),
        child: const Icon(Icons.toc_rounded),
      ),
    );
  }
}
