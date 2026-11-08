import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_access.dart';
import 'package:pseudolearn_app/application/agent/agent_session_state.dart';
import 'package:pseudolearn_app/application/credits/agent_consent_cubit.dart';
import 'package:pseudolearn_app/application/credits/credits_cubit.dart';
import 'package:pseudolearn_app/application/credits/credits_state.dart';
import 'package:pseudolearn_app/application/credits/purchase_cubit.dart';
import 'package:pseudolearn_app/application/credits/purchase_state.dart';
import 'package:pseudolearn_app/data/credits/purchase_store_simulation.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/ports/purchase_store.dart';
import '../../fakes/fake_agent_ports.dart';
import '../../fakes/fake_identifier_generator.dart';

final class _CancellingStore implements PurchaseStore {
  @override
  Future<PurchaseReceipt?> purchase(AgentProduct product) async => null;
}

void main() {
  test('refresh reads the balance and failures keep the last known balance', () async {
    final gateway = FakeCreditsGateway();
    final cubit = CreditsCubit(gateway: gateway);
    await cubit.refresh();
    expect(cubit.state.status, CreditsStatus.known);
    expect(cubit.state.balance!.remaining, 40);
    gateway.next = const CreditsUnavailable(CreditFailure.offline);
    await cubit.refresh();
    expect(cubit.state.status, CreditsStatus.unavailable);
    expect(cubit.state.balance!.remaining, 40);
    await cubit.close();
  });

  test('session balances and an exhaustion failure update the credits', () async {
    final updates = StreamController<SessionCredits>();
    final cubit = CreditsCubit(gateway: FakeCreditsGateway(), sessionBalances: updates.stream);
    updates.add((const CreditBalance(remaining: 12, allowance: 300, topUp: 0), 3, null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.balance!.remaining, 12);
    expect(cubit.state.lastRequestSpent, 3);
    updates.add((const CreditBalance(remaining: 12, allowance: 300, topUp: 0), 3, CreditFailure.creditsExhausted));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isExhausted, isTrue);
    await updates.close();
    await cubit.close();
  });

  test('an inactive balance without top-ups needs the offer', () {
    const inactive = CreditsState(status: CreditsStatus.known, balance: CreditBalance(remaining: 0, allowance: 0, topUp: 0));
    expect(inactive.needsOffer, isTrue);
    const subscribed = CreditsState(status: CreditsStatus.known, periodActive: true, balance: CreditBalance(remaining: 5, allowance: 300, topUp: 0));
    expect(subscribed.needsOffer, isFalse);
    const required = CreditsState(status: CreditsStatus.unavailable, failure: CreditFailure.subscriptionRequired);
    expect(required.needsOffer, isTrue);
    const unconfigured = CreditsState(status: CreditsStatus.unavailable, failure: CreditFailure.modelUnconfigured);
    expect(unconfigured.needsOffer, isFalse);
  });

  test('access goes sign in, offer, consent, conversation', () {
    const known = CreditsState(status: CreditsStatus.known, periodActive: true, balance: CreditBalance(remaining: 5, allowance: 40, topUp: 0));
    const idle = AgentSessionState();
    expect(agentAccessOf(signedIn: false, credits: known, session: idle), AgentAccessView.signIn);
    expect(agentAccessOf(signedIn: true, credits: const CreditsState(status: CreditsStatus.unavailable, failure: CreditFailure.subscriptionRequired), session: idle), AgentAccessView.offer);
    expect(agentAccessOf(signedIn: true, credits: known, session: const AgentSessionState(status: AgentSessionStatus.needsConsent)), AgentAccessView.consent);
    expect(agentAccessOf(signedIn: true, credits: known, session: idle), AgentAccessView.conversation);
    expect(agentComposerBlocked(known, const AgentSessionState(failure: CreditFailure.creditsExhausted)), isFalse);
    expect(agentComposerBlocked(const CreditsState(), const AgentSessionState(failure: CreditFailure.creditsExhausted)), isTrue);
  });

  test('a simulated purchase is redeemed and applied; cancelled and failed purchases are reported', () async {
    final gateway = FakeCreditsGateway();
    final credits = CreditsCubit(gateway: gateway);
    final purchases = PurchaseCubit(store: SimulatedPurchaseStore(FakeIdentifierGenerator(['tx-9'])), gateway: gateway, credits: credits);
    await purchases.buy(AgentProduct.monthly);
    expect(purchases.state.status, PurchaseStatus.completed);
    expect(gateway.redeemed.single.transactionId, 'tx-9');
    expect(gateway.redeemed.single.store, 'simulated');
    expect(credits.state.status, CreditsStatus.known);
    gateway.next = const CreditsUnavailable(CreditFailure.purchasesDisabled);
    await purchases.buy(AgentProduct.topUp);
    expect(purchases.state.failure, CreditFailure.purchasesDisabled);
    final cancelled = PurchaseCubit(store: _CancellingStore(), gateway: gateway, credits: credits);
    await cancelled.buy(AgentProduct.trial);
    expect(cancelled.state.status, PurchaseStatus.cancelled);
    await purchases.close();
    await cancelled.close();
    await credits.close();
  });

  test('consent can be granted and withdrawn', () async {
    final store = InMemoryAgentConsentStore();
    final cubit = AgentConsentCubit(store: store);
    await cubit.load();
    expect(cubit.state, AgentConsentStatus.notGranted);
    await cubit.grant();
    expect(await store.hasConsented(), isTrue);
    await cubit.withdraw();
    expect(cubit.state, AgentConsentStatus.notGranted);
    await cubit.close();
  });
}
