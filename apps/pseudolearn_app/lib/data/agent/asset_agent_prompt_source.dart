import '../../domain/ports/agent_prompt_source.dart';

typedef AgentAssetLoader = Future<String> Function(String path);

final class AssetAgentPromptSource implements AgentPromptSource {
  final AgentAssetLoader _loader;

  const AssetAgentPromptSource(this._loader);

  @override
  Future<String> systemPrompt(String languageCode) =>
      _loader('assets/agent/${_code(languageCode)}/system-prompt.md');

  @override
  Future<String> languageSheet(String languageCode) =>
      _loader('assets/agent/${_code(languageCode)}/language-sheet.md');

  String _code(String languageCode) => languageCode == 'en' ? 'en' : 'es';
}
