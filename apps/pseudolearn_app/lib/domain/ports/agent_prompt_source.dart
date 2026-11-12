abstract interface class AgentPromptSource {
  Future<String> systemPrompt(String languageCode);
  Future<String> languageSheet(String languageCode);
}
