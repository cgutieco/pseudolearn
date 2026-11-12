import 'package:pseudolearn_app/domain/ports/demo_program_source.dart';

class FakeDemoProgramSource implements DemoProgramSource {
  final Map<String, String> programs;

  FakeDemoProgramSource({this.programs = const {}});

  @override
  Future<String> load(String fileName) async {
    final program = programs[fileName];
    if (program == null) throw StateError('missing demo $fileName');
    return program;
  }
}
