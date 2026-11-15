import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/credits/credit_plan_summary.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/presentation/agent/agent_plan_status_card.dart';
import '../../fakes/fake_purchase_ports.dart';
import '../../fakes/purchase_widget_harness.dart';

Future<void> _pump(WidgetTester tester, CreditBalance balance, {required bool periodActive, int lastSpent = 0}) {
  final harness = PurchaseWidgetHarness(store: ScriptedPurchaseStore());
  final plan = CreditPlanSummary.of(balance, periodActive: periodActive);
  return harness.pump(tester, AgentPlanStatusCard(plan: plan, lastSpent: lastSpent), refresh: false);
}

void main() {
  testWidgets('a monthly plan leads with the balance and explains where it comes from', (tester) async {
    await _pump(tester, CreditBalance(remaining: 166, allowance: 300, topUp: 38, renewsAt: DateTime.utc(2026, 11, 15, 12)), periodActive: true, lastSpent: 4);
    expect(find.text('166'), findsOneWidget);
    expect(find.text('créditos disponibles'), findsOneWidget);
    expect(find.text('Plan mensual'), findsOneWidget);
    expect(find.text('128 de 300 del mes'), findsOneWidget);
    expect(find.text('+38 de recarga'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-plan-renews')), findsOneWidget);
    expect(find.text('Tu última petición gastó 4 créditos'), findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(find.byKey(const ValueKey('agent-plan-meter'))).value, closeTo(128 / 300, 1e-9));
  });

  testWidgets('one credit and no requests use the singular and the empty wording', (tester) async {
    await _pump(tester, const CreditBalance(remaining: 1, allowance: 40, topUp: 0, trial: true), periodActive: true);
    expect(find.text('crédito disponible'), findsOneWidget);
    expect(find.text('Prueba gratuita'), findsOneWidget);
    expect(find.text('Aún no has hecho peticiones'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-plan-top-up-left')), findsNothing);
  });

  testWidgets('top-ups alone show no meter and no renewal', (tester) async {
    await _pump(tester, CreditBalance(remaining: 150, allowance: 0, topUp: 150, renewsAt: DateTime.utc(2026, 12)), periodActive: false);
    expect(find.text('Solo recargas'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-plan-meter')), findsNothing);
    expect(find.byKey(const ValueKey('agent-plan-renews')), findsNothing);
  });
}
