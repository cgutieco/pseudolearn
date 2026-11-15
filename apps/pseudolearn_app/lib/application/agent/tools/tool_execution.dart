import 'dart:convert';

final class ToolExecution {
  final Map<String, Object?> output;
  final bool succeeded;
  final String summary;

  const ToolExecution.done(this.output, {this.summary = ''}) : succeeded = true;

  ToolExecution.failed(String code, {String detail = ''})
    : output = {'error': code, if (detail.isNotEmpty) 'detail': detail},
      succeeded = false,
      summary = code;

  String encoded() => jsonEncode({'ok': succeeded, ...output});
}
