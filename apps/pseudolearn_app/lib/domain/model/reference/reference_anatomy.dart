import 'reference_run.dart';
import 'reference_token.dart';

final class ReferenceAnatomyPart {
  final List<ReferenceToken> tokens;
  final List<ReferenceRun> label;

  const ReferenceAnatomyPart({required this.tokens, required this.label});
}
