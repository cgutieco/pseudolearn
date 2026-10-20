import 'package:equatable/equatable.dart';
import 'caret_range.dart';

final class SourceEdit extends Equatable {
  final String sourceCode;
  final CaretRange caret;
  final int revision;
  final bool templateActive;

  const SourceEdit({
    required this.sourceCode,
    required this.caret,
    required this.revision,
    this.templateActive = false,
  });

  @override
  List<Object?> get props => [sourceCode, caret, revision, templateActive];
}
