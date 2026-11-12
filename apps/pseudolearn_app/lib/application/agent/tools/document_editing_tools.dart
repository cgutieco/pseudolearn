import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/documents/document.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../library/use_cases/load_document.dart';
import '../../library/use_cases/save_document_source.dart';
import '../../program/use_cases/check_program.dart';
import 'agent_tool.dart';
import 'program_payloads.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class DocumentSourceWriter {
  final LoadDocument _load;
  final SaveDocumentSource _save;
  final CheckProgram _check;
  final UiLanguageId Function() _language;

  const DocumentSourceWriter({
    required this._load,
    required this._save,
    required this._check,
    required this._language,
  });

  Future<Document?> load(String id) async {
    final result = await _load(id);
    return result is DocumentCommandSucceeded ? result.document : null;
  }

  Future<ToolExecution> write(Document document, String source) async {
    final result = await _save(document: document, sourceCode: source);
    if (result is! DocumentCommandSucceeded) return ToolExecution.failed('storage_failed');
    final report = _check(sourceCode: source, profileId: document.profileId, languageId: _language());
    return ToolExecution.done({
      'document_id': document.id,
      'revision': result.document.revision,
      ...diagnosticsPayload(report),
    }, summary: document.title);
  }
}

final class EditDocumentTool extends DirectTool {
  final DocumentSourceWriter _writer;

  const EditDocumentTool(this._writer);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'edit_document',
    description:
        'Edits part of an algorithm: either replaces old_text (which must appear exactly once) with '
        'new_text, or inserts new_text at offset. Returns the new diagnostics.',
    parameters: objectSchema({
      'document_id': stringProperty('Document id.'),
      'old_text': stringProperty('Exact text to replace.'),
      'new_text': stringProperty('Replacement or inserted text.'),
      'offset': integerProperty('UTF-16 offset for an insertion when old_text is absent.'),
    }, required: const ['document_id', 'new_text']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepEditDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    final replacement = arguments.text('new_text');
    if (id == null || replacement == null) return ToolExecution.failed('invalid_arguments');
    final document = await _writer.load(id);
    if (document == null) return ToolExecution.failed('notFound');
    final edited = _edited(document.content, arguments, replacement);
    if (edited == null) return ToolExecution.failed('edit_not_applicable');
    return _writer.write(document, edited);
  }

  String? _edited(String content, ToolArguments arguments, String replacement) {
    final old = arguments.text('old_text');
    if (old != null && old.isNotEmpty) {
      final first = content.indexOf(old);
      if (first < 0 || content.indexOf(old, first + 1) >= 0) return null;
      return content.replaceRange(first, first + old.length, replacement);
    }
    final offset = arguments.integer('offset');
    if (offset == null || offset < 0 || offset > content.length) return null;
    return content.replaceRange(offset, offset, replacement);
  }
}

final class ReplaceDocumentContentTool extends ConfirmedTool {
  final DocumentSourceWriter _writer;

  const ReplaceDocumentContentTool(this._writer);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'replace_document_content',
    description: 'Replaces the whole source of an algorithm. The person always confirms first.',
    parameters: objectSchema({
      'document_id': stringProperty('Document id.'),
      'content': stringProperty('Complete new source, already checked.'),
    }, required: const ['document_id', 'content']),
    risk: ToolRisk.destructive,
    stepLabel: 'agentStepReplaceDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    final content = arguments.text('content');
    if (id == null || content == null) return ToolExecution.failed('invalid_arguments');
    final document = await _writer.load(id);
    if (document == null) return ToolExecution.failed('notFound');
    return _writer.write(document, content);
  }
}
