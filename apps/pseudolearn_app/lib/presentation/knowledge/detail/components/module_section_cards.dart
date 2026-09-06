import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../components/typography/app_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/border_metrics.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class SpecAnchorList extends StatelessWidget {
  final List<KnowledgeEntry> entries;
  final void Function(String entryId, {String? anchor}) onOpen;

  const SpecAnchorList({
    super.key,
    required this.entries,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      children: [
        for (final entry in entries)
          SpecAnchorCard(entry: entry, theme: theme, onOpen: onOpen),
      ],
    );
  }
}

final class SpecAnchorCard extends StatelessWidget {
  final KnowledgeEntry entry;
  final AppThemeExtension theme;
  final void Function(String entryId, {String? anchor}) onOpen;

  const SpecAnchorCard({
    super.key,
    required this.entry,
    required this.theme,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        side: BorderSide(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: ListTile(
        title: AppText(entry.title, variant: AppTextVariant.bodyDefault),
        subtitle: AppText(entry.summary, variant: AppTextVariant.caption),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => onOpen(entry.id, anchor: entry.anchor),
      ),
    );
  }
}

final class ExerciseList extends StatelessWidget {
  final List<KnowledgeEntry> entries;
  final ValueChanged<String>? onOpen;

  const ExerciseList({
    super.key,
    required this.entries,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      children: [
        for (final entry in entries)
          ExerciseCard(entry: entry, theme: theme, onOpen: onOpen),
      ],
    );
  }
}

final class ExerciseCard extends StatelessWidget {
  final KnowledgeEntry entry;
  final AppThemeExtension theme;
  final ValueChanged<String>? onOpen;

  const ExerciseCard({
    super.key,
    required this.entry,
    required this.theme,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        side: BorderSide(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.code_rounded),
        title: AppText(entry.title, variant: AppTextVariant.bodyDefault),
        subtitle: AppText(entry.summary, variant: AppTextVariant.caption),
        onTap: onOpen != null ? () => onOpen!(entry.id) : null,
      ),
    );
  }
}
