import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/account/account_cubit.dart';
import '../../../application/account/account_state.dart';
import '../../../application/account/local_account_data_purge.dart';
import '../../../application/dashboard/dashboard_cubit.dart';
import '../../../application/route/route_bank_cubit.dart';
import '../../../application/route/route_index_cubit.dart';
import '../../reference/reference_edition_resolver.dart';
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
  final edition = currentReferenceEdition(context);
  context.read<RouteIndexCubit>().load(edition);
  context.read<RouteBankCubit>().load(edition);
  context.read<SyncCubit>().notifyLocalChange();
}
