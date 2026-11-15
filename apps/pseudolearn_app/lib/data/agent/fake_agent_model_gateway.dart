import '../../domain/model/agent/model_outcome.dart';
import '../../domain/model/agent/model_request.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/ports/agent_model_gateway.dart';

final class FakeAgentModelGateway implements AgentModelGateway {
  final List<ModelOutcome> _script;
  final List<ModelRequest> requests = [];
  final List<String> turnIds = [];

  FakeAgentModelGateway([List<ModelOutcome> script = const []]) : _script = [...script];

  void enqueue(ModelOutcome outcome) => _script.add(outcome);

  @override
  Future<ModelOutcome> respond(
    ModelRequest request, {
    required String requestId,
    required String turnId,
  }) async {
    requests.add(request);
    turnIds.add(turnId);
    if (_script.isEmpty) return const ModelFailed(CreditFailure.modelUnconfigured);
    return _script.removeAt(0);
  }
}
