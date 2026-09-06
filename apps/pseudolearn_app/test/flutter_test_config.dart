import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'fakes/load_bundled_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadBundledFonts();
  await testMain();
}
