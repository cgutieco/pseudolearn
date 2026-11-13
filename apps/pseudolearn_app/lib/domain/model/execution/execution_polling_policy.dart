abstract final class ExecutionPollingPolicy {
  static const Duration hostPollInterval = Duration(milliseconds: 5);
  static const Duration interfaceYieldBudget = Duration(milliseconds: 8);
  static const Duration continuousRefreshInterval = Duration(milliseconds: 100);
}
