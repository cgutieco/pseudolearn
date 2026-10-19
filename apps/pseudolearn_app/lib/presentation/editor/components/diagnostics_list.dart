import 'package:flutter/material.dart';
import '../../../domain/model/analysis/app_diagnostic.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'severity_chip.dart';
import '../../theme/tokens/component_metrics.dart';

final class DiagnosticsList extends StatelessWidget {
  final List<AppDiagnostic> diagnostics;
  final ValueChanged<AppDiagnostic>? onDiagnosticTap;

  const DiagnosticsList({
    super.key,
    required this.diagnostics,
    this.onDiagnosticTap,
  });

  @override
  Widget build(BuildContext context) {
    if (diagnostics.isEmpty) {
      return const _EmptyDiagnostics();
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: ComponentMetricsTokens.diagnosticsListHeight,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.space3,
          vertical: SpacingTokens.space2,
        ),
        itemCount: diagnostics.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: SpacingTokens.space2),
        itemBuilder: (context, index) => _DiagnosticItemRow(
          diagnostic: diagnostics[index],
          onTap: () {
            if (onDiagnosticTap != null) onDiagnosticTap!(diagnostics[index]);
          },
        ),
      ),
    );
  }
}

final class _EmptyDiagnostics extends StatelessWidget {
  const _EmptyDiagnostics();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: ComponentMetricsTokens.diagnosticsEmptyHeight,
      ),
      child: Center(
        child: AppText(
          l10n.diagnosticsEmpty,
          variant: AppTextVariant.caption,
          color: theme.colors.severities.success.fg,
        ),
      ),
    );
  }
}

final class _DiagnosticItemRow extends StatelessWidget {
  final AppDiagnostic diagnostic;
  final VoidCallback onTap;

  const _DiagnosticItemRow({required this.diagnostic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DiagnosticMainRow(diagnostic: diagnostic),
            if (diagnostic.relatedRanges.isNotEmpty)
              _RelatedRangesList(ranges: diagnostic.relatedRanges),
          ],
        ),
      ),
    );
  }
}

final class _DiagnosticMainRow extends StatelessWidget {
  final AppDiagnostic diagnostic;

  const _DiagnosticMainRow({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final line = diagnostic.primaryRange.startLine;
    final col = diagnostic.primaryRange.startColumn;

    return Row(
      children: [
        SeverityChip(severity: diagnostic.severity),
        const SizedBox(width: SpacingTokens.space2),
        AppText(
          'L:$line C:$col',
          variant: AppTextVariant.codeCaption,
          color: theme.colors.text.tertiary,
        ),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: AppText(
            diagnostic.message,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.primary,
          ),
        ),
      ],
    );
  }
}

final class _RelatedRangesList extends StatelessWidget {
  final List<RelatedRange> ranges;

  const _RelatedRangesList({required this.ranges});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.space8,
        top: SpacingTokens.spaceHalf,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ranges
            .map(
              (r) => AppText(
                '• ${r.label}',
                variant: AppTextVariant.caption,
                color: theme.colors.text.tertiary,
              ),
            )
            .toList(),
      ),
    );
  }
}
