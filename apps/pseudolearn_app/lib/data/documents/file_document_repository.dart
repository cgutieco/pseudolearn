import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/model/documents/document.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/document_repository.dart';
import '../index/index_rebuild.dart';
import '../index/metadata_index.dart';

Document? parseDocumentFile(File file) {
  try {
    final raw = file.readAsStringSync();
    final headerAndBody = _extractHeaderAndBody(raw);
    if (headerAndBody == null) return null;
    return _buildDocumentFromHeader(headerAndBody.$1, headerAndBody.$2);
  } catch (_) {
    return null;
  }
}

(String, String)? _extractHeaderAndBody(String raw) {
  const separator = '---';
  if (!raw.startsWith(separator)) return null;
  final secondIndex = raw.indexOf(separator, separator.length);
  if (secondIndex == -1) return null;

  final headerText = raw.substring(separator.length, secondIndex).trim();
  var bodyText = raw.substring(secondIndex + separator.length);
  if (bodyText.startsWith('\r\n')) {
    bodyText = bodyText.substring(2);
  } else if (bodyText.startsWith('\n')) {
    bodyText = bodyText.substring(1);
  }
  return (headerText, bodyText);
}

Document? _buildDocumentFromHeader(String headerText, String bodyText) {
  final map = _parseHeaderLines(headerText);
  final id = map['id'];
  final title = map['title'];
  final profileName = map['profile'];
  if (id == null || title == null || profileName == null) return null;

  final profileId = SyntaxProfileId.values.firstWhere(
    (p) => p.name == profileName,
    orElse: () => SyntaxProfileId.classicSpanish,
  );
  return Document(
    id: id,
    title: title,
    content: bodyText,
    profileId: profileId,
    revision: int.tryParse(map['revision'] ?? '1') ?? 1,
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    exerciseId: map['exercise_id'],
  );
}

Map<String, String> _parseHeaderLines(String headerText) {
  final map = <String, String>{};
  for (final line in headerText.split('\n')) {
    final colon = line.indexOf(':');
    if (colon != -1) {
      map[line.substring(0, colon).trim()] = line.substring(colon + 1).trim();
    }
  }
  return map;
}

String serializeDocumentFile(Document doc) {
  final buffer = StringBuffer();
  buffer.writeln('---');
  buffer.writeln('id: ${doc.id}');
  buffer.writeln('title: ${doc.title}');
  buffer.writeln('profile: ${doc.profileId.name}');
  buffer.writeln('revision: ${doc.revision}');
  buffer.writeln('created_at: ${doc.createdAt.toIso8601String()}');
  buffer.writeln('updated_at: ${doc.updatedAt.toIso8601String()}');
  if (doc.exerciseId != null) {
    buffer.writeln('exercise_id: ${doc.exerciseId}');
  }
  buffer.writeln('---');
  buffer.write(doc.content);
  return buffer.toString();
}

final class FileDocumentRepository implements DocumentRepository {
  final Directory directory;
  final MetadataIndex index;

  const FileDocumentRepository({
    required this.directory,
    required this.index,
  });

  @override
  Future<List<DocumentSummary>> listDocuments() async {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return index.listAll();
  }

  @override
  Future<Document?> loadDocument(String id) async {
    final file = File(p.join(directory.path, '$id.pseudo'));
    if (!file.existsSync()) {
      await index.markDeleted(id);
      return null;
    }
    return parseDocumentFile(file);
  }

  @override
  Future<Document> saveDocument(Document document) async {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final file = File(p.join(directory.path, '${document.id}.pseudo'));
    final content = serializeDocumentFile(document);
    final tempFile = File('${file.path}.tmp');
    tempFile.writeAsStringSync(content, flush: true);
    tempFile.renameSync(file.path);

    await index.upsert(document.toSummary());
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    final file = File(p.join(directory.path, '$id.pseudo'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    await index.markDeleted(id);
  }

  @override
  Future<void> rebuildIndex() async {
    await rebuildMetadataIndex(directory: directory, index: index);
  }
}
