import '../../domain/model/execution/simulated_capabilities.dart';
import 'rust_simulated_host.dart';

Map<String, Object?>? replayHostDocument(SimulatedCapabilities capabilities) =>
    capabilities.hasHost
    ? RustSimulatedHost(capabilities).hostDocument()
    : null;
