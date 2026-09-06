import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/dashboard/dashboard_cubit.dart';
import '../../application/dashboard/dashboard_state.dart';
import '../../application/settings/settings_cubit.dart';
import '../../application/settings/settings_state.dart';
import '../../application/sync/sync_cubit.dart';
import '../../application/sync/sync_state.dart';
import '../../domain/model/settings/effective_ui_language.dart';
import 'dashboard_view.dart';

final class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

final class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final settings = context.read<SettingsCubit>().state;
    final systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    context.read<DashboardCubit>().load(resolveEffectiveLanguage(
          setting: settings.language,
          systemLanguageCode: systemLocale,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => previous.language != current.language,
      listener: (context, state) => _load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => _DashboardWithSyncMoment(state: state),
      ),
    );
  }
}

final class _DashboardWithSyncMoment extends StatelessWidget {
  final DashboardState state;

  const _DashboardWithSyncMoment({required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, syncState) => DashboardView(
        state: state,
        lastSyncAt: syncState.lastSyncAt,
        onOpenModule: (moduleId) => context.push('/conocimiento/$moduleId'),
      ),
    );
  }
}
