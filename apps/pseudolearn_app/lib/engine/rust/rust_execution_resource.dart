final class RustExecutionResource {
  int? _identifier;
  String? _revisionId;
  bool _debugConfigured = false;

  int? get identifier => _identifier;

  String? get revisionId => _revisionId;

  bool get debugConfigured => _debugConfigured;

  void open(int identifier, String revisionId) {
    _identifier = identifier;
    _revisionId = revisionId;
    _debugConfigured = false;
  }

  void markDebugConfigured() {
    _debugConfigured = true;
  }

  void clear() {
    _identifier = null;
    _revisionId = null;
    _debugConfigured = false;
  }
}
