import 'package:equatable/equatable.dart';

final class CaretRange extends Equatable {
  final int start;
  final int end;

  const CaretRange({required this.start, required this.end});

  const CaretRange.collapsed(int offset)
      : start = offset,
        end = offset;

  bool get isCollapsed => start == end;

  int get lower => start <= end ? start : end;

  int get upper => start <= end ? end : start;

  CaretRange clampedTo(int length) => CaretRange(
        start: lower.clamp(0, length),
        end: upper.clamp(0, length),
      );

  @override
  List<Object?> get props => [start, end];
}
