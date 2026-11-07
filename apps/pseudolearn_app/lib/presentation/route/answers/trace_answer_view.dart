import 'package:flutter/material.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../../domain/model/route/route_evaluation.dart';
import '../../../domain/model/route/route_verdict.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'text_answer_view.dart';

final class TraceAnswerView extends StatefulWidget {
  final TraceEvaluation evaluation;
  final RouteVerdict? verdict;
  final ValueChanged<RouteAnswer> onSubmit;

  const TraceAnswerView({
    super.key,
    required this.evaluation,
    required this.verdict,
    required this.onSubmit,
  });

  @override
  State<TraceAnswerView> createState() => _TraceAnswerViewState();
}

final class _TraceAnswerViewState extends State<TraceAnswerView> {
  final Map<(int, int), TextEditingController> _controllers = {};

  TextEditingController _controllerAt(int row, int column) =>
      _controllers.putIfAbsent((row, column), TextEditingController.new);

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() => widget.onSubmit(
    CellsRouteAnswer({
      for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
    }),
  );

  @override
  Widget build(BuildContext context) {
    final feedback = widget.verdict?.feedback;
    final wrong = feedback is WrongCellsFeedback ? feedback.cells : const <(int, int)>{};
    final rows = widget.evaluation.rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TraceRowView(label: '', cells: [for (final column in widget.evaluation.columns) TraceCellView.fixed(column)]),
        for (var row = 0; row < rows.length; row++)
          TraceRowView(
            label: rows[row].label,
            cells: [
              for (var column = 0; column < rows[row].cells.length; column++)
                rows[row].cells[column].editable
                    ? TraceCellView.editable(_controllerAt(row, column), wrong: wrong.contains((row, column)))
                    : TraceCellView.fixed(rows[row].cells[column].value),
            ],
          ),
        const SizedBox(height: SpacingTokens.space2),
        CheckButton(onPressed: _submit),
      ],
    );
  }
}

final class TraceRowView extends StatelessWidget {
  final String label;
  final List<TraceCellView> cells;

  const TraceRowView({super.key, required this.label, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: SpacingTokens.space16, child: AppText(label, variant: AppTextVariant.label)),
        for (final cell in cells) Expanded(child: cell),
      ],
    );
  }
}

final class TraceCellView extends StatelessWidget {
  final String? value;
  final TextEditingController? controller;
  final bool wrong;

  const TraceCellView.fixed(this.value, {super.key})
    : controller = null,
      wrong = false;

  const TraceCellView.editable(this.controller, {super.key, required this.wrong})
    : value = null;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final controller = this.controller;
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.space1),
      child: controller == null
          ? AppText(value ?? '', variant: AppTextVariant.codeInline)
          : TextField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: wrong
                    ? OutlineInputBorder(borderSide: BorderSide(color: theme.colors.severities.error.fg))
                    : null,
              ),
            ),
    );
  }
}
