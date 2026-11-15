use crate::physical_network_tls::TlsConfiguration;

#[derive(Clone)]
pub struct NetworkPolicy {
    tls_configuration: TlsConfiguration,
}

impl NetworkPolicy {
    pub fn from_host_roots(certificates: Vec<Vec<u8>>) -> Self {
        Self {
            tls_configuration: TlsConfiguration::from_host_roots(certificates),
        }
    }

    pub fn default_policy() -> Self {
        Self::from_host_roots(Vec::new())
    }

    pub(crate) fn tls_configuration(&self) -> &TlsConfiguration {
        &self.tls_configuration
    }
}
