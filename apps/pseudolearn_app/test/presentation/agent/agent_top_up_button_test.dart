import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/presentation/agent/agent_top_up_button.dart';
import '../../fakes/fake_purchase_ports.dart';
import '../../fakes/purchase_widget_harness.dart';

const _receipt = PurchaseReceipt(product: AgentProduct.topUp, store: 'app_store', transactionId: '9');
const _subscribed = CreditsKnown(CreditBalance(remaining: 16, allowance: 40, topUp: 150, trial: true), periodActive: true);

void main() {
  testWidgets('a top-up the server cannot apply explains it under the button, not as an AI failure', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(attempt: const PurchaseConfirmed(_receipt)), balance: _subscribed);
    await harness.pump(tester, const AgentTopUpButton(keyPrefix: 'top-up'));
    harness.gateway.next = const CreditsUnavailable(CreditFailure.purchaseNotApplied);
    await tester.tap(find.byKey(const ValueKey('top-up')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('top-up-failure')), findsOneWidget);
    expect(find.textContaining('No se pudo sumar la compra a tu saldo'), findsOneWidget);
    expect(find.textContaining('servicio de IA'), findsNothing);
  });

  testWidgets('a store that cannot confirm the top-up says so', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(attempt: const PurchaseRefused(CreditFailure.invalidPurchase)), balance: _subscribed);
    await harness.pump(tester, const AgentTopUpButton(keyPrefix: 'top-up'));
    await tester.tap(find.byKey(const ValueKey('top-up')));
    await tester.pumpAndSettle();
    expect(find.textContaining('La tienda no pudo confirmar la compra'), findsOneWidget);
  });

  testWidgets('a successful or cancelled top-up shows no failure', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(attempt: const PurchaseConfirmed(_receipt)), balance: _subscribed);
    await harness.pump(tester, const AgentTopUpButton(keyPrefix: 'top-up'));
    await tester.tap(find.byKey(const ValueKey('top-up')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('top-up-failure')), findsNothing);
    final cancelled = PurchaseWidgetHarness(store: ScriptedPurchaseStore(), balance: _subscribed);
    await cancelled.pump(tester, const AgentTopUpButton(keyPrefix: 'top-up'));
    await tester.tap(find.byKey(const ValueKey('top-up')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('top-up-failure')), findsNothing);
  });

  testWidgets('without an active plan the button is replaced by the plan notice', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(), balance: const CreditsKnown(CreditBalance(remaining: 30, allowance: 0, topUp: 30)));
    await harness.pump(tester, const AgentTopUpButton(keyPrefix: 'top-up'));
    expect(find.byKey(const ValueKey('top-up')), findsNothing);
    expect(find.byKey(const ValueKey('top-up-needs-plan')), findsOneWidget);
  });
}
