use crate::physical_network_resolver::{self, AddressLookup, AddressResolver, NetworkResolution};
use std::cell::Cell;
use std::net::{Ipv4Addr, SocketAddr};

struct FakeResolver {
    addresses: Vec<SocketAddr>,
    fail: bool,
    calls: Cell<usize>,
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
