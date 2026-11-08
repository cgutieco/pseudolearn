import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

Future<void> _pumpApp(WidgetTester tester, {required FakeAuthGateway auth, required FakeCreditsGateway credits, required FakeAgentModelGateway model, InMemoryAgentConsentStore? consent}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(CubitScope(
    dependencies: buildTestDependencies(
      authGateway: auth,
      agent: buildFakeAgentServices(modelGateway: model, creditsGateway: credits, consentStore: consent),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without an account Nodo offers to sign in', (tester) async {
    await _pumpApp(tester, auth: FakeAuthGateway(), credits: FakeCreditsGateway(), model: FakeAgentModelGateway());
    await _openAgent(tester);
    expect(find.byKey(const ValueKey('agent-sign-in')), findsOneWidget);
  });

  testWidgets('the simulated journey: offer, trial, consent, chat, exhausted, top-up', (tester) async {
    final credits = FakeCreditsGateway(_balance(0, active: false));
    final model = FakeAgentModelGateway([
      textReply('Hola, soy Nodo.', remaining: 39),
      const ModelFailed(CreditFailure.creditsExhausted),
      textReply('De nuevo aquí.', remaining: 149),
    ]);
    await _pumpApp(tester, auth: FakeAuthGateway(currentSession: _account), credits: credits, model: model);
    await _openAgent(tester);
    expect(find.byKey(const ValueKey('agent-offer')), findsOneWidget);

    credits.next = _balance(40);
    await tester.tap(find.byKey(const ValueKey('agent-buy-trial')));
    await tester.pumpAndSettle();
    expect(credits.redeemed.single.product, AgentProduct.trial);

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
}
