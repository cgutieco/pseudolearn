import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/purchase_store_simulation.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import 'package:pseudolearn_app/presentation/agent/agent_subscription_controls.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_purchase_ports.dart';
import '../../fakes/purchase_widget_harness.dart';

CreditsOutcome _plan(PurchaseChannel? managedBy) =>
    CreditsKnown(CreditBalance(remaining: 120, allowance: 300, topUp: 0, managedBy: managedBy), periodActive: true);

void main() {
  testWidgets('a plan bought here can be managed and App Store purchases restored', (tester) async {
    final store = ScriptedPurchaseStore();
    final harness = PurchaseWidgetHarness(store: store, balance: _plan(PurchaseChannel.appStore));
    await harness.pump(tester, const AgentSubscriptionControls());
    expect(find.byKey(const ValueKey('agent-managed-elsewhere')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('agent-manage-subscription')));
    await tester.tap(find.byKey(const ValueKey('agent-restore-purchases')));
    await tester.pumpAndSettle();
    expect(store.managed, 1);
    expect(harness.pending.restored, 1);
  });

  testWidgets('a plan bought in another store is only named, never managed from here', (tester) async {
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(), balance: _plan(PurchaseChannel.paddle));
    await harness.pump(tester, const AgentSubscriptionControls());
    expect(find.text('Tu plan se gestiona en Paddle, desde la app de Windows.'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-manage-subscription')), findsNothing);
  });

  testWidgets('without an active plan there is nothing to manage', (tester) async {
    const lapsed = CreditsKnown(CreditBalance(remaining: 30, allowance: 0, topUp: 30));
    final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore(channel: PurchaseChannel.paddle), balance: lapsed);
    await harness.pump(tester, const AgentSubscriptionControls());
    expect(find.byKey(const ValueKey('agent-manage-subscription')), findsNothing);
    expect(find.byKey(const ValueKey('agent-restore-purchases')), findsNothing);
  });

  testWidgets('the simulated store has nothing to manage or restore', (tester) async {
    final harness = PurchaseWidgetHarness(store: SimulatedPurchaseStore(FakeIdentifierGenerator()), balance: _plan(null));
    await harness.pump(tester, const AgentSubscriptionControls());
    expect(find.byKey(const ValueKey('agent-manage-subscription')), findsNothing);
    expect(find.byKey(const ValueKey('agent-restore-purchases')), findsNothing);
  });
}
