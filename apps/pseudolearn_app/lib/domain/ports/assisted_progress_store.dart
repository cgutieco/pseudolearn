abstract interface class AssistedProgressStore {
  Future<void> markAssisted(String progressId);
  Future<Set<String>> assistedIds();
}
