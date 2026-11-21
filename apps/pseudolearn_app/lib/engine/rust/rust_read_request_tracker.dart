import '../../domain/model/execution/read_request.dart';
import '../../domain/model/execution/read_value_type.dart';
import 'rust_read_statement.dart';
import 'rust_wire_models.dart';

final class RustReadRequestTracker {
  ReadRequest? _request;
  ReadRequest? _lastRequest;
  String? _nodeId;
  int _position = 0;
  bool _awaitingValue = false;
  String? _submitted;

  ReadRequest? get request => _request;

  void clear() {
    _request = null;
    _lastRequest = null;
    _nodeId = null;
    _position = 0;
    _awaitingValue = false;
    _submitted = null;
  }

  void submit(String text) {
    _request = null;
    _submitted = text;
  }

  void enter(RustEvent event) {
    if (event.nodeId != null && event.nodeId == _nodeId) _restart(event.nodeId);
  }

  ReadRequest open(RustEvent event, String statementSource, String? message) {
    if (event.nodeId != _nodeId) _restart(event.nodeId);
    final rejection = _awaitingValue
        ? ReadRejection(rejectedText: _submitted, message: message)
        : null;
    final statement = RustReadStatement.parse(statementSource);
    final request = ReadRequest(
      designator: statement.designatorAt(_position),
      valueType: ReadValueType.fromWireName(event.data['tipo']),
      line: event.line,
      statementText: statement.text,
      rejection: rejection,
    );
    _awaitingValue = true;
    _submitted = null;
    _request = request;
    _lastRequest = request;
    return request;
  }

  ReadRequest? receive() {
    final answered = _lastRequest;
    _position++;
    _awaitingValue = false;
    _submitted = null;
    _request = null;
    return answered;
  }

  void _restart(String? nodeId) {
    _nodeId = nodeId;
    _position = 0;
    _awaitingValue = false;
  }
}
