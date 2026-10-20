import 'dart:io';
import 'package:path/path.dart' as p;
import 'content/knowledge_validation.dart';
import 'content/content_engine.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

Future<void> main(List<String> args) async {
  await initializeNativeBridge();
  final basePath = Directory.current.path;
  final knowledgeTarget = args.isNotEmpty
      ? args.first
      : p.join(basePath, 'assets', 'knowledge');

  final knowledgeDir = Directory(knowledgeTarget);

  final errors = await validateKnowledgeDirectory(knowledgeDir);
  closeContentEngine();

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln('ERROR: $error');
    }
    exit(1);
  }

  stdout.writeln('Content checks passed.');
  exit(0);
}

Future<List<String>> validateKnowledgeDirectory(Directory knowledgeDir) {
  return validateKnowledge(knowledgeDir);
}
