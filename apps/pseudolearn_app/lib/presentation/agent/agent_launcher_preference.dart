import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/agent/agent_launcher_cubit.dart';
import '../components/list/app_radio_list.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../settings/widgets/settings_group.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';

List<AppRadioOption<bool>> _launcherOptions(AppLocalizations l10n) => [
  AppRadioOption(value: true, label: l10n.agentPlanLauncherShow, icon: Icons.visibility_outlined),
  AppRadioOption(value: false, label: l10n.agentPlanLauncherHide, icon: Icons.visibility_off_outlined),
];

final class AgentLauncherPreference extends StatelessWidget {
  const AgentLauncherPreference({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      key: const ValueKey('agent-launcher-preference'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: l10n.agentPlanLauncherTitle,
          items: [
            BlocBuilder<AgentLauncherCubit, bool>(
              builder: (context, shown) => AppRadioList<bool>(
                options: _launcherOptions(l10n),
                selectedValue: shown,
                onSelected: context.read<AgentLauncherCubit>().setShown,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.space2),
        AppText(l10n.agentPlanLauncherNote, variant: AppTextVariant.caption, color: theme.colors.text.secondary),
      ],
    );
  }
}
