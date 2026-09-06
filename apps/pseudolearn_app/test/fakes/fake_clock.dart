import 'package:pseudolearn_app/domain/ports/clock.dart';

final class FakeClock implements Clock {
  DateTime _now;

  FakeClock([DateTime? initial]) : _now = initial ?? DateTime(2026, 1, 1, 12, 0, 0);

  @override
  DateTime now() => _now;

  void setNow(DateTime time) {
    _now = time;
  }

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}
