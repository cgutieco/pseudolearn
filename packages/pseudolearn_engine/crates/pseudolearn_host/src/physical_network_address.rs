use std::net::{Ipv4Addr, Ipv6Addr};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum AddressPolicyResult {
    Allowed,
    InvalidHost,
}

#[must_use]
pub fn validate_host(hostname: &str) -> AddressPolicyResult {
    if hostname.is_empty() || !hostname.is_ascii() {
        return AddressPolicyResult::InvalidHost;
    }
    if let Some(address) = hostname
        .strip_prefix('[')
        .and_then(|value| value.strip_suffix(']'))
    {
        return if address.parse::<Ipv6Addr>().is_ok() {
            AddressPolicyResult::Allowed
        } else {
            AddressPolicyResult::InvalidHost
        };
    }
    if hostname.contains(['[', ']', ':']) || legacy_numeric_host(hostname) {
        return AddressPolicyResult::InvalidHost;
    }
    if hostname.parse::<Ipv4Addr>().is_ok() || valid_domain(hostname) {
        return AddressPolicyResult::Allowed;
    }
    AddressPolicyResult::InvalidHost
}

fn valid_domain(hostname: &str) -> bool {
    let name = hostname.strip_suffix('.').unwrap_or(hostname);
    !name.is_empty()
        && name.len() <= 253
        && name.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= 63
                && !label.starts_with('-')
                && !label.ends_with('-')
                && label
                    .bytes()
                    .all(|byte| byte.is_ascii_alphanumeric() || byte == b'-')
        })
}

fn legacy_numeric_host(hostname: &str) -> bool {
    let normalized = hostname.strip_suffix('.').unwrap_or(hostname);
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
