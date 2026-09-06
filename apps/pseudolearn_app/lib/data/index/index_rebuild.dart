import 'dart:io';
import '../documents/file_document_repository.dart';
import 'index_schema.dart';
import 'metadata_index.dart';

Future<void> rebuildMetadataIndex({
  required Directory directory,
  required MetadataIndex index,
}) async {
  if (!directory.existsSync()) return;

  await IndexSchema.clear(index.database);
  final entities = directory.listSync();
  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.pseudo')) {
      final doc = parseDocumentFile(entity);
      if (doc != null) {
        await index.upsert(doc.toSummary());
      }
    }
  }
}
