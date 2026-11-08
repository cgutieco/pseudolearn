import '../../domain/model/agent/agent_message.dart';
import '../../domain/model/agent/code_block.dart';

sealed class ReplySegment {
  const ReplySegment();
}

final class ReplyText extends ReplySegment {
  final String text;

  const ReplyText(this.text);
}

final class ReplyCode extends ReplySegment {
  final CheckedCodeBlock code;

  const ReplyCode(this.code);
}

const String specificationCitation = 'specification:';

List<ReplySegment> replySegments(AgentMessage message) {
  final segments = <ReplySegment>[];
  var cursor = 0;
  for (final code in message.codeBlocks) {
    final before = message.text.substring(cursor, code.block.start).trim();
    if (before.isNotEmpty) segments.add(ReplyText(before));
    segments.add(ReplyCode(code));
    cursor = code.block.end;
  }
  final rest = message.text.substring(cursor).trim();
  if (rest.isNotEmpty) segments.add(ReplyText(rest));
  return segments;
}

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
