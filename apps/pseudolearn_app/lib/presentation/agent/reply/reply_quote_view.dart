import 'package:flutter/material.dart';
import '../../../domain/model/agent/code_block.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/color_semantic_severity.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'reply_blocks_view.dart';
import 'reply_metrics.dart';

final class ReplyQuoteView extends StatelessWidget {
  final ReplyQuote quote;
  final List<CheckedCodeBlock> codeBlocks;
  final int depth;

  const ReplyQuoteView({super.key, required this.quote, required this.codeBlocks, required this.depth});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final tone = _toneOf(quote.kind, theme.colors.severities);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3, vertical: SpacingTokens.space2),
      decoration: BoxDecoration(
        color: tone?.surface,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(RadiusTokens.radiusSm)),
        border: Border(
          left: BorderSide(color: tone?.border ?? theme.colors.borders.strong, width: ReplyMetrics.quoteRuleWidth),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tone != null) _AlertTitle(kind: quote.kind, color: tone.fg),
          ReplyBlocksView(blocks: quote.blocks, codeBlocks: codeBlocks, depth: depth),
        ],
      ),
    );
  }
}

SeverityItemColors? _toneOf(ReplyQuoteKind kind, SeverityColors severities) => switch (kind) {
  ReplyQuoteKind.plain => null,
  ReplyQuoteKind.note => severities.info,
  ReplyQuoteKind.tip => severities.success,
  ReplyQuoteKind.important => severities.hint,
  ReplyQuoteKind.warning => severities.warning,
  ReplyQuoteKind.caution => severities.error,
};

final class _AlertTitle extends StatelessWidget {
  final ReplyQuoteKind kind;
  final Color color;

  const _AlertTitle({required this.kind, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, label) = switch (kind) {
      ReplyQuoteKind.plain || ReplyQuoteKind.note => (Icons.info_outline, l10n.agentAlertNote),
      ReplyQuoteKind.tip => (Icons.lightbulb_outline, l10n.agentAlertTip),
      ReplyQuoteKind.important => (Icons.priority_high, l10n.agentAlertImportant),
      ReplyQuoteKind.warning => (Icons.warning_amber_outlined, l10n.agentAlertWarning),
      ReplyQuoteKind.caution => (Icons.report_outlined, l10n.agentAlertCaution),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space1),
      child: Row(
        children: [
          Icon(icon, size: IconMetricsTokens.iconXs, color: color),
          const SizedBox(width: SpacingTokens.space1),
          AppText(label, variant: AppTextVariant.label, color: color),
        ],
      ),
    );
  }
}
