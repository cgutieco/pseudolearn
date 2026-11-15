import 'dart:math';
import '../../domain/ports/identifier_generator.dart';

final class RandomIdentifierGenerator implements IdentifierGenerator {
  final Random _random;

  RandomIdentifierGenerator([Random? random])
      : _random = random ?? Random.secure();

  @override
  String generate() {
    final values = List<int>.generate(16, (_) => _random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
