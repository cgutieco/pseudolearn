import 'package:flutter/material.dart';
import '../../../application/execution/execution_state.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'simulated_scenario_help_button.dart';
import 'simulated_scenario_selector.dart';

final class SimulatedScenarioPanelContent extends StatelessWidget {
  final ExecutionState state;

  const SimulatedScenarioPanelContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final compact =
        DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
      decoration: BoxDecoration(
        color: colors.surfaces.raised,
        border: Border(top: BorderSide(color: colors.borders.subtle)),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: colors.text.secondary, size: 18),
          const SizedBox(width: SpacingTokens.space2),
          AppText(
            AppLocalizations.of(context)!.simulatedScenarioBadge,
            variant: AppTextVariant.caption,
            color: colors.text.secondary,
          ),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: SimulatedScenarioSelector(state: state)),
          SimulatedScenarioHelpButton(compact: compact),
        ],
      ),
    );
  }
}
