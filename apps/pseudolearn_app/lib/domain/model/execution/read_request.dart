import 'read_value_type.dart';

final class ReadRejection {
  final String? rejectedText;
  final String? message;

  const ReadRejection({this.rejectedText, this.message});
}

final class ReadRequest {
  final String designator;
  final ReadValueType? valueType;
  final int line;
  final String statementText;
  final ReadRejection? rejection;

  const ReadRequest({
    required this.designator,
    required this.line,
    required this.statementText,
    this.valueType,
    this.rejection,
  });
}
