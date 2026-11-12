import 'dart:convert';
import '../../domain/model/agent/knowledge_hit.dart';
import 'knowledge_document.dart';

List<KnowledgeDocument> manualDocuments(String json, String languageCode) {
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  return [
    for (final entry in decoded['entries'] as List<dynamic>)
      KnowledgeDocument(
        source: KnowledgeSource.manual,
        id: (entry as Map<String, dynamic>)['id'] as String,
        title: entry['title'] as String,
        text: '${entry['body']} ${(entry['keywords'] as List<dynamic>).join(' ')}',
        languageCode: languageCode,
      ),
  ];
}

List<KnowledgeDocument> specificationDocuments(String json, String languageCode) {
  final titles = <String, String>{};
  final texts = <String, List<String>>{};
  for (final entry in jsonDecode(json) as List<dynamic>) {
    final map = entry as Map<String, dynamic>;
    final section = map['section'] as String;
    final text = map['text'] as String;
    if (map['kind'] == 'title') titles[section] = text;
    texts.putIfAbsent(section, () => []).add(text);
  }
  return [
    for (final section in texts.keys)
      KnowledgeDocument(
        source: KnowledgeSource.specification,
        id: section,
        title: titles[section] ?? section,
        text: texts[section]!.join('. '),
        languageCode: languageCode,
      ),
  ];
}

List<KnowledgeDocument> sheetDocuments(String markdown, String languageCode) {
  final documents = <KnowledgeDocument>[];
  String? heading;
  final body = StringBuffer();
  void flush() {
    final title = heading;
    if (title != null && body.toString().trim().isNotEmpty) {
      documents.add(KnowledgeDocument(
        source: KnowledgeSource.languageSheet,
        id: title,
        title: title,
        text: body.toString().trim(),
        languageCode: languageCode,
      ));
    }
    body.clear();
  }
  for (final line in const LineSplitter().convert(markdown)) {
    if (line.startsWith('## ') || line.startsWith('### ')) {
      flush();
      heading = line.replaceFirst(RegExp(r'^#+ '), '').replaceAll('`', '');
    } else {
      body.writeln(line);
    }
  }
  flush();
  return documents;
}
