use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum AddressPolicyResult {
    Allowed,
    InvalidHost,
    DestinationDenied,
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

#[must_use]
pub fn validate_address(address: IpAddr, local_test_origin: bool) -> AddressPolicyResult {
    if local_test_origin {
        return if is_loopback_address(address) {
            AddressPolicyResult::Allowed
        } else {
            AddressPolicyResult::DestinationDenied
        };
    }
    if is_forbidden(address) {
        return AddressPolicyResult::DestinationDenied;
    }
    AddressPolicyResult::Allowed
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

fn is_forbidden(address: IpAddr) -> bool {
    match address {
        IpAddr::V4(ipv4) => forbidden_ipv4(ipv4),
        IpAddr::V6(ipv6) => forbidden_ipv6(ipv6),
    }
}

fn is_loopback_address(address: IpAddr) -> bool {
    match address {
        IpAddr::V4(ipv4) => ipv4.is_loopback(),
        IpAddr::V6(ipv6) => {
            ipv6.is_loopback() || ipv4_mapped(ipv6).is_some_and(|mapped| mapped.is_loopback())
        }
    }
}

fn forbidden_ipv4(address: Ipv4Addr) -> bool {
    address.is_loopback()
        || address.is_private()
        || address.is_link_local()
        || address.is_unspecified()
        || address.is_multicast()
        || address.octets() == [255, 255, 255, 255]
}

fn forbidden_ipv6(address: Ipv6Addr) -> bool {
    if let Some(mapped) = ipv4_mapped(address) {
        return forbidden_ipv4(mapped);
    }
    address.is_loopback()
        || address.is_unique_local()
        || address.is_unicast_link_local()
        || address.is_unspecified()
        || address.is_multicast()
}

fn ipv4_mapped(address: Ipv6Addr) -> Option<Ipv4Addr> {
    let bytes = address.octets();
    if bytes[..10].iter().any(|byte| *byte != 0) || bytes[10..12] != [0xff, 0xff] {
        return None;
    }
    Some(Ipv4Addr::new(bytes[12], bytes[13], bytes[14], bytes[15]))
}
