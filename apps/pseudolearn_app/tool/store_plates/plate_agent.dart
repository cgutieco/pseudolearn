import 'package:pseudolearn_app/composition/agent_services.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../test/fakes/agent_scripts.dart';
import '../../test/fakes/fake_agent_ports.dart';
import '../../test/fakes/fake_agent_services.dart';
import '../../test/fakes/fake_auth_gateway.dart';
import 'nodo_script.dart';

const AccountSession plateAccount =
    AccountSession(userId: 'store-plate', provider: AuthMethod.apple);

const CreditBalance _plateBalance =
    CreditBalance(remaining: 38, allowance: 40, topUp: 0);

AgentServices scriptedNodo(UiLanguageId language) => buildFakeAgentServices(
      modelGateway: FakeAgentModelGateway([
        textReply(nodoExchanges[language]!.reply, remaining: 37),
      ]),
      creditsGateway: FakeCreditsGateway(
        const CreditsKnown(_plateBalance, periodActive: true),
      ),
      consentStore: InMemoryAgentConsentStore(consented: true),
    );

FakeAuthGateway signedInGateway() =>
    FakeAuthGateway(currentSession: plateAccount);
