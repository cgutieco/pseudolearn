import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_cubit.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/agent/model_outcome.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import '../../fakes/agent_scripts.dart';
import '../../fakes/fake_agent_ports.dart';
import '../../fakes/fake_agent_services.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/in_memory_preferences_store.dart';
import '../../fakes/pump_app.dart';
import '../../fakes/test_dependencies.dart';

const _account = AccountSession(userId: 'u1', provider: AuthMethod.google);

CreditsOutcome _balance(int remaining, {bool active = true}) => CreditsKnown(
  CreditBalance(remaining: remaining, allowance: active ? 40 : 0, topUp: 0, trial: active),
  periodActive: active,
);

Future<void> _openAgent(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('feature:agent')));
  await tester.pumpAndSettle();
}

const _launcher = ValueKey('feature:agent');

Future<void> _pumpApp(WidgetTester tester, {required FakeAuthGateway auth, required FakeCreditsGateway credits, required FakeAgentModelGateway model, InMemoryAgentConsentStore? consent, InMemoryPreferencesStore? preferences}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(CubitScope(
    dependencies: buildTestDependencies(
      authGateway: auth,
      preferences: preferences,
      agent: buildFakeAgentServices(modelGateway: model, creditsGateway: credits, consentStore: consent),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without an account the launcher is hidden and settings introduces Nodo with a sign-in call', (tester) async {
    await _pumpApp(tester, auth: FakeAuthGateway(), credits: FakeCreditsGateway(), model: FakeAgentModelGateway());
    expect(find.byKey(_launcher), findsNothing);
    await visitDestination(tester, '/ajustes/nodo');
    expect(find.byKey(const ValueKey('agent-introduction')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-introduction-top-up')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-sign-in')), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-buy-monthly')), findsNothing);
    expect(find.byKey(_launcher), findsNothing);
  });

  testWidgets('the simulated journey: introduction, trial, plan center, consent, chat, exhausted, top-up', (tester) async {
    final credits = FakeCreditsGateway(_balance(0, active: false));
    final model = FakeAgentModelGateway([
      textReply('Hola, soy Nodo.', remaining: 39),
      const ModelFailed(CreditFailure.creditsExhausted),
      textReply('De nuevo aquí.', remaining: 149),
    ]);
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: credits, model: model);
    expect(find.byKey(_launcher), findsNothing);
    await visitDestination(tester, '/ajustes/nodo');
    expect(find.byKey(const ValueKey('agent-introduction')), findsOneWidget);

    credits.next = _balance(40);
    await tester.tap(find.byKey(const ValueKey('agent-buy-trial')));
    await tester.pumpAndSettle();
    expect(credits.redeemed.single.product, AgentProduct.trial);
    expect(find.byKey(const ValueKey('agent-plan-center')), findsOneWidget);
    expect(find.text('Prueba gratuita'), findsOneWidget);
    expect(find.byKey(_launcher), findsOneWidget);
    await _openAgent(tester);

    await tester.enterText(find.descendant(of: find.byKey(const ValueKey('agent-composer')), matching: find.byType(TextField)), 'hola');
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-consent')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('agent-consent-accept')));
    await tester.pumpAndSettle();
    expect(find.text('Hola, soy Nodo.'), findsOneWidget);

    credits.next = _balance(0);
    await tester.enterText(find.descendant(of: find.byKey(const ValueKey('agent-composer')), matching: find.byType(TextField)), 'otra');
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-exhausted')), findsOneWidget);

    credits.next = CreditsKnown(const CreditBalance(remaining: 150, allowance: 40, topUp: 150), periodActive: true);
    await tester.tap(find.byKey(const ValueKey('agent-top-up')));
    await tester.pumpAndSettle();
    expect(credits.redeemed.last.product, AgentProduct.topUp);
    await tester.enterText(find.descendant(of: find.byKey(const ValueKey('agent-composer')), matching: find.byType(TextField)), 'sigue');
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();
    expect(find.text('De nuevo aquí.'), findsOneWidget);
  });

  testWidgets('a destructive request shows the confirmation bar with a preview', (tester) async {
    final model = FakeAgentModelGateway([
      toolReply('delete_document', '{"document_id":"missing"}'),
      textReply('No lo borré.'),
    ]);
    await _pumpApp(
      tester,
      auth: FakeAuthGateway(currentSession: _account),
      credits: FakeCreditsGateway(_balance(30)),
      model: model,
      consent: InMemoryAgentConsentStore(consented: true),
    );
    await _openAgent(tester);
    await tester.enterText(find.descendant(of: find.byKey(const ValueKey('agent-composer')), matching: find.byType(TextField)), 'borra');
    await tester.tap(find.byKey(const ValueKey('agent-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-confirmation')), findsOneWidget);
    expect(find.textContaining('missing'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('agent-decline')));
    await tester.pumpAndSettle();
    expect(find.text('No lo borré.'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-confirmation')), findsNothing);
  });

  testWidgets('on a phone the composer stays above the keyboard', (tester) async {
    await _pumpApp(
      tester,
      auth: FakeAuthGateway(currentSession: _account),
      credits: FakeCreditsGateway(_balance(30)),
      model: FakeAgentModelGateway(),
      consent: InMemoryAgentConsentStore(consented: true),
    );
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    await _openAgent(tester);
    const keyboardHeight = 300.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final composerBottom = tester.getBottomLeft(find.byKey(const ValueKey('agent-composer'))).dy;
    expect(composerBottom, lessThanOrEqualTo(844 - keyboardHeight));
  });

  testWidgets('hiding the launcher removes it everywhere and the choice survives a restart', (tester) async {
    final preferences = InMemoryPreferencesStore();
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: FakeCreditsGateway(_balance(30)), model: FakeAgentModelGateway(), preferences: preferences);
    expect(find.byKey(_launcher), findsOneWidget);
    await visitDestination(tester, '/ajustes/nodo');
    await tester.scrollUntilVisible(find.text('Ocultar'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Ocultar'));
    await tester.pumpAndSettle();
    expect(find.byKey(_launcher), findsNothing);
    expect((await preferences.read()).agentLauncherShown, isFalse);

    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: FakeCreditsGateway(_balance(30)), model: FakeAgentModelGateway(), preferences: preferences);
    expect(find.byKey(_launcher), findsNothing);
    await visitDestination(tester, '/ajustes/nodo');
    await tester.scrollUntilVisible(find.text('Mostrar en todas las pantallas'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Mostrar en todas las pantallas'));
    await tester.pumpAndSettle();
    expect(find.byKey(_launcher), findsOneWidget);
  });

  testWidgets('a lapsed plan with top-up credits keeps the launcher and offers to subscribe again', (tester) async {
    const lapsed = CreditsKnown(CreditBalance(remaining: 150, allowance: 0, topUp: 150));
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: FakeCreditsGateway(lapsed), model: FakeAgentModelGateway());
    expect(find.byKey(_launcher), findsOneWidget);
    await visitDestination(tester, '/ajustes/nodo');
    expect(find.byKey(const ValueKey('agent-plan-lapsed')), findsOneWidget);
    expect(find.text('Solo recargas'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-plan-meter')), findsNothing);
    expect(find.byKey(const ValueKey('agent-plan-renews')), findsNothing);
  });

  testWidgets('a signed-in account without a plan never sees the launcher', (tester) async {
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: FakeCreditsGateway(const CreditsUnavailable(CreditFailure.subscriptionRequired)), model: FakeAgentModelGateway());
    expect(find.byKey(_launcher), findsNothing);
  });

  testWidgets('signing out turns Nodo off and the introduction asks to buy it or sign in again', (tester) async {
    final auth = FakeAuthGateway(currentSession: _account);
    await _pumpApp(tester, auth: auth, credits: FakeCreditsGateway(_balance(30)), model: FakeAgentModelGateway());
    expect(find.byKey(_launcher), findsOneWidget);
    await tester.element(find.byKey(_launcher)).read<AccountCubit>().signOut();
    await tester.pumpAndSettle();
    expect(find.byKey(_launcher), findsNothing);
    await visitDestination(tester, '/ajustes/nodo');
    expect(find.byKey(const ValueKey('agent-sign-in')), findsOneWidget);
    expect(find.textContaining('ya tenga Nodo activo'), findsOneWidget);
  });

  testWidgets('pulling the plan center down reads the balance again, with no refresh button', (tester) async {
    final credits = FakeCreditsGateway(_balance(30));
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: credits, model: FakeAgentModelGateway());
    await visitDestination(tester, '/ajustes/nodo');
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Actualizar saldo'), findsNothing);
    credits.next = _balance(25);
    await tester.fling(find.byKey(const ValueKey('agent-plan-center')), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('a failed pull keeps the known balance and says why', (tester) async {
    final credits = FakeCreditsGateway(_balance(30));
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: credits, model: FakeAgentModelGateway());
    await visitDestination(tester, '/ajustes/nodo');
    credits.next = const CreditsUnavailable(CreditFailure.offline);
    await tester.fling(find.byKey(const ValueKey('agent-plan-center')), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Necesita conexión. No se cobró nada.'), findsOneWidget);
  });
}
