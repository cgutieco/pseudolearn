import 'reference_token.dart';

sealed class ReferenceRun {
  const ReferenceRun();

  String get plainText;
}

final class ReferenceTextRun extends ReferenceRun {
  final String text;
  final ReferenceEmphasis emphasis;

  const ReferenceTextRun(this.text, {this.emphasis = ReferenceEmphasis.none});

  @override
  String get plainText => text;
}

enum ReferenceEmphasis { none, strong, italic }

final class ReferenceCodeRun extends ReferenceRun {
  final List<ReferenceToken> tokens;

  const ReferenceCodeRun(this.tokens);

  @override
  String get plainText => tokens.map((token) => token.text).join();
}

final class ReferenceSlotRun extends ReferenceRun {
  final String text;

  const ReferenceSlotRun(this.text);

  @override
  String get plainText => text;
}

final class ReferenceLinkRun extends ReferenceRun {
  final String sectionId;
  final String text;

  const ReferenceLinkRun({required this.sectionId, required this.text});

  @override
  String get plainText => text;
}

final class ReferenceTermRun extends ReferenceRun {
  final String term;
  final String text;

  const ReferenceTermRun({required this.term, required this.text});

  @override
  String get plainText => text;
}

final class ReferenceDefinitionRun extends ReferenceRun {
  final String term;
  final String text;

  const ReferenceDefinitionRun({required this.term, required this.text});

  @override
  String get plainText => text;
}

final class ReferenceSpecLinkRun extends ReferenceRun {
  final String sectionId;
  final String? anchor;
  final String text;

  const ReferenceSpecLinkRun({
    required this.sectionId,
    required this.text,
    this.anchor,
  });

  @override
  String get plainText => text;
}

final class ReferenceLessonLinkRun extends ReferenceRun {
  final String lessonId;
  final String text;

  const ReferenceLessonLinkRun({required this.lessonId, required this.text});

  @override
  String get plainText => text;
}

String plainTextOf(List<ReferenceRun> runs) =>
    runs.map((run) => run.plainText).join();
