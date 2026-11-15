import 'package:material_ui/material_ui.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'lesson_callouts.dart';

final class AttemptView extends StatefulWidget {
  final AttemptLessonBlock attempt;
  final LessonScope scope;

  const AttemptView({super.key, required this.attempt, required this.scope});

  @override
  State<AttemptView> createState() => _AttemptViewState();
}

final class _AttemptViewState extends State<AttemptView> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return AccentPanel(
      accent: theme.colors.severities.warning.fg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonBlockColumn(blocks: widget.attempt.prompt, scope: widget.scope),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: _revealed ? l10n.routeAttemptHide : l10n.routeAttemptReveal,
              variant: AppButtonVariant.secondary,
              onPressed: () => setState(() => _revealed = !_revealed),
            ),
          ),
          if (_revealed) const SizedBox(height: SpacingTokens.space3),
          if (_revealed)
            LessonBlockColumn(blocks: widget.attempt.answer, scope: widget.scope),
        ],
      ),
    );
  }
}
