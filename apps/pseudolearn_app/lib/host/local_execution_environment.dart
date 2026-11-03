import 'dart:io';

import '../domain/ports/execution_environment.dart';

final class LocalExecutionEnvironment implements ExecutionEnvironment {
  final String root;

  const LocalExecutionEnvironment(this.root);

  @override
  String directoryFor(String documentId) =>
      Directory('$root/execution/${Uri.encodeComponent(documentId)}').path;
}
