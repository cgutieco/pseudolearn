import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';

final class ReferenceListView extends StatelessWidget {
  final ReferenceList list;
  final ValueChanged<String> onOpenSection;

  const ReferenceListView({
    super.key,
    required this.list,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, entry) in list.entries.indexed)
          ReferenceListEntry(
            marker: list.ordered ? '${index + 1}.' : '•',
            child: ReferenceRunsText(runs: entry, onOpenSection: onOpenSection),
          ),
      ],
    );
  }
}

final class ReferenceListEntry extends StatelessWidget {
  final String marker;
  final Widget child;

  const ReferenceListEntry({
    super.key,
    required this.marker,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SpacingTokens.space6,
            child: AppText(
              marker,
              variant: AppTextVariant.bodyDefault,
              color: theme.colors.text.tertiary,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
