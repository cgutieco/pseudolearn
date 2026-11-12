abstract interface class AgentConsentStore {
  Future<bool> hasConsented();
  Future<void> grant();
  Future<void> withdraw();
}
