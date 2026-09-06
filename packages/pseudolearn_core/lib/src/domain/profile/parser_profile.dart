import 'unsupported_construct.dart';

abstract interface class ParserProfile {
  bool get mandatoryStatementTerminator;

  bool get mandatoryStepInCountedLoop;

  Map<String, UnsupportedConstruct> get unsupportedConstructs;
}
