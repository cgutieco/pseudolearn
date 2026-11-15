import '../credits/credits_state.dart';
import 'agent_session_state.dart';

enum AgentAccessView { signIn, offer, consent, conversation }

enum AgentSettingsView { introduction, loading, planCenter }

AgentAccessView agentAccessOf({
  required bool signedIn,
  required CreditsState credits,
  required AgentSessionState session,
}) {
  if (!signedIn) return AgentAccessView.signIn;
  if (credits.needsOffer) return AgentAccessView.offer;
  if (session.status == AgentSessionStatus.needsConsent) return AgentAccessView.consent;
  return AgentAccessView.conversation;
}

bool agentComposerBlocked(CreditsState credits, AgentSessionState session) =>
    credits.status == CreditsStatus.known ? credits.isExhausted : session.blocksComposer;

bool agentLauncherShown({required bool signedIn, required CreditsState credits, required bool preferred}) =>
    signedIn && preferred && credits.hasAccess;

AgentSettingsView agentSettingsViewOf({required bool signedIn, required CreditsState credits}) {
  if (!signedIn) return AgentSettingsView.introduction;
  if (credits.hasAccess) return AgentSettingsView.planCenter;
  if (credits.awaitsFirstBalance) return AgentSettingsView.loading;
  return AgentSettingsView.introduction;
}
