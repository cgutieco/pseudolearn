import 'package:pseudolearn_app/domain/ports/app_version_source.dart';

final class FakeAppVersionSource implements AppVersionSource {
  final String version;

  const FakeAppVersionSource({this.version = '1.1.0'});

  @override
  Future<String> read() async => version;
}
