import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/account/account_cubit.dart';
import '../../application/account/account_state.dart';
import '../../application/agent/agent_access.dart';
import '../../application/credits/agent_consent_cubit.dart';
import '../../application/credits/credits_cubit.dart';
import '../../application/credits/credits_state.dart';
import '../components/layout/app_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'agent_introduction_view.dart';
import 'agent_plan_center.dart';

final class AgentSettingsPage extends StatefulWidget {
  const AgentSettingsPage({super.key});

  @override
  State<AgentSettingsPage> createState() => _AgentSettingsPageState();
}

final class _AgentSettingsPageState extends State<AgentSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CreditsCubit>().refresh();
    context.read<AgentConsentCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.agentCreditsTitle,
        measure: ContentMeasure.form,
        onBack: () => context.pop(),
        backSemanticLabel: l10n.settingsBack,
        body: const _SettingsSwitch(),
      ),
    );
  }
}

final class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, account) => BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, credits) => switch (agentSettingsViewOf(signedIn: account is AccountAuthenticated, credits: credits)) {
          AgentSettingsView.introduction => AgentIntroductionView(signedIn: account is AccountAuthenticated),
          AgentSettingsView.loading => const Center(key: ValueKey('agent-settings-loading'), child: CircularProgressIndicator()),
          AgentSettingsView.planCenter => const AgentPlanCenter(),
        },
      ),
    );
  }
}
