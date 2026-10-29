use crate::physical_network_address::{self, AddressPolicyResult};
use std::net::{SocketAddr, ToSocketAddrs};

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum AddressLookup {
    Addresses(Vec<SocketAddr>),
    Failed,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum NetworkResolution {
    Addresses(Vec<SocketAddr>),
    InvalidHost,
    DestinationDenied,
    ConnectionFailed,
}

pub trait AddressResolver {
    #[must_use]
    fn resolve(&self, hostname: &str, port: u16) -> AddressLookup;
}

pub struct SystemAddressResolver;

impl AddressResolver for SystemAddressResolver {
    fn resolve(&self, hostname: &str, port: u16) -> AddressLookup {
        let hostname = hostname
            .strip_prefix('[')
            .and_then(|value| value.strip_suffix(']'))
            .unwrap_or(hostname);
        match (hostname, port).to_socket_addrs() {
            Ok(addresses) => AddressLookup::Addresses(addresses.collect()),
            Err(_) => AddressLookup::Failed,
        }
    }
}

#[must_use]
pub fn resolve_checked<Resolver: AddressResolver>(
    resolver: &Resolver,
    hostname: &str,
    port: u16,
    local_test_origin: bool,
) -> NetworkResolution {
    if physical_network_address::validate_host(hostname) != AddressPolicyResult::Allowed
        || port == 0
    {
        return NetworkResolution::InvalidHost;
    }
    match resolver.resolve(hostname, port) {
        AddressLookup::Addresses(addresses) => {
            validate_resolved(addresses, port, local_test_origin)
        }
        AddressLookup::Failed => NetworkResolution::ConnectionFailed,
    }
}

fn validate_resolved(
    addresses: Vec<SocketAddr>,
    port: u16,
    local_test_origin: bool,
) -> NetworkResolution {
    if addresses.is_empty() {
        return NetworkResolution::ConnectionFailed;
    }
    for address in &addresses {
        if address.port() != port {
            return NetworkResolution::ConnectionFailed;
        }
        if physical_network_address::validate_address(address.ip(), local_test_origin)
            == AddressPolicyResult::DestinationDenied
        {
            return NetworkResolution::DestinationDenied;
        }
    }
    NetworkResolution::Addresses(addresses)
}
