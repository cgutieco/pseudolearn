import 'package:material_ui/material_ui.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';

final class TextAnswerView extends StatefulWidget {
  final ValueChanged<RouteAnswer> onSubmit;

  const TextAnswerView({super.key, required this.onSubmit});

  @override
  State<TextAnswerView> createState() => _TextAnswerViewState();
}

final class _TextAnswerViewState extends State<TextAnswerView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(hintText: l10n.routeAnswerPlaceholder),
        ),
        const SizedBox(height: SpacingTokens.space2),
        CheckButton(onPressed: () => widget.onSubmit(TextRouteAnswer(_controller.text))),
      ],
    );
  }
}

final class CheckButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CheckButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppButton(
        label: AppLocalizations.of(context)!.routeExerciseCheck,
        variant: AppButtonVariant.primary,
        icon: Icons.check_rounded,
        onPressed: onPressed,
      ),
    );
  }
}
