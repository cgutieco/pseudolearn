import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../domain/model/execution/simulated_scenario.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';

final class SimulatedScenarioSelector extends StatelessWidget {
  final ExecutionState state;

  const SimulatedScenarioSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<SimulatedScenario>(
      value: state.simulatedScenario,
      isExpanded: true,
      isDense: true,
      onChanged: state.isInFlight
          ? null
          : (scenario) => _select(context, scenario),
      items: [
        for (final scenario in SimulatedScenario.values)
          DropdownMenuItem(
            value: scenario,
            child: AppText(
              _scenarioLabel(scenario, AppLocalizations.of(context)!),
              variant: AppTextVariant.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    ),
  );

  void _select(BuildContext context, SimulatedScenario? scenario) {
    if (scenario == null) return;
    context.read<ExecutionCubit>().applyViewAction(
      ExecutionViewAction.selectScenario,
      scenario: scenario,
    );
  }
}

String _scenarioLabel(SimulatedScenario scenario, AppLocalizations l10n) =>
    switch (scenario) {
      SimulatedScenario.noHost => l10n.simulatedScenarioNoHost,
      SimulatedScenario.noPermissions => l10n.simulatedScenarioNoPermissions,
      SimulatedScenario.virtualFiles => l10n.simulatedScenarioVirtualFiles,
      SimulatedScenario.preparedHttp => l10n.simulatedScenarioPreparedHttp,
      SimulatedScenario.logicalTime => l10n.simulatedScenarioLogicalTime,
      SimulatedScenario.timeout => l10n.simulatedScenarioTimeout,
      SimulatedScenario.uncertainResult => l10n.simulatedScenarioUncertain,
    };
