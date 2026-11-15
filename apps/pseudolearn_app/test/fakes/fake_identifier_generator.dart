import 'package:pseudolearn_app/domain/ports/identifier_generator.dart';

final class FakeIdentifierGenerator implements IdentifierGenerator {
  final List<String> _sequence;
  int _index = 0;

  FakeIdentifierGenerator([List<String>? sequence])
      : _sequence = sequence ?? ['id-1', 'id-2', 'id-3'];

  @override
  String generate() {
    if (_index < _sequence.length) {
      final id = _sequence[_index];
      _index++;
      return id;
    }
    return 'id-${_index++}';
  }
}
