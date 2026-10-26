import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

final class CorpusProgram {
  final String name;
  final String source;
  final SyntaxProfileId profile;

  const CorpusProgram(this.name, this.source, this.profile);

  UiLanguageId get language => profile == SyntaxProfileId.english
      ? UiLanguageId.english
      : UiLanguageId.spanish;
}

SyntaxProfileId _profileOf(String path, String suffix) =>
    path.endsWith(suffix) ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish;

List<CorpusProgram> exampleCorpus() {
  final files = Directory('assets/knowledge/examples')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.pseudo'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      CorpusProgram(
        file.uri.pathSegments.last,
        file.readAsStringSync(),
        _profileOf(file.path, '_en.pseudo'),
      ),
  ];
}

List<CorpusProgram> exerciseSolutionCorpus() {
  final files = Directory('assets/knowledge/exercises')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      CorpusProgram(
        file.uri.pathSegments.last,
        (jsonDecode(file.readAsStringSync())
                as Map<String, Object?>)['referenceSolution']
            as String,
        _profileOf(file.path, '_en.json'),
      ),
  ];
}

const List<(String, String)> defectivePrograms = [
  (
    'undeclared variable',
    'Algoritmo P\n  a <- 1;\nFinAlgoritmo\n',
  ),
  (
    'unterminated block',
    'Algoritmo P\n  Definir Mutable a Como Entero <- 0;\n  Si a = 1 Entonces\n    a <- 2;\nFinAlgoritmo\n',
  ),
  (
    'type mismatch',
    'Algoritmo P\n  Definir Mutable a Como Entero <- 0;\n  a <- "texto";\nFinAlgoritmo\n',
  ),
  ('empty program', ''),
  ('missing algorithm end', 'Algoritmo P\n  Definir a Como Entero <- 0;\n'),
];
