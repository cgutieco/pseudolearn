import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class TrackingStrip extends StatelessWidget {
  final List<String> changedNames;
  final List<String> changedValues;

  const TrackingStrip({
    super.key,
    required this.changedNames,
    required this.changedValues,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Container(
      height: SpacingTokens.space8,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(
          top: BorderSide(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: changedNames.isEmpty
          ? _StripMessage(text: l10n.trackingStripEmpty)
          : _StripEntries(label: l10n.trackingStripLabel, names: changedNames, values: changedValues),
    );
  }
}

final class _StripMessage extends StatelessWidget {
  final String text;

  const _StripMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText(text, variant: AppTextVariant.caption, color: theme.colors.text.tertiary, maxLines: 1),
    );
  }
}

final class _StripEntries extends StatelessWidget {
  final String label;
  final List<String> names;
  final List<String> values;

  const _StripEntries({required this.label, required this.names, required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Row(
      children: [
        AppText(label, variant: AppTextVariant.caption, color: theme.colors.text.tertiary),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: names.length,
            separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.space3),
            itemBuilder: (_, index) => _StripEntry(name: names[index], value: values[index]),
          ),
        ),
      ],
    );
  }
}

final class _StripEntry extends StatelessWidget {
  final String name;
  final String value;

  const _StripEntry({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Center(
      child: AppText(
        '$name = $value',
        variant: AppTextVariant.codeCaption,
        color: theme.colors.text.link,
        maxLines: 1,
      ),
    );
  }
}
