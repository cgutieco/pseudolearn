import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_view_semantics.dart';

void main() {
  test('projects capability, builtin type and effect operation attributes', () {
    final capability = RustViewSemantics.fromJson({'capability_type': 'file'});
    final builtin = RustViewSemantics.fromJson({'builtin_type': 'io_error'});
    final operation = RustViewSemantics.fromJson({
      'effect_operation': 'file_open',
    });
    expect(capability.capabilityType, 'file');
    expect(builtin.builtinType, 'io_error');
    expect(operation.effectOperation, 'file_open');
  });

  test('a node without the new attributes projects none of them', () {
    final semantics = RustViewSemantics.fromJson({'primitive': 'integer'});
    expect(semantics.primitive, 'integer');
    expect(semantics.capabilityType, isNull);
    expect(semantics.builtinType, isNull);
    expect(semantics.effectOperation, isNull);
  });

  test('the empty semantics carries no capability information', () {
    expect(RustViewSemantics.none.capabilityType, isNull);
    expect(RustViewSemantics.none.effectOperation, isNull);
  });
}
