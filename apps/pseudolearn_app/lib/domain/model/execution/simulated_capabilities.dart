final class SimulatedCapabilities {
  static const SimulatedCapabilities none = SimulatedCapabilities();

  final Set<String> permissions;
  final Map<String, List<int>> files;
  final List<String> arguments;
  final int clockStartNanos;
  final Set<String> networkOrigins;
  final Map<String, SimulatedHttpResponse> httpResponses;
  final Map<String, SimulatedEffectFailure> failures;
  final bool hostEnabled;

  const SimulatedCapabilities({
    this.permissions = const {},
    this.files = const {},
    this.arguments = const [],
    this.clockStartNanos = 0,
    this.networkOrigins = const {},
    this.httpResponses = const {},
    this.failures = const {},
    this.hostEnabled = false,
  });

  bool get hasHost => hostEnabled || permissions.isNotEmpty;
}

final class SimulatedHttpResponse {
  final int status;
  final Map<String, String> headers;
  final List<int> body;

  const SimulatedHttpResponse({
    required this.status,
    this.headers = const {},
    this.body = const [],
  });
}

final class SimulatedEffectFailure {
  final String code;
  final bool uncertain;

  const SimulatedEffectFailure(this.code, {this.uncertain = false});
}
