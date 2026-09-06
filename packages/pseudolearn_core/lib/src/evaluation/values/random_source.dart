abstract interface class RandomSource {
  double nextUnitInterval();
}

final class SeededRandomSource implements RandomSource {
  static const int defaultSeed = 0x9E3779B9;

  int _state;

  SeededRandomSource([int seed = defaultSeed]) : _state = seed & 0xFFFFFFFF;

  @override
  double nextUnitInterval() {
    _state = (_state + 0x6D2B79B7) & 0xFFFFFFFF;
    var t = _state;
    t = _multiply32(t ^ (t >> 15), t | 1);
    t = (t ^ _multiply32(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    final result = (t ^ (t >> 14)) & 0xFFFFFFFF;
    return result / 4294967296.0;
  }

  static int _multiply32(int a, int b) {
    final aHigh = (a >> 16) & 0xFFFF;
    final aLow = a & 0xFFFF;
    final bHigh = (b >> 16) & 0xFFFF;
    final bLow = b & 0xFFFF;
    final low = (aLow * bLow) & 0xFFFFFFFF;
    final mid = ((aHigh * bLow + aLow * bHigh) & 0xFFFF) << 16;
    return (low + mid) & 0xFFFFFFFF;
  }
}
