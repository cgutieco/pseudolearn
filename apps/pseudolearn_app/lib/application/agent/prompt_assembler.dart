import 'dart:convert';
import '../../domain/model/agent/model_item.dart';
import '../../domain/model/agent/model_request.dart';
import '../../domain/model/agent/screen_context_snapshot.dart';
import '../../domain/model/agent/tool_definition.dart';
import '../../domain/ports/agent_prompt_source.dart';
import '../../domain/ports/knowledge_index.dart';
import '../../domain/ports/screen_context_source.dart';

final class PromptAssembler {
  final AgentPromptSource _prompts;
  final KnowledgeIndex _knowledge;
  final ScreenContextSource _screen;
  final AmbientContext Function() _ambient;
  final Map<String, Future<String>> _stableParts = {};

  PromptAssembler({
    required AgentPromptSource prompts,
    required KnowledgeIndex knowledge,
    required ScreenContextSource screen,
    required AmbientContext Function() ambient,
  }) : _prompts = prompts,
       _knowledge = knowledge,
       _screen = screen,
       _ambient = ambient;

  Future<ModelRequest> build(List<ModelItem> history, List<ToolDefinition> tools) async {
    final ambient = _ambient();
    final stable = await _stableParts.putIfAbsent(
      ambient.interfaceLanguage,
      () => _stable(ambient.interfaceLanguage),
    );
    return ModelRequest(
      instructions: '$stable\n\n${_dynamic(ambient)}',
      input: history,
      tools: tools,
    );
  }

  Future<String> _stable(String languageCode) async {
    final system = await _prompts.systemPrompt(languageCode);
    final sheet = await _prompts.languageSheet(languageCode);
    final manual = await _knowledge.manualSummary(languageCode);
    return '$system\n\n# Language sheet\n\n$sheet\n\n# App manual index\n\n$manual';
  }

  String _dynamic(AmbientContext ambient) {
    final snapshot = _screen.snapshot();
    return '# Current context\n\n${jsonEncode({
      'interface_language': ambient.interfaceLanguage,
      'default_profile': ambient.defaultProfile,
      'date': ambient.date.toIso8601String().substring(0, 10),
      'platform': ambient.platform,
      'screen': snapshot.screen,
      'route': snapshot.route,
      'screen_fields': snapshot.fields,
    })}';
  }
}
