import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../../domain/model/route/route_evaluation.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/button/button_palette.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'text_answer_view.dart';

final class OrderAnswerView extends StatefulWidget {
  final List<List<ReferenceRun>> steps;
  final List<String> lines;
  final String head;
  final String tail;
  final LessonScope scope;
  final ValueChanged<RouteAnswer> onSubmit;

  OrderAnswerView.steps({
    super.key,
    required OrderStepsEvaluation evaluation,
    required this.scope,
    required this.onSubmit,
  }) : steps = evaluation.steps,
       lines = const [],
       head = '',
       tail = '';

  OrderAnswerView.program({
    super.key,
    required OrderProgramEvaluation evaluation,
    required this.scope,
    required this.onSubmit,
  }) : steps = const [],
       lines = evaluation.blocks,
       head = evaluation.head,
       tail = evaluation.tail;

  int get count => steps.isEmpty ? lines.length : steps.length;

  @override
  State<OrderAnswerView> createState() => _OrderAnswerViewState();
}

final class _OrderAnswerViewState extends State<OrderAnswerView> {
  late final List<int> _order = [for (var index = 0; index < widget.count; index++) index];

  void _move(int position, int delta) {
    final target = position + delta;
    if (target < 0 || target >= _order.length) return;
    setState(() {
      final moved = _order.removeAt(position);
      _order.insert(target, moved);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.head.isNotEmpty) AppText(widget.head, variant: AppTextVariant.codeInline),
        for (var position = 0; position < _order.length; position++)
          OrderTile(
            onUp: () => _move(position, -1),
            onDown: () => _move(position, 1),
            child: widget.steps.isEmpty
                ? AppText(widget.lines[_order[position]], variant: AppTextVariant.codeInline)
                : LessonRunsText(runs: widget.steps[_order[position]], scope: widget.scope),
          ),
        if (widget.tail.isNotEmpty) AppText(widget.tail, variant: AppTextVariant.codeInline),
        const SizedBox(height: SpacingTokens.space2),
        CheckButton(onPressed: () => widget.onSubmit(OrderRouteAnswer(List.of(_order)))),
      ],
    );
  }
}

final class OrderTile extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final Widget child;

  const OrderTile({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space1),
      child: AppCardSurface(
        padding: const EdgeInsets.all(SpacingTokens.space2),
        child: Row(
          children: [
            Expanded(child: child),
            AppIconButton(icon: Icons.arrow_upward_rounded, semanticLabel: l10n.routeOrderUp, variant: AppButtonVariant.tertiary, onPressed: onUp),
            AppIconButton(icon: Icons.arrow_downward_rounded, semanticLabel: l10n.routeOrderDown, variant: AppButtonVariant.tertiary, onPressed: onDown),
          ],
        ),
      ),
    );
  }
}
