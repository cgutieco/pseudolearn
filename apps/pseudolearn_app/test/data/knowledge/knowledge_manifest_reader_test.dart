import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/knowledge_manifest_reader.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

const String _manifest = '''
{
  "manifestVersion": 2,
  "contentVersion": 1,
  "modules": [
    {
      "id": "CON-B1",
      "track": "B",
      "order": 1,
      "title": "Datos",
      "summary": "Tipos y variables.",
      "path": "modules/CON-B1_es.md"
    }
  ],
  "specification": [
    {
      "id": "esp-i-datos",
      "document": "esp-i",
      "anchor": "datos",
      "order": 1,
      "title": "Datos",
      "summary": "Tipos, operadores y asignacion.",
      "path": "specification/esp-i-datos_es.md"
    }
  ],
  "exercises": [
    {
      "id": "CON-B1-E1",
      "level": 1,
      "kind": "crear",
      "module": "CON-B1",
      "title": "Cuadrado",
      "summary": "Escribe el cuadrado.",
      "path": "exercises/CON-B1-E1_es.json"
    }
  ],
  "examples": [
    {
      "id": "example-sum",
      "title": "Suma",
      "summary": "Suma dos valores.",
      "path": "examples/sum_es.pseudo",
      "profile": "classic_spanish"
    }
  ],
  "support": [
    {
      "id": "contact-support",
      "title": "Contacto",
      "summary": "Canales de asistencia.",
      "path": "support/contact_es.md"
    }
  ]
}
''';

List<KnowledgeEntry> _entriesOf(String source) {
  final result = const KnowledgeManifestReader().read(source);
  return (result as ContentLoaded<List<KnowledgeEntry>>).value;
}

void main() {
  group('KnowledgeManifestReader', () {
    test('reads every declared section into typed entries', () {
      final entries = _entriesOf(_manifest);

      expect(entries.length, 5);
      expect(entries[0].type, KnowledgeEntryType.module);
      expect(entries[0].track, LearningTrack.imperative);
      expect(entries[0].order, 1);
      expect(entries[1].type, KnowledgeEntryType.specificationSection);
      expect(entries[2].type, KnowledgeEntryType.exercise);
      expect(entries[2].level, ExerciseLevel.reproduce);
      expect(entries[2].moduleId, 'CON-B1');
      expect(entries[3].type, KnowledgeEntryType.example);
      expect(entries[3].profileId, SyntaxProfileId.classicSpanish);
      expect(entries[4].type, KnowledgeEntryType.contact);
    });

    test('the route order is a datum of the manifest, not of the file name', () {
      const outOfOrder = '''
{
  "manifestVersion": 2,
  "modules": [
    {"id": "CON-B2", "track": "B", "order": 2, "title": "Entrada", "summary": "", "path": "a.md"},
    {"id": "CON-B1", "track": "B", "order": 1, "title": "Datos", "summary": "", "path": "b.md"}
  ]
}
''';
      final entries = _entriesOf(outOfOrder);

      expect(entries.map((e) => e.order).toList(), [2, 1]);
    });

    test('a manifest of another version is a named failure', () {
      final result = const KnowledgeManifestReader().read(
        '{"manifestVersion": 1, "entries": []}',
      );

      expect(result, isA<ContentLoadFailed<List<KnowledgeEntry>>>());
      expect(
        (result as ContentLoadFailed<List<KnowledgeEntry>>).failure,
        ContentLoadFailure.unsupportedManifestVersion,
      );
    });

    test('a manifest that is not valid json is a named failure, never an exception', () {
      final result = const KnowledgeManifestReader().read('{ not json');

      expect(
        (result as ContentLoadFailed<List<KnowledgeEntry>>).failure,
        ContentLoadFailure.malformedManifest,
      );
    });

    test('a section that is not a list is a named failure', () {
      final result = const KnowledgeManifestReader().read(
        '{"manifestVersion": 2, "modules": {"id": "CON-B1"}}',
      );

      expect(
        (result as ContentLoadFailed<List<KnowledgeEntry>>).failure,
        ContentLoadFailure.malformedManifest,
      );
      expect(result.detail, 'modules');
    });

    test('an empty manifest is valid and yields no entries', () {
      expect(_entriesOf('{"manifestVersion": 2}'), isEmpty);
      expect(_entriesOf('{"manifestVersion": 2, "modules": []}'), isEmpty);
    });

    test('an unknown level leaves the entry without a level instead of failing', () {
      final entries = _entriesOf(
        '{"manifestVersion": 2, "exercises": [{"id": "E", "level": 9, "title": "t", "summary": ""}]}',
      );

      expect(entries.single.level, isNull);
    });
  });
}
