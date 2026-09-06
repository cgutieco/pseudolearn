import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/account/account_cubit.dart';
import '../../../application/account/account_state.dart';
import '../../../domain/model/account/auth_method.dart';
import 'account_view.dart';

final class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        return AccountView(
          accountState: state,
          onSignInApple: () {
            context.read<AccountCubit>().signIn(AuthMethod.apple);
          },
          onSignInGoogle: () {
            context.read<AccountCubit>().signIn(AuthMethod.google);
          },
          onSignInMagicLink: (email) {
            context.read<AccountCubit>().signIn(AuthMethod.magicLink, email: email);
          },
          onSignOut: () {
            context.read<AccountCubit>().signOut();
          },
          onSignOutAndDeleteLocalData: () {
            context.read<AccountCubit>().signOut(deleteLocalData: true);
          },
          onDeleteAccount: () {
            context.read<AccountCubit>().deleteAccount();
          },
          onBack: () => context.pop(),
        );
      },
    );
  }
}
