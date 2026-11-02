import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import 'simulated_scenario_panel_content.dart';

final class SimulatedScenarioPanel extends StatelessWidget {
  const SimulatedScenarioPanel({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExecutionCubit, ExecutionState>(
        builder: (context, state) =>
            SimulatedScenarioPanelContent(state: state),
      );
}
