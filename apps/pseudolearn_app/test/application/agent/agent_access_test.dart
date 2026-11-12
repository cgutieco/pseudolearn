import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_access.dart';
import 'package:pseudolearn_app/application/credits/credits_state.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';

const _active = CreditsState(status: CreditsStatus.known, balance: CreditBalance(remaining: 30, allowance: 300, topUp: 0), periodActive: true);
const _lapsedWithTopUp = CreditsState(status: CreditsStatus.known, balance: CreditBalance(remaining: 20, allowance: 0, topUp: 20));
const _lapsedEmpty = CreditsState(status: CreditsStatus.known, balance: CreditBalance(remaining: 0, allowance: 0, topUp: 0));

void main() {
  group('launcher', () {
    test('shows only for a signed-in account with access that did not hide it', () {
      expect(agentLauncherShown(signedIn: true, credits: _active, preferred: true), isTrue);
      expect(agentLauncherShown(signedIn: true, credits: _lapsedWithTopUp, preferred: true), isTrue);
    });

    test('hides without an account, even with a cached plan', () {
      expect(agentLauncherShown(signedIn: false, credits: _active, preferred: true), isFalse);
    });

    test('hides when the person turned it off', () {
      expect(agentLauncherShown(signedIn: true, credits: _active, preferred: false), isFalse);
    });

    test('hides without a plan, before the first balance and when the server asks for a plan', () {
      expect(agentLauncherShown(signedIn: true, credits: _lapsedEmpty, preferred: true), isFalse);
      expect(agentLauncherShown(signedIn: true, credits: const CreditsState(), preferred: true), isFalse);
      const required = CreditsState(status: CreditsStatus.unavailable, balance: CreditBalance(remaining: 30, allowance: 300, topUp: 0), periodActive: true, failure: CreditFailure.subscriptionRequired);
      expect(agentLauncherShown(signedIn: true, credits: required, preferred: true), isFalse);
    });

    test('an offline refresh keeps a known plan', () {
      const offline = CreditsState(status: CreditsStatus.unavailable, balance: CreditBalance(remaining: 30, allowance: 300, topUp: 0), periodActive: true, failure: CreditFailure.offline);
      expect(agentLauncherShown(signedIn: true, credits: offline, preferred: true), isTrue);
    });
  });

  group('settings view', () {
    test('without an account Nodo is introduced', () {
      expect(agentSettingsViewOf(signedIn: false, credits: _active), AgentSettingsView.introduction);
    });

    test('with access the plan center opens', () {
      expect(agentSettingsViewOf(signedIn: true, credits: _active), AgentSettingsView.planCenter);
      expect(agentSettingsViewOf(signedIn: true, credits: _lapsedWithTopUp), AgentSettingsView.planCenter);
    });

    test('the first balance is awaited instead of flashing the introduction', () {
      expect(agentSettingsViewOf(signedIn: true, credits: const CreditsState()), AgentSettingsView.loading);
      expect(agentSettingsViewOf(signedIn: true, credits: const CreditsState(status: CreditsStatus.loading)), AgentSettingsView.loading);
    });

    test('without a plan or when the balance cannot be read Nodo is introduced', () {
      expect(agentSettingsViewOf(signedIn: true, credits: _lapsedEmpty), AgentSettingsView.introduction);
      expect(agentSettingsViewOf(signedIn: true, credits: const CreditsState(status: CreditsStatus.unavailable, failure: CreditFailure.offline)), AgentSettingsView.introduction);
    });
  });
}
