import 'package:url_launcher/url_launcher.dart' as ul;

import '../../domain/ports/external_url_launcher.dart';

final class PlatformExternalUrlLauncher implements ExternalUrlLauncher {
  const PlatformExternalUrlLauncher();

  @override
  Future<bool> launchExternalUrl(Uri url) {
    return ul.launchUrl(url, mode: ul.LaunchMode.externalApplication);
  }
}
