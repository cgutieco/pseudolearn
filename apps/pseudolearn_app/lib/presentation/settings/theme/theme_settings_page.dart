import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/settings/settings_state.dart';
import 'theme_settings_view.dart';

final class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return ThemeSettingsView(
          selectedThemeMode: state.themeMode,
          onThemeSelected: (newThemeMode) {
            context.read<SettingsCubit>().setThemeMode(newThemeMode);
          },
          onBack: () => context.pop(),
        );
      },
    );
  }
}
