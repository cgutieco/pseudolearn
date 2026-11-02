import 'simulated_capabilities.dart';

enum SimulatedScenario {
  noHost,
  noPermissions,
  virtualFiles,
  preparedHttp,
  logicalTime,
  timeout,
  uncertainResult;

  SimulatedCapabilities get capabilities => configurations[this]!;

  static const Map<SimulatedScenario, SimulatedCapabilities> configurations = {
    SimulatedScenario.noHost: SimulatedCapabilities.none,
    SimulatedScenario.noPermissions: SimulatedCapabilities(hostEnabled: true),
    SimulatedScenario.virtualFiles: SimulatedCapabilities(
      permissions: {'archivos_lectura'},
      files: {
        'datos.txt': [80, 115, 101, 117, 100, 111, 76, 101, 97, 114, 110],
      },
      hostEnabled: true,
    ),
    SimulatedScenario.preparedHttp: SimulatedCapabilities(
      permissions: {'red'},
      networkOrigins: {'https://example.test'},
      httpResponses: {
        'GET https://example.test/greeting': SimulatedHttpResponse(
          status: 200,
          headers: {'content-type': 'text/plain; charset=utf-8'},
          body: [104, 111, 108, 97],
        ),
      },
      hostEnabled: true,
    ),
    SimulatedScenario.logicalTime: SimulatedCapabilities(
      permissions: {'reloj', 'temporizador'},
      clockStartNanos: 1_000_000_000,
      hostEnabled: true,
    ),
    SimulatedScenario.timeout: SimulatedCapabilities(
      permissions: {'temporizador'},
      failures: {'timer_wait': SimulatedEffectFailure('tiempo_agotado')},
      hostEnabled: true,
    ),
    SimulatedScenario.uncertainResult: SimulatedCapabilities(
      permissions: {'red'},
      networkOrigins: {'https://example.test'},
      failures: {
        'POST https://example.test/update': SimulatedEffectFailure(
          'interrumpido',
          uncertain: true,
        ),
      },
      hostEnabled: true,
    ),
  };
}
