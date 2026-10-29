use crate::{HttpMethod, HttpRequestValue, HttpResponseValue, IoError};
use pseudolearn_abi::IoErrorKind;

pub fn redirect_request(
    request: &HttpRequestValue,
    response: &HttpResponseValue,
) -> Result<HttpRequestValue, IoError> {
    if !matches!(response.status, 301 | 302 | 303 | 307 | 308) {
        return Err(redirect_denied());
    }
    let location = unique_location(&response.headers)?;
    let target = resolve_location(&response.final_url, location)?;
    let source = crate::network_url::parse_url(&response.final_url)?;
    let destination = crate::network_url::parse_url(&target).map_err(|_| redirect_denied())?;
    if source.scheme == "https" && destination.scheme == "http" {
        return Err(redirect_denied());
    }
    let mut redirected = request.clone();
    redirected.url = destination.without_fragment;
    if changes_to_get(response.status, request.method) {
        redirected.method = HttpMethod::Get;
        redirected.body = None;
    }
    if source.origin != destination.origin {
        redirected
            .headers
            .retain(|(name, _)| !credential_header(name));
    }
    Ok(redirected)
}

fn unique_location(headers: &[(String, String)]) -> Result<&str, IoError> {
    let mut locations = headers
        .iter()
        .filter(|(name, _)| name.eq_ignore_ascii_case("location"));
    let location = locations.next().map(|(_, value)| value.as_str());
    if location.is_none() || locations.next().is_some() {
        return Err(redirect_denied());
    }
    location.ok_or_else(redirect_denied)
}

fn resolve_location(base_url: &str, location: &str) -> Result<String, IoError> {
    if location.is_empty() || location.chars().any(char::is_control) {
        return Err(redirect_denied());
    }
    if has_scheme(location) {
        return crate::network_url::parse_url(location)
            .map(|parsed| parsed.without_fragment)
            .map_err(|_| redirect_denied());
    }
    let (scheme, origin, base_path) = base_parts(base_url)?;
    let resolved = resolve_reference(&scheme, &origin, &base_path, location);
    crate::network_url::parse_url(&resolved)
        .map(|parsed| parsed.without_fragment)
        .map_err(|_| redirect_denied())
}

fn resolve_reference(scheme: &str, origin: &str, base_path: &str, location: &str) -> String {
    if let Some(authority) = location.strip_prefix("//") {
        return format!("{scheme}:{authority}");
    }
    if location.starts_with('/') {
        return format!("{origin}{location}");
    }
    if location.starts_with('?') {
        return format!("{origin}{}{location}", path_without_query(base_path));
    }
    if location.starts_with('#') {
        return format!("{origin}{base_path}");
    }
    resolve_path_reference(origin, base_path, location)
}

fn base_parts(base_url: &str) -> Result<(String, String, String), IoError> {
    let base = base_url.split('#').next().ok_or_else(redirect_denied)?;
    let (scheme, address) = base.split_once("://").ok_or_else(redirect_denied)?;
    let boundary = address.find(['/', '?']).unwrap_or(address.len());
    let authority = address.get(..boundary).ok_or_else(redirect_denied)?;
    let origin = format!("{scheme}://{authority}");
    let suffix = address.get(boundary..).ok_or_else(redirect_denied)?;
    let base_path = if suffix.starts_with('/') {
        suffix.to_owned()
    } else {
        format!("/{suffix}")
    };
    Ok((scheme.to_ascii_lowercase(), origin, base_path))
}

fn resolve_path_reference(origin: &str, base_path: &str, location: &str) -> String {
    let (relative_path, suffix) = path_and_suffix(location);
    let directory = base_path
        .split('?')
        .next()
        .unwrap_or(base_path)
        .rsplit_once('/')
        .map_or(
            "/",
            |(parent, _)| if parent.is_empty() { "/" } else { parent },
        );
    let merged = if directory.ends_with('/') {
        format!("{directory}{relative_path}")
    } else {
        format!("{directory}/{relative_path}")
    };
    format!("{origin}{}{suffix}", normalize_path(&merged))
}

fn path_and_suffix(value: &str) -> (&str, &str) {
    let boundary = value.find(['?', '#']).unwrap_or(value.len());
    value.split_at(boundary)
}

fn path_without_query(path: &str) -> &str {
    path.split('?').next().unwrap_or(path)
}

fn normalize_path(path: &str) -> String {
    let trailing_slash = path.ends_with('/') || path.ends_with("/.") || path.ends_with("/..");
    let mut segments = Vec::new();
    for segment in path.split('/') {
        match segment {
            "." => {}
            ".." => {
                if segments.len() > 1 {
                    segments.pop();
                }
            }
            _ => segments.push(segment),
        }
    }
    let mut normalized = segments.join("/");
    if !normalized.starts_with('/') {
        normalized.insert(0, '/');
    }
    if trailing_slash && !normalized.ends_with('/') {
        normalized.push('/');
    }
    normalized
}

fn has_scheme(location: &str) -> bool {
    let boundary = location.find(['/', '?', '#']).unwrap_or(location.len());
    location
        .get(..boundary)
        .is_some_and(|prefix| prefix.contains(':'))
}

fn changes_to_get(status: u16, method: HttpMethod) -> bool {
    status == 303 || (matches!(status, 301 | 302) && method == HttpMethod::Post)
}

fn credential_header(name: &str) -> bool {
    let normalized = name.to_ascii_lowercase();
    matches!(
        normalized.as_str(),
        "authorization"
            | "proxy-authorization"
            | "cookie"
            | "set-cookie"
            | "token"
            | "key"
            | "secret"
    ) || ["-token", "-key", "-secret"]
        .iter()
        .any(|suffix| normalized.ends_with(suffix))
}

fn redirect_denied() -> IoError {
    IoError::from_kind(IoErrorKind::RedirectDenied)
}
