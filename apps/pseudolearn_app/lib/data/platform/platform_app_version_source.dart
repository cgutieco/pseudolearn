import 'package:package_info_plus/package_info_plus.dart';
import '../../domain/ports/app_version_source.dart';

final class PlatformAppVersionSource implements AppVersionSource {
  const PlatformAppVersionSource();

  @override
  Future<String> read() async => (await PackageInfo.fromPlatform()).version;
}
