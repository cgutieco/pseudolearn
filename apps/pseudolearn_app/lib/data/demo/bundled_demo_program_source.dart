import '../../domain/ports/demo_program_source.dart';
import '../reference/bundled_reference_repository.dart';

const String demoAssetRoot = 'assets/demo/';

final class BundledDemoProgramSource implements DemoProgramSource {
  final ReferenceAssetLoader _assetLoader;

  const BundledDemoProgramSource({required ReferenceAssetLoader assetLoader})
    : _assetLoader = assetLoader;

  @override
  Future<String> load(String fileName) => _assetLoader('$demoAssetRoot$fileName');
}
