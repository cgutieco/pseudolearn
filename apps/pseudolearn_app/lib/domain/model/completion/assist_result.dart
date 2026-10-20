import 'package:equatable/equatable.dart';
import '../editor/caret_range.dart';

enum StopDirection { next, previous, exit }

final class AssistResult extends Equatable {
  final String sourceCode;
  final CaretRange selection;
  final bool templateActive;

  const AssistResult({
    required this.sourceCode,
    required this.selection,
    required this.templateActive,
  });

  @override
  List<Object?> get props => [sourceCode, selection, templateActive];
}
