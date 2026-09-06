import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/settings/settings_state.dart';
import 'language_settings_view.dart';

final class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return LanguageSettingsView(
          selectedLanguage: state.language,
          onLanguageSelected: (newLanguage) {
            context.read<SettingsCubit>().setLanguage(newLanguage);
          },
          onBack: () => context.pop(),
        );
      },
    );
  }
}
