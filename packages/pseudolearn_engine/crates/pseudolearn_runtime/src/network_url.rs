use crate::IoError;
use pseudolearn_abi::IoErrorKind;
use std::net::{Ipv4Addr, Ipv6Addr};

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct ParsedUrl {
    pub(crate) scheme: String,
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
        scheme,
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
    if host.is_empty() || !valid_host(&host) || noncanonical_numeric_host(&host) {
        return Err(invalid());
    }
    Ok((host.to_ascii_lowercase(), port))
}

fn split_host_port(authority: &str, scheme: &str) -> Result<(String, u16), IoError> {
    if let Some(address) = authority.strip_prefix('[') {
        let (host, suffix) = address.split_once(']').ok_or_else(invalid)?;
        let parsed_host = host.parse::<Ipv6Addr>().map_err(|_| invalid())?;
        let port = if suffix.is_empty() {
            default_port(scheme)
        } else {
            suffix
                .strip_prefix(':')
                .ok_or_else(invalid)?
                .parse()
                .map_err(|_| invalid())?
        };
        return Ok((format!("[{parsed_host}]"), port));
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
    if let Some(address) = host
        .strip_prefix('[')
        .and_then(|value| value.strip_suffix(']'))
    {
        return address.parse::<Ipv6Addr>().is_ok();
    }
    if host.parse::<Ipv4Addr>().is_ok() {
        return true;
    }
    let normalized = host.strip_suffix('.').unwrap_or(host);
    !normalized.is_empty()
        && normalized.len() <= 253
        && normalized.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= 63
                && !label.starts_with('-')
                && !label.ends_with('-')
                && label
                    .bytes()
                    .all(|byte| byte.is_ascii_alphanumeric() || byte == b'-')
        })
}

fn noncanonical_numeric_host(host: &str) -> bool {
    let normalized = host.strip_suffix('.').unwrap_or(host);
    let components = normalized.split('.').collect::<Vec<_>>();
    if !components
        .iter()
        .all(|component| numeric_component(component))
    {
        return false;
    }
    if components.len() != 4 {
        return true;
    }
    if components
        .iter()
        .any(|component| component.len() > 1 && component.starts_with('0'))
    {
        return true;
    }
    components
        .iter()
        .any(|component| component.parse::<u16>().map_or(true, |value| value > 255))
}

fn numeric_component(component: &str) -> bool {
    if component.is_empty() {
        return false;
    }
    if let Some(hexadecimal) = component
        .strip_prefix("0x")
        .or_else(|| component.strip_prefix("0X"))
    {
        return !hexadecimal.is_empty() && hexadecimal.bytes().all(|byte| byte.is_ascii_hexdigit());
    }
    component.bytes().all(|byte| byte.is_ascii_digit())
}

fn default_port(scheme: &str) -> u16 {
    if scheme == "https" { 443 } else { 80 }
}

fn invalid() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidUrl)
}
