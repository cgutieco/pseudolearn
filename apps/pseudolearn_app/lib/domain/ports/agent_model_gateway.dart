import '../model/agent/model_outcome.dart';
import '../model/agent/model_request.dart';

abstract interface class AgentModelGateway {
  Future<ModelOutcome> respond(
    ModelRequest request, {
    required String requestId,
    required String turnId,
  });
}
