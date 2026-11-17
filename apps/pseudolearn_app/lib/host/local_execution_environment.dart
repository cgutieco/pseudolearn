import 'package:path/path.dart' as p;

import '../domain/ports/execution_environment.dart';

final class LocalExecutionEnvironment implements ExecutionEnvironment {
  static const String _executionFolder = 'execution';
  static const String _folderNoEncodedIdentifierCanProduce = '%00';

  final String root;

  const LocalExecutionEnvironment(this.root);

  @override
  String directoryFor(String documentId) => p.join(root, _executionFolder, _singleSegmentNameFor(documentId));

  String _singleSegmentNameFor(String documentId) {
    final encoded = Uri.encodeComponent(documentId).replaceAll('.', '%2E');
    return encoded.isEmpty ? _folderNoEncodedIdentifierCanProduce : encoded;
  }
}
