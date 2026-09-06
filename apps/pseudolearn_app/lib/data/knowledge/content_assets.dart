final class ContentAssets {
  final Map<String, String> exampleSources;
  final Map<String, String> exampleTitles;
  final Map<String, String> illustrationTitles;

  const ContentAssets({
    this.exampleSources = const {},
    this.exampleTitles = const {},
    this.illustrationTitles = const {},
  });

  static const ContentAssets none = ContentAssets();
}
