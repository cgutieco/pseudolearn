final class ExecutionObservationPolicy {
  const ExecutionObservationPolicy._();

  static const int maximumHistoryWindow = 4096;
  static const int maximumCachedEvents = 4096;
  static const int eventWindowSize = 96;
  static const int valuePageSize = 64;
  static const int frameWindowSize = 32;
}
