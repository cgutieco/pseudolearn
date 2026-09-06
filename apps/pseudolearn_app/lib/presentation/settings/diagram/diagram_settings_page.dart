import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/settings/settings_state.dart';
import 'diagram_settings_view.dart';

final class DiagramSettingsPage extends StatelessWidget {
  const DiagramSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return DiagramSettingsView(
          isAssisted: state.assistedDiagramZoom,
          onAssistSelected: (isAssisted) {
            context.read<SettingsCubit>().setAssistedDiagramZoom(isAssisted);
          },
          onBack: () => context.pop(),
        );
      },
    );
  }
}
