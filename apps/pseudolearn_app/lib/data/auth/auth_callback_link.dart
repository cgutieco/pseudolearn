const String _scheme = 'pseudolearn';
const String _host = 'auth-callback';

const String authCallbackUrl = '$_scheme://$_host';

bool isAuthCallbackLink(Uri link) =>
    link.scheme == _scheme && link.host == _host;
