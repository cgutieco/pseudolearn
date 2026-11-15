enum TargetLanguageId {
  python('python', 'Python'),
  rust('rust', 'Rust');

  final String id;
  final String displayName;

  const TargetLanguageId(this.id, this.displayName);

  static TargetLanguageId fromId(String id) {
    return TargetLanguageId.values.firstWhere(
      (lang) => lang.id == id,
      orElse: () => TargetLanguageId.python,
    );
  }
}
