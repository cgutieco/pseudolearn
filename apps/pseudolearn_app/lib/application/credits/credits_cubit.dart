import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/credits_outcome.dart';
import '../../domain/ports/credits_gateway.dart';
import 'credits_state.dart';

typedef SessionCredits = (CreditBalance?, int, CreditFailure?);

final class CreditsCubit extends Cubit<CreditsState> {
  final CreditsGateway _gateway;
  StreamSubscription<SessionCredits>? _session;
  SessionCredits? _lastSession;

  CreditsCubit({
    required CreditsGateway gateway,
    Stream<SessionCredits> sessionBalances = const Stream.empty(),
  }) : _gateway = gateway,
       super(const CreditsState()) {
    _session = sessionBalances.listen(_onSessionBalance);
  }

  Future<void> refresh() async {
    emit(CreditsState(
      status: CreditsStatus.loading,
      balance: state.balance,
      periodActive: state.periodActive,
      trialUsed: state.trialUsed,
      lastRequestSpent: state.lastRequestSpent,
    ));
    apply(await _gateway.balance());
  }

  void apply(CreditsOutcome outcome) {
    if (isClosed) return;
    emit(switch (outcome) {
      CreditsKnown(:final balance, :final periodActive, :final trialUsed) => CreditsState(
        status: CreditsStatus.known,
        balance: balance,
        periodActive: periodActive || balance.allowance > 0,
        trialUsed: trialUsed,
        lastRequestSpent: state.lastRequestSpent,
      ),
      CreditsUnavailable(:final failure) => CreditsState(
        status: CreditsStatus.unavailable,
        balance: state.balance,
        periodActive: state.periodActive,
        trialUsed: state.trialUsed,
        failure: failure,
        lastRequestSpent: state.lastRequestSpent,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _session?.cancel();
    return super.close();
  }

  void _onSessionBalance(SessionCredits update) {
    if (update == _lastSession) return;
    _lastSession = update;
    final (reported, spent, failure) = update;
    final balance = failure == CreditFailure.creditsExhausted
        ? CreditBalance(
            remaining: 0,
            allowance: reported?.allowance ?? state.balance?.allowance ?? 0,
            topUp: 0,
            renewsAt: reported?.renewsAt ?? state.balance?.renewsAt,
          )
        : reported;
    if (isClosed || balance == null) return;
    emit(CreditsState(
      status: CreditsStatus.known,
      balance: balance,
      periodActive: state.periodActive || balance.allowance > 0,
      trialUsed: state.trialUsed,
      lastRequestSpent: spent,
    ));
  }
}
