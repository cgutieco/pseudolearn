import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../tool/content/execution_host_checks.dart';

void main() {
  test('product sources only reference physical execution hosts', () async {
    expect(await validateExecutionHostDirectory(Directory('lib')), isEmpty);
  });
  test('a retired host fixture is rejected', () async {
    final source = await File(
      'tool/fixtures/retired_execution_host.fixture',
    ).readAsString();
    expect(validateExecutionHostSource(source, 'fixture'), isNotEmpty);
    expect(
      validateExecutionHostSource('final host = NativeHost();', 'control'),
      isEmpty,
    );
  });
}
