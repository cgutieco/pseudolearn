use crate::execution_options::ExecutionArguments;
use crate::physical_error::HostError;
use crate::physical_network_address::AddressPolicyResult;
use crate::physical_network_tls::TlsConfiguration;
use http::Uri;
use serde_json::{Value, json};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct NetworkOrigin {
    scheme: String,
    host: String,
    port: u16,
    local: bool,
}

impl NetworkOrigin {
    #[must_use]
    pub fn new(scheme: impl Into<String>, host: impl Into<String>, port: u16, local: bool) -> Self {
        Self {
            scheme: scheme.into(),
            host: host.into().to_ascii_lowercase(),
            port,
            local,
        }
    }

    fn matches(&self, other: &Self) -> bool {
        self.scheme == other.scheme && self.host == other.host && self.port == other.port
    }
}

pub struct NetworkCapabilities;

impl NetworkCapabilities {
    #[must_use]
    pub fn value() -> Value {
        json!({
            "tls_validation":true,
            "wire_limit":"available",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip"
        })
    }
}

#[derive(Clone)]
pub(crate) struct NetworkPolicy {
    origins: Vec<NetworkOrigin>,
    tls_configuration: TlsConfiguration,
}

impl NetworkPolicy {
    pub(crate) fn from_execution(execution: &ExecutionArguments) -> Result<Self, HostError> {
        let mut origins = execution
            .origins
            .iter()
            .map(|value| network_origin(value, false).map_err(|_| HostError::INVALID_PATH))
            .collect::<Result<Vec<_>, _>>()?;
        origins.extend(
            execution
                .local_origins
                .iter()
                .map(|value| network_origin(value, true).map_err(|_| HostError::INVALID_PATH))
                .collect::<Result<Vec<_>, _>>()?,
        );
        let certificates = execution
            .test_roots
            .iter()
            .map(|path| std::fs::read(path).map_err(|_| HostError::INVALID_PATH))
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Self {
            origins,
            tls_configuration: TlsConfiguration::from_host_roots(certificates),
        })
    }

    pub(crate) fn default_policy() -> Self {
        Self {
            origins: Vec::new(),
            tls_configuration: TlsConfiguration::from_host_roots(Vec::new()),
        }
    }

    pub(crate) fn local_test_origin(&self, value: &str) -> Result<bool, HostError> {
        let requested = parse_request_origin(value).map_err(|_| HostError::INVALID_PATH)?;
        self.origins
            .iter()
            .find(|origin| origin.matches(&requested))
            .map(|origin| origin.local)
            .ok_or(HostError::PERMISSION_DENIED)
    }

    pub(crate) fn tls_configuration(&self) -> &TlsConfiguration {
        &self.tls_configuration
    }
}

pub fn network_origin(value: &str, local: bool) -> Result<NetworkOrigin, String> {
    parse_origin(value, local)
}

fn parse_origin(value: &str, local: bool) -> Result<NetworkOrigin, String> {
    parse_uri(value, local, true)
}

fn parse_request_origin(value: &str) -> Result<NetworkOrigin, String> {
    let uri = value.parse::<Uri>().map_err(|_| "invalid URL".to_owned())?;
    let local = uri.scheme_str() == Some("http");
    parse_uri(value, local, false)
}

fn parse_uri(value: &str, local: bool, require_origin: bool) -> Result<NetworkOrigin, String> {
    let uri = value
        .parse::<Uri>()
        .map_err(|_| "invalid origin".to_owned())?;
    let scheme = uri
        .scheme_str()
        .ok_or_else(|| "missing scheme".to_owned())?;
    if value.contains('#')
        || !matches!(scheme, "http" | "https")
        || (local && scheme != "http")
        || (!local && scheme != "https")
        || uri
            .authority()
            .is_some_and(|authority| authority.as_str().contains('@'))
        || (require_origin
            && uri
                .path_and_query()
                .is_some_and(|path| path.as_str() != "/"))
    {
        return Err("invalid origin".to_owned());
    }
    let host = uri.host().ok_or_else(|| "missing host".to_owned())?;
    let address_host = if host.contains(':') {
        format!("[{host}]")
    } else {
        host.to_owned()
    };
    if crate::physical_network_address::validate_host(&address_host) != AddressPolicyResult::Allowed
    {
        return Err("invalid host".to_owned());
    }
    if local && !loopback_host(host) {
        return Err("local origin must use loopback".to_owned());
    }
    let port = uri
        .port_u16()
        .unwrap_or(if scheme == "https" { 443 } else { 80 });
    Ok(NetworkOrigin::new(scheme, host, port, local))
}

fn loopback_host(host: &str) -> bool {
    host.eq_ignore_ascii_case("localhost")
        || host
            .trim_matches(['[', ']'])
            .parse::<std::net::IpAddr>()
            .is_ok_and(|address| address.is_loopback())
}
