import 'package:equatable/equatable.dart';

enum HelpFormSegmentKind { word, symbol, slot, ellipsis }

final class HelpFormSegment extends Equatable {
  final HelpFormSegmentKind kind;
  final String text;
  final bool joined;

  const HelpFormSegment({
    required this.kind,
    required this.text,
    this.joined = false,
  });

  @override
  List<Object?> get props => [kind, text, joined];
}

final class HelpFormLine extends Equatable {
  final int indent;
  final List<HelpFormSegment> segments;

  const HelpFormLine({required this.indent, required this.segments});

  @override
  List<Object?> get props => [indent, segments];
}
