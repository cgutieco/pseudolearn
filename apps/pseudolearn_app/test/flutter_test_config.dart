import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'fakes/load_bundled_fonts.dart';
import 'fakes/native_test_engine.dart';
import '../tool/content/content_engine.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeNativeBridge();
  await loadBundledFonts();
  tearDownAll(() {
    closeTestEngine();
    closeContentEngine();
  });
  await testMain();
}
