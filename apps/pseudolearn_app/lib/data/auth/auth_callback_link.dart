const String _scheme = 'pseudolearn';
const String _host = 'auth-callback';
const Set<String> _sessionTokenKeys = {'access_token', 'refresh_token'};

const String authCallbackUrl = '$_scheme://$_host';

bool isAuthCallbackLink(Uri link) =>
    link.scheme == _scheme && link.host == _host;

bool carriesSessionTokens(Uri link) {
  final fragmentKeys = Uri.splitQueryString(link.fragment).keys;
  return link.queryParameters.keys.any(_sessionTokenKeys.contains) ||
      fragmentKeys.any(_sessionTokenKeys.contains);
}
