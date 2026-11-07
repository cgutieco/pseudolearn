import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/exercise_case.dart';
import '../../../domain/model/knowledge/expected_value_kind.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../../domain/model/route/route_evaluation.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';
import 'text_answer_view.dart';

final class DesignAnswerView extends StatefulWidget {
  final DesignTestsEvaluation evaluation;
  final ValueChanged<RouteAnswer> onSubmit;

  const DesignAnswerView({super.key, required this.evaluation, required this.onSubmit});

  @override
  State<DesignAnswerView> createState() => _DesignAnswerViewState();
}

final class _DesignAnswerViewState extends State<DesignAnswerView> {
  final List<(TextEditingController, TextEditingController)> _rows = [
    (TextEditingController(), TextEditingController()),
  ];

  @override
  void dispose() {
    for (final (inputs, expected) in _rows) {
      inputs.dispose();
      expected.dispose();
    }
    super.dispose();
  }

  void _add() => setState(() => _rows.add((TextEditingController(), TextEditingController())));

  void _remove(int index) => setState(() => _rows.removeAt(index));

  void _submit() => widget.onSubmit(
    CasesRouteAnswer([for (final (inputs, expected) in _rows) _caseOf(inputs.text, expected.text)]),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _rows.length; index++)
          DesignCaseRow(inputs: _rows[index].$1, expected: _rows[index].$2, onRemove: () => _remove(index)),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(label: l10n.routeDesignAddCase, variant: AppButtonVariant.secondary, icon: Icons.add_rounded, onPressed: _add),
        ),
        const SizedBox(height: SpacingTokens.space2),
        CheckButton(onPressed: _submit),
      ],
    );
  }
}

ExerciseCase _caseOf(String inputs, String expected) => ExerciseCase(
  inputs: [
    for (final value in inputs.split(';'))
      if (value.trim().isNotEmpty) value.trim(),
  ],
  expectedOutputs: expected.trim().isEmpty ? const [] : expected.trim().split('\n'),
  expectedValueKind: ExpectedValueKind.numeric,
);

final class DesignCaseRow extends StatelessWidget {
  final TextEditingController inputs;
  final TextEditingController expected;
  final VoidCallback onRemove;

  const DesignCaseRow({
    super.key,
    required this.inputs,
    required this.expected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: TextField(controller: inputs, decoration: InputDecoration(labelText: l10n.routeDesignInputs))),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: TextField(controller: expected, maxLines: 4, minLines: 1, decoration: InputDecoration(labelText: l10n.routeDesignExpected))),
          AppIconButton(icon: Icons.close_rounded, semanticLabel: l10n.routeDesignRemove, variant: AppButtonVariant.tertiary, onPressed: onRemove),
        ],
      ),
    );
  }
}
