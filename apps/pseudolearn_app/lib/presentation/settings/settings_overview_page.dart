import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/onboarding/onboarding_cubit.dart';
import '../../application/settings/settings_cubit.dart';
import '../../application/settings/settings_state.dart';
import 'settings_overview_view.dart';

final class SettingsOverviewPage extends StatelessWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsOverviewView(
          currentLanguage: state.language,
          currentThemeMode: state.themeMode,
          assistedDiagramZoom: state.assistedDiagramZoom,
          onNavigateAccount: () => context.push('/ajustes/cuenta'),
          onNavigateLanguage: () => context.push('/ajustes/idioma'),
          onNavigateTheme: () => context.push('/ajustes/tema'),
          onNavigateDiagram: () => context.push('/ajustes/diagramas'),
          onNavigateContact: () => context.push('/ajustes/contacto'),
          onRestartOnboarding: () {
            context.read<OnboardingCubit>().restart();
            context.go('/onboarding');
          },
        );
      },
    );
  }
}
