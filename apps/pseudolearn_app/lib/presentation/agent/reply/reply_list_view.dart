import 'package:material_ui/material_ui.dart';
import '../../../domain/model/agent/code_block.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import 'reply_blocks_view.dart';
import 'reply_metrics.dart';

const List<String> _bulletsByDepth = ['•', '◦', '▪'];

final class ReplyListView extends StatelessWidget {
  final ReplyList list;
  final List<CheckedCodeBlock> codeBlocks;
  final int depth;

  const ReplyListView({super.key, required this.list, required this.codeBlocks, required this.depth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in list.items.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : ReplyMetrics.blockGap / 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Marker(task: item.task, label: _markerLabel(index)),
                Expanded(child: ReplyBlocksView(blocks: item.blocks, codeBlocks: codeBlocks, depth: depth + 1)),
              ],
            ),
          ),
      ],
    );
  }

  String _markerLabel(int index) =>
      list.ordered ? '${list.start + index}.' : _bulletsByDepth[depth % _bulletsByDepth.length];
}

final class _Marker extends StatelessWidget {
  final ReplyTask task;
  final String label;

  const _Marker({required this.task, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: ReplyMetrics.listMarkerWidth,
      child: switch (task) {
        ReplyTask.none => AppText(label, variant: AppTextVariant.bodyDefault, color: theme.colors.text.secondary),
        ReplyTask.done => Icon(
          Icons.check_box_outlined,
          size: IconMetricsTokens.iconSm,
          color: theme.colors.severities.success.fg,
          semanticLabel: l10n.agentTaskDone,
        ),
        ReplyTask.open => Icon(
          Icons.check_box_outline_blank,
          size: IconMetricsTokens.iconSm,
          color: theme.colors.text.secondary,
          semanticLabel: l10n.agentTaskOpen,
        ),
      },
    );
  }
}
