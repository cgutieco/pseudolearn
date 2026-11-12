import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/account/account_cubit.dart';
import '../../application/account/account_state.dart';
import '../../application/credits/credits_cubit.dart';

bool _becameSignedIn(AccountState previous, AccountState current) =>
    current is AccountAuthenticated && previous != current;

final class AgentCreditsRefresher extends StatefulWidget {
  final Widget child;

  const AgentCreditsRefresher({super.key, required this.child});

  @override
  State<AgentCreditsRefresher> createState() => _AgentCreditsRefresherState();
}

final class _AgentCreditsRefresherState extends State<AgentCreditsRefresher> {
  @override
  void initState() {
    super.initState();
    if (context.read<AccountCubit>().state is AccountAuthenticated) context.read<CreditsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: _becameSignedIn,
      listener: (context, _) => context.read<CreditsCubit>().refresh(),
      child: widget.child,
    );
  }
}
