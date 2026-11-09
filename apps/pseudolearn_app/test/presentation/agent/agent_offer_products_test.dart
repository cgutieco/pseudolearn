import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/purchase_store_simulation.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import 'package:pseudolearn_app/presentation/agent/agent_offer_products.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_purchase_ports.dart';
import '../../fakes/purchase_widget_harness.dart';

const _noPlan = CreditsKnown(CreditBalance(remaining: 0, allowance: 0, topUp: 0));
const _trialSpent = CreditsKnown(CreditBalance(remaining: 0, allowance: 0, topUp: 0), trialUsed: true);

void main() {
  testWidgets('in the App Store the billed price leads, the trial follows and one button subscribes', (tester) async {
    final harness = PurchaseWidgetHarness(
      store: ScriptedPurchaseStore(knownPrices: {AgentProduct.monthly: 'S/ 12,90'}),
      balance: _noPlan,
    );
    await harness.pump(tester, const AgentOfferProducts());
    expect(find.text('S/ 12,90 al mes'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-offer-trial-included')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-buy-trial')), findsNothing);
    expect(find.text('Suscribirme'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-offer-legal')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-offer-restore')), findsOneWidget);
    final priceTop = tester.getTopLeft(find.byKey(const ValueKey('agent-offer-price'))).dy;
    final trialTop = tester.getTopLeft(find.byKey(const ValueKey('agent-offer-trial-included'))).dy;
    expect(priceTop, lessThan(trialTop));
  });

  testWidgets('without a store price the offer defers it to the checkout and hides a spent trial', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(channel: PurchaseChannel.paddle), balance: _trialSpent);
    await harness.pump(tester, const AgentOfferProducts());
    expect(find.byKey(const ValueKey('agent-offer-price-at-checkout')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-offer-trial-included')), findsNothing);
    expect(find.byKey(const ValueKey('agent-offer-restore')), findsNothing);
  });

  testWidgets('a payment in the browser explains how to come back', (tester) async {
    final harness = PurchaseWidgetHarness(
      store: ScriptedPurchaseStore(channel: PurchaseChannel.paddle, attempt: const PurchaseContinuesOutside()),
      balance: _noPlan,
    );
    await harness.pump(tester, const AgentOfferProducts());
    await tester.tap(find.byKey(const ValueKey('agent-buy-monthly')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-purchase-outside')), findsOneWidget);
  });

  testWidgets('the simulated store keeps its own trial and says no money is charged', (tester) async {
    final harness = PurchaseWidgetHarness(store: SimulatedPurchaseStore(FakeIdentifierGenerator()), balance: _noPlan);
    await harness.pump(tester, const AgentOfferProducts(), locale: 'en');
    expect(find.byKey(const ValueKey('agent-buy-trial')), findsOneWidget);
    expect(find.text('Simulated purchases: no money is charged.'), findsOneWidget);
  });

  testWidgets('the legal links open the terms and the privacy page in the reader language', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(), balance: _noPlan);
    await harness.pump(tester, const AgentOfferProducts(), locale: 'en');
    await tester.tap(find.byKey(const ValueKey('agent-offer-terms')));
    await tester.tap(find.byKey(const ValueKey('agent-offer-privacy')));
    await tester.pumpAndSettle();
    expect(harness.links.opened.map((url) => url.path), ['/en/terms', '/en/privacy']);
  });
}
