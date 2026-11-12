import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../library/use_cases/create_document.dart';
import '../../library/use_cases/delete_document.dart';
import '../../library/use_cases/rename_document.dart';
import '../../library/use_cases/set_execution_arguments.dart';
import 'agent_tool.dart';
import 'program_payloads.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

ToolExecution documentResult(DocumentCommandResult result) => switch (result) {
  DocumentCommandSucceeded(:final document) =>
    ToolExecution.done(summaryPayload(document.toSummary()), summary: document.title),
  DocumentCommandRejected(:final failure) => ToolExecution.failed(failure.name),
};

final class CreateDocumentTool extends DirectTool {
  final CreateDocument _create;

  const CreateDocumentTool(this._create);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'create_document',
    description: 'Creates a new algorithm in the Library. Titles must be unique.',
    parameters: objectSchema({
      'title': stringProperty('Unique title.'),
      'profile': stringProperty('Syntax profile.', values: profileNames),
      'content': stringProperty('Initial source; check it first with check_program.'),
    }, required: const ['title', 'profile']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepCreateDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final title = arguments.text('title');
    final profile = arguments.profile('profile');
    if (title == null || profile == null) return ToolExecution.failed('invalid_arguments');
    return documentResult(await _create(CreateDocumentCommand(
      title: title,
      profileId: profile,
      content: arguments.text('content') ?? '',
    )));
  }
}

final class RenameDocumentTool extends DirectTool {
  final RenameDocument _rename;

  const RenameDocumentTool(this._rename);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'rename_document',
    description: 'Renames an algorithm.',
    parameters: objectSchema({
      'document_id': stringProperty('Document id.'),
      'title': stringProperty('New unique title.'),
    }, required: const ['document_id', 'title']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepRenameDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    final title = arguments.text('title');
    if (id == null || title == null) return ToolExecution.failed('invalid_arguments');
    return documentResult(await _rename(documentId: id, title: title));
  }
}

final class DeleteDocumentTool extends ConfirmedTool {
  final DeleteDocument _delete;

  const DeleteDocumentTool(this._delete);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'delete_document',
    description: 'Deletes an algorithm. The person always confirms first.',
    parameters: objectSchema({'document_id': stringProperty('Document id.')}, required: const ['document_id']),
    risk: ToolRisk.destructive,
    stepLabel: 'agentStepDeleteDocument',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    if (id == null) return ToolExecution.failed('invalid_arguments');
    return await _delete(id)
        ? ToolExecution.done({'deleted': id}, summary: id)
        : ToolExecution.failed('storage_failed');
  }
}

final class SetExecutionArgumentsTool extends DirectTool {
  final SetExecutionArguments _set;

  const SetExecutionArgumentsTool(this._set);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'set_execution_arguments',
    description: 'Stores the program arguments of an algorithm, as in its run options.',
    parameters: objectSchema({
      'document_id': stringProperty('Document id.'),
      'arguments': stringListProperty('Arguments in order; empty list clears them.'),
    }, required: const ['document_id', 'arguments']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepArguments',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    final values = arguments.texts('arguments');
    if (id == null || values == null) return ToolExecution.failed('invalid_arguments');
    return documentResult(await _set(documentId: id, arguments: values));
  }
}
