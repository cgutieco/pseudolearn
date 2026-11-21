final class RustEffectTapeAssembly {
  Map<String, Object?>? _header;
  final List<Object?> _entries = [];

  int get entryCount => _entries.length;

  void receive(Map<String, Object?>? window, {required int from}) {
    if (window == null) return;
    final entries = window['entries'];
    if (entries is! List<Object?> || from > _entries.length) {
      throw const FormatException('Invalid effect tape window');
    }
    _entries
      ..removeRange(from, _entries.length)
      ..addAll(entries);
    _header = window;
  }

  Map<String, Object?>? document() {
    final header = _header;
    if (header == null) return null;
    return {...header, 'entries': List<Object?>.of(_entries)};
  }

  void clear() {
    _header = null;
    _entries.clear();
  }
}
