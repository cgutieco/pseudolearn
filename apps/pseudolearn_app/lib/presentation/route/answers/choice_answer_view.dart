import 'package:flutter/material.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../../domain/model/route/route_evaluation.dart';
import '../../../domain/model/route/route_verdict.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'text_answer_view.dart';

final class ChoiceAnswerView extends StatefulWidget {
  final ChoiceEvaluation evaluation;
  final LessonScope scope;
  final ValueChanged<RouteAnswer> onSubmit;

  const ChoiceAnswerView({
    super.key,
    required this.evaluation,
    required this.scope,
    required this.onSubmit,
  });

  @override
  State<ChoiceAnswerView> createState() => _ChoiceAnswerViewState();
}

final class _ChoiceAnswerViewState extends State<ChoiceAnswerView> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final options = widget.evaluation.options;
    final selected = _selected;
    return RadioGroup<int>(
      groupValue: selected,
      onChanged: (value) => setState(() => _selected = value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < options.length; index++)
            RadioListTile<int>(
              value: index,
              title: LessonRunsText(runs: options[index].runs, scope: widget.scope),
            ),
          if (selected != null)
            CheckButton(onPressed: () => widget.onSubmit(ChoiceRouteAnswer(selected))),
        ],
      ),
    );
  }
}

final class ClassifyAnswerView extends StatefulWidget {
  final ClassifyEvaluation evaluation;
  final RouteVerdict? verdict;
  final LessonScope scope;
  final ValueChanged<RouteAnswer> onSubmit;

  const ClassifyAnswerView({
    super.key,
    required this.evaluation,
    required this.verdict,
    required this.scope,
    required this.onSubmit,
  });

  @override
  State<ClassifyAnswerView> createState() => _ClassifyAnswerViewState();
}

final class _ClassifyAnswerViewState extends State<ClassifyAnswerView> {
  final Map<int, int> _assigned = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final feedback = widget.verdict?.feedback;
    final wrong = feedback is MisplacedFeedback ? feedback.elements : const <int>{};
    final elements = widget.evaluation.elements;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < elements.length; index++)
          ClassifyRow(
            element: elements[index],
            categories: widget.evaluation.categories,
            assigned: _assigned[index],
            color: wrong.contains(index) ? theme.colors.severities.error.fg : null,
            scope: widget.scope,
            hint: l10n.routeClassifyChoose,
            onChanged: (value) => setState(() => value == null ? _assigned.remove(index) : _assigned[index] = value),
          ),
        CheckButton(onPressed: () => widget.onSubmit(AssignmentRouteAnswer(Map.of(_assigned)))),
      ],
    );
  }
}

final class ClassifyRow extends StatelessWidget {
  final ClassifiedEntry element;
  final List<String> categories;
  final int? assigned;
  final Color? color;
  final LessonScope scope;
  final String hint;
  final ValueChanged<int?> onChanged;

  const ClassifyRow({
    super.key,
    required this.element,
    required this.categories,
    required this.assigned,
    required this.color,
    required this.scope,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Row(
        children: [
          Expanded(child: LessonRunsText(runs: element.runs, scope: scope, color: color)),
          DropdownButton<int>(
            value: assigned,
            hint: Text(hint),
            items: [
              for (var category = 0; category < categories.length; category++)
                DropdownMenuItem(value: category, child: Text(categories[category])),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
