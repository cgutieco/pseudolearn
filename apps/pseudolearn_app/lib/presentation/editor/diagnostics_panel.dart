import 'package:flutter/material.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'components/severity_chip.dart';
import '../theme/tokens/component_metrics.dart';

final class DiagnosticsPanel extends StatefulWidget {
  final List<AppDiagnostic> diagnostics;
  final ValueChanged<AppDiagnostic>? onDiagnosticTap;
  final bool isCollapsed;
  final Widget? trailing;

  const DiagnosticsPanel({
    super.key,
    required this.diagnostics,
    this.onDiagnosticTap,
    this.isCollapsed = false,
    this.trailing,
  });

  @override
  State<DiagnosticsPanel> createState() => _DiagnosticsPanelState();
}

final class _DiagnosticsPanelState extends State<DiagnosticsPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final isExpanded = _isExpanded && !widget.isCollapsed;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(top: BorderSide(color: theme.colors.borders.subtle, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DiagnosticsHeader(
            count: widget.diagnostics.length,
            isExpanded: isExpanded,
            offersToggle: !widget.isCollapsed,
            onToggle: () => setState(() => _isExpanded = !_isExpanded),
            trailing: widget.trailing,
          ),
          if (isExpanded)
            _DiagnosticsList(
              diagnostics: widget.diagnostics,
              onDiagnosticTap: widget.onDiagnosticTap,
            ),
        ],
      ),
    );
  }
}

final class _DiagnosticsHeader extends StatelessWidget {
  final int count;
  final bool isExpanded;
  final bool offersToggle;
  final VoidCallback onToggle;
  final Widget? trailing;

  const _DiagnosticsHeader({
    required this.count,
    required this.isExpanded,
    required this.offersToggle,
    required this.onToggle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final countColor = count > 0 ? theme.colors.severities.error.fg : theme.colors.text.secondary;
    final height = trailing != null ? 40.0 : 36.0;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      color: theme.colors.surfaces.subtle,
      child: Row(
        children: [
          Expanded(child: _DiagnosticsCountLabel(text: l10n.diagnosticsCount(count), color: countColor)),
          if (offersToggle)
            AppIconButton(
              icon: isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              semanticLabel: isExpanded ? l10n.actionCollapse : l10n.actionExpand,
              variant: AppButtonVariant.tertiary,
              onPressed: onToggle,
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

final class _DiagnosticsCountLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _DiagnosticsCountLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppText(text, variant: AppTextVariant.label, color: color, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

final class _DiagnosticsList extends StatelessWidget {
  final List<AppDiagnostic> diagnostics;
  final ValueChanged<AppDiagnostic>? onDiagnosticTap;

  const _DiagnosticsList({required this.diagnostics, this.onDiagnosticTap});

  @override
  Widget build(BuildContext context) {
    if (diagnostics.isEmpty) {
      return const _EmptyDiagnostics();
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: ComponentMetricsTokens.diagnosticsListHeight),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3, vertical: SpacingTokens.space2),
        itemCount: diagnostics.length,
        separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.space2),
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
      constraints: const BoxConstraints(maxHeight: ComponentMetricsTokens.diagnosticsEmptyHeight),
      child: Center(
        child: AppText(l10n.diagnosticsEmpty, variant: AppTextVariant.caption, color: theme.colors.severities.success.fg),
      ),
    );
  }
}

final class _DiagnosticItemRow extends StatelessWidget {
  final AppDiagnostic diagnostic;
  final VoidCallback onTap;

  const _DiagnosticItemRow({
    required this.diagnostic,
    required this.onTap,
  });

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
        AppText('L:$line C:$col', variant: AppTextVariant.codeCaption, color: theme.colors.text.tertiary),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: AppText(diagnostic.message, variant: AppTextVariant.bodySmall, color: theme.colors.text.primary),
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
      padding: const EdgeInsets.only(left: SpacingTokens.space8, top: SpacingTokens.spaceHalf),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ranges
            .map((r) => AppText('• ${r.label}', variant: AppTextVariant.caption, color: theme.colors.text.tertiary))
            .toList(),
      ),
    );
  }
}
