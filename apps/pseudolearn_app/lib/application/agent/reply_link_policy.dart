import '../../domain/ports/external_url_launcher.dart';

const Set<String> _openableSchemes = {'https', 'http'};

Uri? openableReplyLink(String? target) {
  if (target == null) return null;
  final uri = Uri.tryParse(target.trim());
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
  if (!_openableSchemes.contains(uri.scheme.toLowerCase())) return null;
  if (uri.userInfo.isNotEmpty) return null;
  return uri;
}

final class ReplyLinkOpener {
  final ExternalUrlLauncher _launcher;

  const ReplyLinkOpener(this._launcher);

  bool canOpen(String? target) => openableReplyLink(target) != null;

  Future<bool> open(String? target) async {
    final link = openableReplyLink(target);
    if (link == null) return false;
    return _launcher.launchExternalUrl(link);
  }
}
