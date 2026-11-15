part of 'rust_program_view.dart';

extension _RustProgramViewSemanticValidator on _RustProgramViewWireValidator {
  bool _validateSemantics(Map<String, Object?> node, String path) {
    if (!_stringList(node, 'operators', path)) return false;
    for (final key in [
      'operator',
      'builtin',
      'receiver',
      'primitive',
      'builtin_type',
      'capability_type',
      'effect_operation',
      'collection_operation',
      'type_constructor',
    ]) {
      if (node.containsKey(key) && node[key] is! String) {
        return _malformed('$path.$key');
      }
    }
    for (final key in [
      'without_newline',
      'super_constructor',
      'suspendable',
      'initialized',
      'propagates',
      'discard',
    ]) {
      if (node.containsKey(key) && node[key] is! bool) {
        return _malformed('$path.$key');
      }
    }
    return _validateLiteral(node, path);
  }

  bool _stringList(Map<String, Object?> node, String key, String path) {
    if (!node.containsKey(key)) return true;
    final value = node[key];
    if (value is! List<Object?> || value.any((item) => item is! String)) {
      return _malformed('$path.$key');
    }
    return true;
  }

  bool _validateLiteral(Map<String, Object?> node, String path) {
    if (!node.containsKey('literal')) return true;
    final literal = node['literal'];
    if (literal is! Map<String, Object?>) return _malformed('$path.literal');
    if (literal['type'] is! String || literal['value'] is! String) {
      return _malformed('$path.literal');
    }
    return true;
  }
}
