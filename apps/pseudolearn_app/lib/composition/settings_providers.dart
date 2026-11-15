import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/account/account_cubit.dart';
import '../application/settings/app_version_cubit.dart';
import '../application/settings/settings_cubit.dart';
import 'app_dependencies.dart';

List<BlocProvider> createSettingsProviders(
  AppDependencies dependencies,
  SettingsCubit settings,
) {
  return [
    BlocProvider<SettingsCubit>(create: (_) => settings),
    BlocProvider<AppVersionCubit>(
      create: (_) =>
          AppVersionCubit(source: dependencies.appVersionSource)..init(),
    ),
    BlocProvider<AccountCubit>(
      lazy: false,
      create: (_) => AccountCubit(
        authGateway: dependencies.authGateway,
        incomingLinks: dependencies.incomingLinkSource,
        accountDeletionGateway: dependencies.accountDeletionGateway,
        localAccountDataPurger: dependencies.localAccountDataPurger,
      )..init(),
    ),
  ];
}
