import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/credits/credits_cubit.dart';
import 'package:pseudolearn_app/application/credits/purchase_cubit.dart';
import 'package:pseudolearn_app/application/credits/purchase_state.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/model/credits/legal_document.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import '../../fakes/fake_agent_ports.dart';
import '../../fakes/fake_purchase_ports.dart';

const _receipt = PurchaseReceipt(product: AgentProduct.topUp, store: 'app_store', transactionId: '7', evidence: 'jws');

final class _Harness {
  final gateway = FakeCreditsGateway();
  final pending = FakePendingPurchases();
  final links = RecordingUrlLauncher();
  final returns = StreamController<Uri>.broadcast();
  late final credits = CreditsCubit(gateway: gateway);
  late final ScriptedPurchaseStore store;
  late final PurchaseCubit cubit;

  _Harness({PurchaseAttempt attempt = const PurchaseCancelled(), Map<AgentProduct, String> prices = const {}}) {
    store = ScriptedPurchaseStore(attempt: attempt, knownPrices: prices, channel: PurchaseChannel.paddle);
    cubit = PurchaseCubit(store: store, pending: pending, gateway: gateway, credits: credits, links: links, returns: returns.stream);
  }

  Future<void> close() async {
    await cubit.close();
    await credits.close();
    await returns.close();
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('the channel and the store prices are known from the start', () async {
    final harness = _Harness(prices: {AgentProduct.monthly: r'$4.99'});
    await _settle();
    expect(harness.cubit.state.channel, PurchaseChannel.paddle);
    expect(harness.cubit.state.priceOf(AgentProduct.monthly), r'$4.99');
    expect(harness.cubit.state.priceOf(AgentProduct.topUp), isNull);
    await harness.close();
  });

  test('a confirmed purchase is finished only after the server accepts it', () async {
    final harness = _Harness(attempt: const PurchaseConfirmed(_receipt));
    await harness.cubit.buy(AgentProduct.topUp);
    expect(harness.cubit.state.status, PurchaseStatus.completed);
    expect(harness.pending.finished, [_receipt]);
    harness.gateway.next = const CreditsUnavailable(CreditFailure.subscriptionRequired);
    await harness.cubit.buy(AgentProduct.topUp);
    expect(harness.cubit.state.failure, CreditFailure.subscriptionRequired);
    expect(harness.pending.finished, hasLength(1));
    await harness.close();
  });

  test('pending store transactions are redeemed in the background and finished on success', () async {
    final harness = _Harness();
    harness.pending.receipts.add(_receipt);
    await _settle();
    await _settle();
    expect(harness.gateway.redeemed, [_receipt]);
    expect(harness.pending.finished, [_receipt]);
    await harness.close();
  });

  test('a refused pending transaction stays unfinished for the next attempt', () async {
    final harness = _Harness();
    harness.gateway.next = const CreditsUnavailable(CreditFailure.subscriptionRequired);
    harness.pending.receipts.add(_receipt);
    await _settle();
    expect(harness.pending.finished, isEmpty);
    await harness.close();
  });

  test('a payment outside the app waits until the return link refreshes the balance', () async {
    final harness = _Harness(attempt: const PurchaseContinuesOutside());
    await harness.cubit.buy(AgentProduct.monthly);
    expect(harness.cubit.state.status, PurchaseStatus.continuesOutside);
    harness.returns.add(Uri.parse('pseudolearn://auth/callback'));
    await _settle();
    expect(harness.cubit.state.status, PurchaseStatus.continuesOutside);
    harness.returns.add(Uri.parse('pseudolearn://agent/purchase'));
    await _settle();
    await _settle();
    expect(harness.cubit.state.status, PurchaseStatus.idle);
    expect(harness.credits.state.balance?.remaining, 40);
    await harness.close();
  });

  test('refused, cancelled and concurrent purchases are reported without redeeming', () async {
    final harness = _Harness(attempt: const PurchaseRefused(CreditFailure.alreadySubscribed));
    await harness.cubit.buy(AgentProduct.monthly);
    expect(harness.cubit.state.failure, CreditFailure.alreadySubscribed);
    harness.store.attempt = const PurchaseCancelled();
    await harness.cubit.buy(AgentProduct.monthly);
    expect(harness.cubit.state.status, PurchaseStatus.cancelled);
    expect(harness.gateway.redeemed, isEmpty);
    await harness.close();
  });

  test('restore, manage and legal links go to their ports', () async {
    final harness = _Harness();
    await harness.cubit.restore();
    expect(await harness.cubit.manageSubscription(), isTrue);
    expect(await harness.cubit.openLegal(LegalDocument.terms, 'en'), isTrue);
    expect(harness.pending.restored, 1);
    expect(harness.store.managed, 1);
    expect(harness.links.opened.single.toString(), 'https://pseudolearn.app/en/terms');
    await harness.close();
  });
}
