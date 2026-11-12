const String specificationCitation = 'specification:';

List<String> citedSpecificationSections(String text) {
  final sections = <String>{};
  var from = text.indexOf(specificationCitation);
  while (from >= 0) {
    final start = from + specificationCitation.length;
    var end = start;
    while (end < text.length && _isSectionCharacter(text.codeUnitAt(end))) {
      end += 1;
    }
    final section = _trimmed(text.substring(start, end));
    if (section.isNotEmpty) sections.add(section);
    from = text.indexOf(specificationCitation, end);
  }
  return sections.toList();
}

bool _isSectionCharacter(int unit) =>
    (unit >= 0x61 && unit <= 0x7A) || (unit >= 0x30 && unit <= 0x39) || unit == 0x2E || unit == 0x2D;

String _trimmed(String section) =>
    section.endsWith('.') ? section.substring(0, section.length - 1) : section;
