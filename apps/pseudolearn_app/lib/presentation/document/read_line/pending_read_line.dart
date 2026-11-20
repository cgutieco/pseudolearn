import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../application/execution/execution_cubit.dart';
import '../../../domain/model/execution/execution_step.dart';
import 'read_line.dart';

final class PendingReadLine extends StatelessWidget {
  final ExecutionStep step;

  const PendingReadLine({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final wait = step.inputWait;
    return ReadLine(
      request: step.readRequest,
      onSubmit: (text) {
        if (wait == null) return;
        context.read<ExecutionCubit>().provideInput(wait, text);
      },
    );
  }
}
