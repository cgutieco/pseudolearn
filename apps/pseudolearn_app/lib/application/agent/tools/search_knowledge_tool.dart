import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/ports/knowledge_index.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class SearchKnowledgeTool extends DirectTool {
  final KnowledgeIndex _index;
  final String Function() _languageCode;

  const SearchKnowledgeTool(this._index, this._languageCode);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'search_knowledge',
    description:
        'Searches the app manual, the language specification and the language sheet. Cite the '
        'returned citation when you use a result.',
    parameters: objectSchema({
      'query': stringProperty('Words to search for.'),
      'limit': integerProperty('Maximum results, 1 to 8.'),
    }, required: const ['query']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepSearch',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final query = arguments.text('query');
    if (query == null) return ToolExecution.failed('invalid_arguments', detail: 'query');
    final limit = (arguments.integer('limit') ?? 5).clamp(1, 8);
    final hits = await _index.search(query: query, languageCode: _languageCode(), limit: limit);
    return ToolExecution.done({
      'results': [
        for (final hit in hits)
          {'citation': hit.citation, 'title': hit.title, 'excerpt': hit.excerpt, 'language': hit.languageCode},
      ],
    }, summary: '${hits.length}');
  }
}
