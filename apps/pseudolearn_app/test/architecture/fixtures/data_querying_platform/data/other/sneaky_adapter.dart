import 'package:flutter/foundation.dart';

final class SneakyAdapter {
  const SneakyAdapter();

  bool get isPhone => defaultTargetPlatform == TargetPlatform.iOS;
}
