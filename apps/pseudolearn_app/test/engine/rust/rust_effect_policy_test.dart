import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_policy.dart';

void main() {
  Map<String, Object?> effect(String operation) => {
    'effect_seq': 1,
    'operation': operation,
  };

  group('unrestricted policy', () {
    const policy = RustEffectPolicy.unrestricted();

    test('admits file, network and environment effects', () {
      expect(policy.admits(effect('request_directory')), isTrue);
      expect(policy.admits(effect('network_send')), isTrue);
      expect(policy.admits(effect('environment_get')), isTrue);
    });

    test('admits an effect without an operation', () {
      expect(policy.admits(const {'effect_seq': 1}), isTrue);
    });
  });

  group('contained policy', () {
    const policy = RustEffectPolicy.contained();

    test('admits console, arguments, clock and timer effects', () {
      for (final operation in [
        'console_write',
        'console_write_error',
        'console_set_exit_code',
        'arguments_values',
        'clock_now',
        'clock_local_now',
        'timer_wait',
      ]) {
        expect(policy.admits(effect(operation)), isTrue, reason: operation);
      }
    });

    test('refuses directory, file, network and environment effects', () {
      for (final operation in [
        'request_directory',
        'request_network',
        'file_open',
        'file_write_text',
        'directory_delete',
        'network_send',
        'environment_get',
      ]) {
        expect(policy.admits(effect(operation)), isFalse, reason: operation);
      }
    });

    test('refuses an effect without an operation', () {
      expect(policy.admits(const {'effect_seq': 1}), isFalse);
    });

    test('refuses an empty operation name', () {
      expect(policy.admits(effect('')), isFalse);
    });
  });

  test('the refusal is a certain permission failure', () {
    expect(RustEffectPolicy.refusal['outcome'], 'failed');
    expect(RustEffectPolicy.refusal['value'], {
      'code': 'permiso_denegado',
      'uncertain': false,
    });
  });
}
