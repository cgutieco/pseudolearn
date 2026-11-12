import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../library/use_cases/list_documents.dart';
import '../../library/use_cases/load_document.dart';
import 'agent_tool.dart';
import 'program_payloads.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class ListDocumentsTool extends DirectTool {
  final ListDocuments _list;

  const ListDocumentsTool(this._list);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'list_documents',
    description: 'Lists the algorithms in the Library with id, title, profile and linked exercise.',
    parameters: objectSchema(const {}),
    risk: ToolRisk.read,
    stepLabel: 'agentStepListDocuments',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final documents = await _list();
    if (documents == null) return ToolExecution.failed('storage_failed');
    return ToolExecution.done({
      'documents': [for (final document in documents) summaryPayload(document)],
    }, summary: '${documents.length}');
  }
}

final class GetDocumentTool extends DirectTool {
  final LoadDocument _load;

  const GetDocumentTool(this._load);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'get_document',
    description: 'Returns one algorithm with its full source, profile and run arguments.',
    parameters: objectSchema({
      'document_id': stringProperty('Id from list_documents or the screen context.'),
    }, required: const ['document_id']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepReadDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    if (id == null) return ToolExecution.failed('invalid_arguments', detail: 'document_id');
    return switch (await _load(id)) {
      DocumentCommandSucceeded(:final document) => ToolExecution.done(documentPayload(document)),
      DocumentCommandRejected(:final failure) => ToolExecution.failed(failure.name),
    };
  }
}
