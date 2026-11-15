import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/asset_knowledge_index.dart';
import 'package:pseudolearn_app/data/agent/knowledge_parsers.dart';
import 'package:pseudolearn_app/data/agent/knowledge_text.dart';
import 'package:pseudolearn_app/domain/model/agent/knowledge_hit.dart';

AssetKnowledgeIndex _index() =>
    AssetKnowledgeIndex(assetLoader: (path) => File(path).readAsString());

void main() {
  test('a Spanish question about arguments finds the run options entry', () async {
    final hits = await _index().search(query: '¿Para qué sirve el campo de argumentos?', languageCode: 'es');
    expect(hits.first.citation, 'manual:execution-options');
    expect(hits.first.languageCode, 'es');
  });

  test('language questions reach the specification and the sheet', () async {
    final hits = await _index().search(query: 'arreglos índice cero', languageCode: 'es', limit: 10);
    expect(hits.map((hit) => hit.source), contains(KnowledgeSource.languageSheet));
    expect(hits.map((hit) => hit.source), contains(KnowledgeSource.specification));
  });

  test('an empty or symbol-only query returns nothing', () async {
    expect(await _index().search(query: '', languageCode: 'es'), isEmpty);
    expect(await _index().search(query: '¿?¡!', languageCode: 'en'), isEmpty);
  });

  test('a query with no match returns nothing in either language', () async {
    expect(await _index().search(query: 'zzqxv wqpqz', languageCode: 'es'), isEmpty);
  });

  test('a question in the other language falls back to that language', () async {
    final hits = await _index().search(query: 'replay tape', languageCode: 'es');
    expect(hits, isNotEmpty);
    expect(hits.first.languageCode, 'en');
  });

  test('the limit is respected and a zero limit returns nothing', () async {
    expect(await _index().search(query: 'programa', languageCode: 'es', limit: 2), hasLength(2));
    expect(await _index().search(query: 'programa', languageCode: 'es', limit: 0), isEmpty);
  });

  test('the manual summary lists every entry with its route', () async {
    final summary = await _index().manualSummary('en');
    expect(summary, contains('- execution-options (/biblioteca/documento/:id): Run options'));
  });

  test('text folding and tokens ignore case, accents and one-letter words', () {
    expect(knowledgeTokens('Índice Á y PROGRAMACIÓN'), ['indice', 'programacion']);
    expect(foldKnowledgeText('Ñandú'), 'ñandu');
  });

  test('sheet sections become documents and empty sections are skipped', () {
    final documents = sheetDocuments('# T\n\n## Uno\n\ntexto\n\n## Vacío\n\n### `Dos`\n\nmás', 'es');
    expect([for (final document in documents) document.id], ['Uno', 'Dos']);
  });
}
