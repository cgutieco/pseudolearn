import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/settings/settings_state.dart';
import 'editor_settings_view.dart';

final class EditorSettingsPage extends StatelessWidget {
  const EditorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return EditorSettingsView(
          isAssisted: state.editorAssistance,
          onAssistSelected: (isAssisted) {
            context.read<SettingsCubit>().setEditorAssistance(isAssisted);
          },
          onBack: () => context.pop(),
        );
      },
    );
  }
}
