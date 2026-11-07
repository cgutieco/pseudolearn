import 'package:flutter/material.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';
import 'text_answer_view.dart';

final class InputsAnswerView extends StatefulWidget {
  final int reads;
  final ValueChanged<RouteAnswer> onSubmit;

  const InputsAnswerView({super.key, required this.reads, required this.onSubmit});

  @override
  State<InputsAnswerView> createState() => _InputsAnswerViewState();
}

final class _InputsAnswerViewState extends State<InputsAnswerView> {
  late final List<TextEditingController> _controllers = [
    for (var index = 0; index < widget.reads; index++) TextEditingController(),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _controllers.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(labelText: l10n.routeAnswerInput(index + 1)),
            ),
          ),
        CheckButton(
          onPressed: () => widget.onSubmit(
            InputsRouteAnswer([for (final controller in _controllers) controller.text.trim()]),
          ),
        ),
      ],
    );
  }
}
