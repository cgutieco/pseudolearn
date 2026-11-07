import 'reference_token.dart';

sealed class ReferenceFormSegment {
  const ReferenceFormSegment();
}

final class ReferenceFormToken extends ReferenceFormSegment {
  final ReferenceToken token;

  const ReferenceFormToken(this.token);
}

final class ReferenceFormSlot extends ReferenceFormSegment {
  final String label;

  const ReferenceFormSlot(this.label);
}

final class ReferenceFormOptional extends ReferenceFormSegment {
  final String mark;

  const ReferenceFormOptional(this.mark);
}
