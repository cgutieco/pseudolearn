final class CodeLanguage {
  final Set<String> keywords;
  final Set<String> types;
  final Set<String> constants;
  final List<String> lineComments;
  final String? blockCommentOpen;
  final String? blockCommentClose;
  final List<String> quotes;
  final bool caseInsensitive;
  final bool tagNames;

  const CodeLanguage({
    this.keywords = const {},
    this.types = const {},
    this.constants = const {},
    this.lineComments = const [],
    this.blockCommentOpen,
    this.blockCommentClose,
    this.quotes = const ['"', "'"],
    this.caseInsensitive = false,
    this.tagNames = false,
  });

  static const CodeLanguage plain = CodeLanguage(quotes: []);

  bool isKeyword(String word) => keywords.contains(_normalized(word));

  bool isType(String word) => types.contains(_normalized(word));

  bool isConstant(String word) => constants.contains(_normalized(word));

  String _normalized(String word) => caseInsensitive ? word.toLowerCase() : word;
}

Set<String> words(String list) => list.split(' ').where((word) => word.isNotEmpty).toSet();
