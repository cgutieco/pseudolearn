import 'dart:io';

const _retiredHostMarkers = [
  'SimulatedScenario',
  'SimulatedCapabilities',
  'RustSimulatedHost',
  'simulatedScenario',
  'simulated_',
];

List<String> validateExecutionHostSource(String source, String path) => [
  for (final marker in _retiredHostMarkers)
    if (source.contains(marker)) 'APP-HOST-REAL: $path contains $marker',
];

Future<List<String>> validateExecutionHostDirectory(Directory directory) async {
  final errors = <String>[];
  await for (final entry in directory.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entry is! File ||
        (!entry.path.endsWith('.dart') && !entry.path.endsWith('.arb'))) {
      continue;
    }
    errors.addAll(
      validateExecutionHostSource(await entry.readAsString(), entry.path),
    );
  }
  return errors;
}
