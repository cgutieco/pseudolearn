import 'dart:io';
import 'package:path/path.dart' as p;
import 'content/knowledge_validation.dart';

Future<void> main(List<String> args) async {
  final basePath = Directory.current.path;
  final knowledgeTarget = args.isNotEmpty ? args.first : p.join(basePath, 'assets', 'knowledge');

  final knowledgeDir = Directory(knowledgeTarget);

  final errors = await validateKnowledgeDirectory(knowledgeDir);

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
