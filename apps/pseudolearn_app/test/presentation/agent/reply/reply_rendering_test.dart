import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/presentation/agent/reply/reply_flowchart_painter.dart';
import '../../../fakes/agent_scripts.dart';
import '../../../fakes/fake_agent_ports.dart';
import '../../../fakes/fake_agent_services.dart';
import '../../../fakes/fake_auth_gateway.dart';
import '../../../fakes/test_dependencies.dart';

const String _richReply = '''
## Comparación

| Función | PseudoLearn | Python | Go |
|---|:-:|---|---|
| Mostrar texto | `Escribir "Hola";` | `print("Hola")` | `fmt.Println("Hola")` |
| Bucle mientras | `Mientras ... Hacer` | `while ...:` | `for ... {` |

- [x] Leer el enunciado
- [ ] Probar con **casos**

> [!WARNING]
> No olvides el punto y coma.

```javascript
const total = suma(2, 3); // cinco
```

```pseudolearn
Algoritmo P
  Escribir 1;
FinAlgoritmo
```

```mermaid
flowchart TD
  A[Programa] -->|válido| B{¿Errores?}
  B --> C[Diagnósticos]
```

```mermaid
pie title Lenguajes
  "Python" : 60
```
''';

Finder _composerField() =>
    find.descendant(of: find.byKey(const ValueKey('agent-composer')), matching: find.byType(TextField));

Future<void> _askForRichReply(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(CubitScope(
    dependencies: buildTestDependencies(
      authGateway: FakeAuthGateway(currentSession: const AccountSession(userId: 'u1', provider: AuthMethod.google)),
      agent: buildFakeAgentServices(
        modelGateway: FakeAgentModelGateway([textReply(_richReply)]),
        creditsGateway: FakeCreditsGateway(
          CreditsKnown(const CreditBalance(remaining: 30, allowance: 40, topUp: 0), periodActive: true),
        ),
        consentStore: InMemoryAgentConsentStore(consented: true),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('feature:agent')));
  await tester.pumpAndSettle();
  await tester.enterText(_composerField(), 'compara');
  await tester.tap(find.byKey(const ValueKey('agent-send')));
  await tester.pumpAndSettle();
}

Finder _flowchartPaint() =>
    find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is ReplyFlowchartPainter);

void main() {
  testWidgets('a rich reply renders tables, tasks, alerts, code and diagrams', (tester) async {
    await _askForRichReply(tester, const Size(1280, 900));
    expect(find.text('Comparación'), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('Mostrar texto'), findsOneWidget);
    expect(find.text('Escribir "Hola";'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    expect(find.text('javascript'), findsOneWidget);
    expect(find.text('PseudoLearn'), findsNWidgets(2));
    expect(_flowchartPaint(), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-diagram-unsupported')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the diagram toggles to its source and back', (tester) async {
    await _askForRichReply(tester, const Size(1280, 2400));
    final toggle = find.byKey(const ValueKey('agent-diagram-toggle'));
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(_flowchartPaint(), findsNothing);
    expect(find.textContaining('A[Programa]'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(_flowchartPaint(), findsOneWidget);
  });

  testWidgets('on a phone wide tables and code scroll instead of overflowing', (tester) async {
    await _askForRichReply(tester, const Size(390, 844));
    expect(find.byType(Table), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
