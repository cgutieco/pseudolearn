final class RustEffectPolicy {
  static const Set<String> _containedOperations = {
    'console_write',
    'console_write_error',
    'console_set_exit_code',
    'arguments_values',
    'clock_now',
    'clock_local_now',
    'timer_wait',
  };

  static const Map<String, Object?> refusal = {
    'outcome': 'failed',
    'value': {'code': 'permiso_denegado', 'uncertain': false},
  };

  final Set<String>? _admittedOperations;

  const RustEffectPolicy.unrestricted() : _admittedOperations = null;

  const RustEffectPolicy.contained()
    : _admittedOperations = _containedOperations;

  bool admits(Map<String, Object?> effect) {
    final admitted = _admittedOperations;
    return admitted == null || admitted.contains(effect['operation']);
  }
}
