import '../../domain/span.dart';
import '../../semantic/symbols/symbol.dart';
import 'object_instance.dart';
import 'runtime_scope.dart';

final class CallFrame {
  final RuntimeScope scope;
  final String subroutineName;
  final Span? callSpan;
  final ObjectInstance? receiver;
  final ClassSymbol? currentClass;

  CallFrame({
    required this.subroutineName,
    this.callSpan,
    this.receiver,
    this.currentClass,
  }) : scope = RuntimeScope();
}
