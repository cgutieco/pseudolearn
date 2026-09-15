import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/account/account_cubit.dart';
import '../../../application/account/account_state.dart';
import '../../../application/account/local_account_data_purge.dart';
import '../../../application/dashboard/dashboard_cubit.dart';
import '../../../application/knowledge/bank/exercise_bank_cubit.dart';
import '../../../application/knowledge/route/learning_route_cubit.dart';
import '../../../application/library/library_cubit.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/sync/sync_cubit.dart';
import '../../../domain/model/settings/effective_ui_language.dart';

final class LocalAccountDataRefresher extends StatelessWidget {
  final Widget child;

  const LocalAccountDataRefresher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: isLocalAccountDataPurge,
      listener: (context, _) => _reloadLocalDataViews(context),
      child: child,
    );
  }
}

void _reloadLocalDataViews(BuildContext context) {
  final language = resolveEffectiveLanguage(
    setting: context.read<SettingsCubit>().state.language,
    systemLanguageCode:
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  context.read<LibraryCubit>().loadDocuments();
  context.read<DashboardCubit>().load(language);
  context.read<LearningRouteCubit>().loadRoute(language);
  context.read<ExerciseBankCubit>().loadExercises(language);
  context.read<SyncCubit>().notifyLocalChange();
}
