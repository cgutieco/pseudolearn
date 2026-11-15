import 'package:pseudolearn_app/domain/ports/external_url_launcher.dart';

final class FakeExternalUrlLauncher implements ExternalUrlLauncher {
  final List<Uri> launchedUrls = [];
  bool shouldSucceed = true;

  @override
  Future<bool> launchExternalUrl(Uri url) async {
    if (!shouldSucceed) return false;
    launchedUrls.add(url);
    return true;
  }
}
