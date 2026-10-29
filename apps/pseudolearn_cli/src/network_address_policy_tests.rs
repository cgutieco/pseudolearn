use crate::physical_network_address::{self, AddressPolicyResult};
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

#[test]
fn accepts_canonical_hostnames_and_ip_literals() {
    for hostname in ["service.example", "127.0.0.1", "[2001:db8::1]"] {
        assert_eq!(
            physical_network_address::validate_host(hostname),
            AddressPolicyResult::Allowed
        );
    }
}

#[test]
fn rejects_alternative_numeric_ip_forms() {
    for hostname in ["2130706433", "0x7f000001", "0177.0.0.1", "127.1"] {
        assert_eq!(
            physical_network_address::validate_host(hostname),
            AddressPolicyResult::InvalidHost,
            "{hostname}"
        );
    }
}

#[test]
fn rejects_malformed_hostnames_and_ports() {
    for hostname in [
        "",
        "service..example",
        "-service.example",
        "service.example-",
    ] {
        assert_eq!(
            physical_network_address::validate_host(hostname),
            AddressPolicyResult::InvalidHost,
            "{hostname}"
        );
    }
}

#[test]
fn rejects_ssrf_ranges_for_ipv4_and_ipv6() -> Result<(), String> {
    let addresses = [
        IpAddr::V4(Ipv4Addr::LOCALHOST),
        IpAddr::V4(Ipv4Addr::new(10, 1, 2, 3)),
        IpAddr::V4(Ipv4Addr::new(169, 254, 10, 20)),
        IpAddr::V4(Ipv4Addr::new(169, 254, 169, 254)),
        IpAddr::V4(Ipv4Addr::UNSPECIFIED),
        IpAddr::V4(Ipv4Addr::new(224, 0, 0, 1)),
        IpAddr::V6(Ipv6Addr::LOCALHOST),
        IpAddr::V6("fc00::1".parse().map_err(|_| "invalid test address")?),
        IpAddr::V6("fe80::1".parse().map_err(|_| "invalid test address")?),
        IpAddr::V6(
            "::ffff:127.0.0.1"
                .parse()
                .map_err(|_| "invalid test address")?,
        ),
    ];
    for address in addresses {
        assert_eq!(
            physical_network_address::validate_address(address, false),
            AddressPolicyResult::DestinationDenied,
            "{address}"
        );
    }
    Ok(())
}

#[test]
fn local_test_origin_allows_only_loopback_addresses() -> Result<(), String> {
    let mapped_loopback = "::ffff:127.0.0.1"
        .parse::<Ipv6Addr>()
        .map_err(|_| "invalid test address")?;
    for address in [
        IpAddr::V4(Ipv4Addr::LOCALHOST),
        IpAddr::V6(Ipv6Addr::LOCALHOST),
        IpAddr::V6(mapped_loopback),
    ] {
        assert_eq!(
            physical_network_address::validate_address(address, true),
            AddressPolicyResult::Allowed
        );
    }
    for address in [
        IpAddr::V4(Ipv4Addr::new(192, 168, 1, 5)),
        IpAddr::V4(Ipv4Addr::new(8, 8, 8, 8)),
    ] {
        assert_eq!(
            physical_network_address::validate_address(address, true),
            AddressPolicyResult::DestinationDenied
        );
    }
    Ok(())
}
