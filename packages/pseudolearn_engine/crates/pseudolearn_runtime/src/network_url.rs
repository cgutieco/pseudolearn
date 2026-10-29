use crate::IoError;
use pseudolearn_abi::IoErrorKind;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct ParsedUrl {
    pub(crate) origin: String,
    pub(crate) without_fragment: String,
}

pub(crate) fn parse_url(value: &str) -> Result<ParsedUrl, IoError> {
    if value.chars().any(char::is_control) || value.chars().any(char::is_whitespace) {
        return Err(invalid());
    }
    let (scheme, address) = value.split_once("://").ok_or_else(invalid)?;
    let scheme = scheme.to_ascii_lowercase();
    if !["http", "https"].contains(&scheme.as_str()) || address.contains('@') {
        return Err(invalid());
    }
    let authority_end = address.find(['/', '?', '#']).unwrap_or(address.len());
    let authority = address.get(..authority_end).ok_or_else(invalid)?;
    let (host, port) = parse_authority(authority, &scheme)?;
    let origin = format!("{scheme}://{host}:{port}");
    let without_fragment = value.split_once('#').map_or(value, |(head, _)| head);
    Ok(ParsedUrl {
        origin,
        without_fragment: without_fragment.to_owned(),
    })
}

pub(crate) fn parse_origin(value: &str) -> Result<String, IoError> {
    let parsed = parse_url(value)?;
    let address = value
        .split_once("://")
        .map(|(_, address)| address)
        .ok_or_else(invalid)?;
    if address.contains('/') || address.contains('?') || address.contains('#') {
        return Err(invalid());
    }
    Ok(parsed.origin)
}

fn parse_authority(authority: &str, scheme: &str) -> Result<(String, u16), IoError> {
    if authority.is_empty() || !authority.is_ascii() {
        return Err(invalid());
    }
    let (host, port) = split_host_port(authority, scheme)?;
    if host.is_empty() || !valid_host(&host) {
        return Err(invalid());
    }
    Ok((host.to_ascii_lowercase(), port))
}

fn split_host_port(authority: &str, scheme: &str) -> Result<(String, u16), IoError> {
    if let Some(address) = authority.strip_prefix('[') {
        let (host, suffix) = address.split_once(']').ok_or_else(invalid)?;
        if host.is_empty() || !host.contains(':') {
            return Err(invalid());
        }
        let port = if suffix.is_empty() {
            default_port(scheme)
        } else {
            suffix
                .strip_prefix(':')
                .ok_or_else(invalid)?
                .parse()
                .map_err(|_| invalid())?
        };
        return Ok((format!("[{}]", host.to_ascii_lowercase()), port));
    }
    let mut parts = authority.split(':');
    let host = parts.next().ok_or_else(invalid)?;
    let port = match (parts.next(), parts.next()) {
        (None, None) => default_port(scheme),
        (Some(value), None) => value.parse().map_err(|_| invalid())?,
        _ => return Err(invalid()),
    };
    Ok((host.to_owned(), port))
}

fn valid_host(host: &str) -> bool {
    host.starts_with('[')
        || host
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'.' | b'-'))
}

fn default_port(scheme: &str) -> u16 {
    if scheme == "https" { 443 } else { 80 }
}

fn invalid() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidUrl)
}
