import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/credits/credits_cubit.dart';
import 'package:pseudolearn_app/application/credits/purchase_cubit.dart';
import 'package:pseudolearn_app/data/credits/purchase_store_simulation.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/presentation/agent/agent_credits_exhausted.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/fake_agent_ports.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_purchase_ports.dart';
import '../../fakes/purchase_widget_harness.dart';

const _lapsedWithoutCredits = CreditsKnown(CreditBalance(remaining: 0, allowance: 0, topUp: 0));
const _subscribedWithoutCredits = CreditsKnown(CreditBalance(remaining: 0, allowance: 300, topUp: 0), periodActive: true);

Future<FakeCreditsGateway> _pumpPanel(WidgetTester tester, CreditsOutcome balance, {bool refresh = true}) async {
  final gateway = FakeCreditsGateway(balance);
  final credits = CreditsCubit(gateway: gateway);
  if (refresh) await credits.refresh();
  final purchases = PurchaseCubit(store: SimulatedPurchaseStore(FakeIdentifierGenerator()), pending: FakePendingPurchases(), gateway: gateway, credits: credits, links: RecordingUrlLauncher());
  addTearDown(credits.close);
  addTearDown(purchases.close);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: credits),
          BlocProvider.value(value: purchases),
        ],
        child: const AgentCreditsExhausted(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return gateway;
}

void main() {
  testWidgets('with an active plan the exhausted panel sells a top-up', (tester) async {
    final gateway = await _pumpPanel(tester, _subscribedWithoutCredits);
    expect(find.byKey(const ValueKey('agent-top-up-needs-plan')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('agent-top-up')));
    await tester.pumpAndSettle();
    expect(gateway.redeemed.single.product, AgentProduct.topUp);
  });

  testWidgets('without an active period the panel explains that a top-up needs the plan', (tester) async {
    final gateway = await _pumpPanel(tester, _lapsedWithoutCredits);
    expect(find.byKey(const ValueKey('agent-top-up')), findsNothing);
    expect(find.byKey(const ValueKey('agent-top-up-needs-plan')), findsOneWidget);
    expect(gateway.redeemed, isEmpty);
  });

  testWidgets('the top-up shows its store price when the store knows it', (tester) async {
    final harness = PurchaseWidgetHarness(
      store: ScriptedPurchaseStore(knownPrices: {AgentProduct.topUp: 'MXN 45'}),
      balance: _subscribedWithoutCredits,
    );
    await harness.pump(tester, const AgentCreditsExhausted());
    expect(find.text('Recargar 150 créditos · MXN 45'), findsOneWidget);
  });

  testWidgets('an unknown balance keeps the top-up and lets the server decide', (tester) async {
    await _pumpPanel(tester, _lapsedWithoutCredits, refresh: false);
    expect(find.byKey(const ValueKey('agent-top-up')), findsOneWidget);
  });
}
