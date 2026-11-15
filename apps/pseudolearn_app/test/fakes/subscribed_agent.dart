import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/ports/preferences_store.dart';
import 'fake_agent_ports.dart';
import 'fake_agent_services.dart';
import 'fake_auth_gateway.dart';
import 'test_dependencies.dart';

const AccountSession subscribedAccount = AccountSession(userId: 'u1', provider: AuthMethod.google);

const CreditsOutcome subscribedBalance =
    CreditsKnown(CreditBalance(remaining: 30, allowance: 40, topUp: 0, trial: true), periodActive: true);

AppDependencies buildSubscribedDependencies({FakeCreditsGateway? credits, PreferencesStore? preferences}) =>
    buildTestDependencies(
      authGateway: FakeAuthGateway(currentSession: subscribedAccount),
      preferences: preferences,
      agent: buildFakeAgentServices(creditsGateway: credits ?? FakeCreditsGateway(subscribedBalance)),
    );
