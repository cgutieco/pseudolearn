use crate::physical_network_resolver::{self, AddressLookup, AddressResolver, NetworkResolution};
use std::cell::Cell;
use std::net::{Ipv4Addr, SocketAddr};

struct FakeResolver {
    addresses: Vec<SocketAddr>,
    fail: bool,
    calls: Cell<usize>,
}

struct ChangingResolver {
    calls: Cell<usize>,
}

impl AddressResolver for ChangingResolver {
    fn resolve(&self, _hostname: &str, port: u16) -> AddressLookup {
        let call = self.calls.get();
        self.calls.set(call.saturating_add(1));
        let octets = if call == 0 {
            [8, 8, 8, 8]
        } else {
            [127, 0, 0, 1]
        };
        AddressLookup::Addresses(vec![address(octets, port)])
    }
}

impl FakeResolver {
    fn new(addresses: Vec<SocketAddr>, fail: bool) -> Self {
        Self {
            addresses,
            fail,
            calls: Cell::new(0),
        }
    }
}

impl AddressResolver for FakeResolver {
    fn resolve(&self, _hostname: &str, _port: u16) -> AddressLookup {
        self.calls.set(self.calls.get() + 1);
        if self.fail {
            return AddressLookup::Failed;
        }
        AddressLookup::Addresses(self.addresses.clone())
    }
}

fn address(octets: [u8; 4], port: u16) -> SocketAddr {
    SocketAddr::from((Ipv4Addr::from(octets), port))
}

#[test]
fn returns_the_checked_snapshot_after_one_resolution() {
    let addresses = vec![address([8, 8, 8, 8], 443), address([1, 1, 1, 1], 443)];
    let resolver = FakeResolver::new(addresses.clone(), false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example", 443, false),
        NetworkResolution::Addresses(addresses)
    );
    assert_eq!(resolver.calls.get(), 1);
}

#[test]
fn rejects_every_address_if_any_resolution_is_forbidden() {
    let resolver = FakeResolver::new(
        vec![address([8, 8, 8, 8], 443), address([127, 0, 0, 1], 443)],
        false,
    );
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example", 443, false),
        NetworkResolution::DestinationDenied
    );
    assert_eq!(resolver.calls.get(), 1);
}

#[test]
fn rejects_a_forbidden_address_from_a_trailing_dot_hostname() {
    let resolver = FakeResolver::new(vec![address([169, 254, 169, 254], 443)], false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example.", 443, false),
        NetworkResolution::DestinationDenied
    );
    assert_eq!(resolver.calls.get(), 1);
}

#[test]
fn dns_rebinding_cannot_change_the_single_checked_snapshot() {
    let resolver = ChangingResolver {
        calls: Cell::new(0),
    };
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example", 443, false),
        NetworkResolution::Addresses(vec![address([8, 8, 8, 8], 443)])
    );
    assert_eq!(resolver.calls.get(), 1);
}

#[test]
fn seeded_host_port_and_dns_combinations_preserve_address_policy() {
    let mut state = 42_u64;
    for _ in 0..1000 {
        state = splitmix64(state);
        let host = match state % 4 {
            0 => "service.example",
            1 => "service.example.",
            2 => "2130706433",
            _ => "api.example",
        };
        state = splitmix64(state);
        let port = u16::try_from((state % 3).saturating_add(443)).unwrap_or(443);
        let addresses = if state & 1 == 0 {
            vec![address([8, 8, 8, 8], port)]
        } else {
            vec![
                address([8, 8, 8, 8], port),
                address([169, 254, 169, 254], port),
            ]
        };
        let resolver = FakeResolver::new(addresses.clone(), false);
        let result = physical_network_resolver::resolve_checked(&resolver, host, port, false);
        if resolver.calls.get() == 1 && addresses.contains(&address([169, 254, 169, 254], port)) {
            assert_eq!(result, NetworkResolution::DestinationDenied);
        }
        if matches!(result, NetworkResolution::Addresses(_)) {
            assert_eq!(resolver.calls.get(), 1);
        } else if result == NetworkResolution::InvalidHost {
            assert_eq!(resolver.calls.get(), 0);
        }
    }
}

fn splitmix64(value: u64) -> u64 {
    let mut mixed = value.wrapping_add(0x9e37_79b9_7f4a_7c15);
    mixed = (mixed ^ (mixed >> 30)).wrapping_mul(0xbf58_476d_1ce4_e5b9);
    mixed = (mixed ^ (mixed >> 27)).wrapping_mul(0x94d0_49bb_1331_11eb);
    mixed ^ (mixed >> 31)
}

#[test]
fn preserves_local_test_grants_for_loopback_origins() {
    let resolver = FakeResolver::new(vec![address([127, 0, 0, 1], 8080)], false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "localhost", 8080, true),
        NetworkResolution::Addresses(vec![address([127, 0, 0, 1], 8080)])
    );
    assert_eq!(resolver.calls.get(), 1);
}

#[test]
fn returns_connection_failure_for_dns_errors_and_empty_results() {
    let failed = FakeResolver::new(Vec::new(), true);
    assert_eq!(
        physical_network_resolver::resolve_checked(&failed, "service.example", 443, false),
        NetworkResolution::ConnectionFailed
    );
    let empty = FakeResolver::new(Vec::new(), false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&empty, "service.example", 443, false),
        NetworkResolution::ConnectionFailed
    );
}

#[test]
fn rejects_invalid_hosts_before_calling_the_resolver() {
    let resolver = FakeResolver::new(vec![address([8, 8, 8, 8], 443)], false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "2130706433", 443, false),
        NetworkResolution::InvalidHost
    );
    assert_eq!(resolver.calls.get(), 0);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example", 0, false),
        NetworkResolution::InvalidHost
    );
    assert_eq!(resolver.calls.get(), 0);
}

#[test]
fn rejects_resolver_results_with_an_unrequested_port() {
    let resolver = FakeResolver::new(vec![address([8, 8, 8, 8], 80)], false);
    assert_eq!(
        physical_network_resolver::resolve_checked(&resolver, "service.example", 443, false),
        NetworkResolution::ConnectionFailed
    );
}

#[test]
fn system_resolver_returns_the_literal_ip_at_the_requested_port() {
    let resolver = physical_network_resolver::SystemAddressResolver;
    assert_eq!(
        resolver.resolve("127.0.0.1", 8080),
        AddressLookup::Addresses(vec![address([127, 0, 0, 1], 8080)])
    );
}
