use crate::physical_error::HostError;
use rustls::{
    ClientConfig, Error,
    pki_types::{CertificateDer, pem::PemObject},
};
use std::io;
use std::sync::Arc;
use tokio_rustls::TlsConnector;

#[derive(Clone)]
pub struct TlsConfiguration {
    additional_root_certificates: Vec<Vec<u8>>,
}

impl TlsConfiguration {
    pub fn from_host_roots(additional_root_certificates: Vec<Vec<u8>>) -> Self {
        Self {
            additional_root_certificates,
        }
    }

    pub(crate) fn connector(&self) -> Result<TlsConnector, HostError> {
        let builder = ClientConfig::builder();
        let mut certificates = Vec::new();
        for root in &self.additional_root_certificates {
            let parsed = CertificateDer::pem_slice_iter(root)
                .collect::<Result<Vec<_>, _>>()
                .map_err(|_| HostError::CERTIFICATE_INVALID)?;
            if parsed.is_empty() {
                return Err(HostError::CERTIFICATE_INVALID);
            }
            certificates.extend(parsed);
        }
        let verifier = rustls_platform_verifier::Verifier::new_with_extra_roots(
            certificates,
            builder.crypto_provider().clone(),
        )
        .map_err(|_| HostError::CERTIFICATE_INVALID)?;
        let settings = builder
            .dangerous()
            .with_custom_certificate_verifier(Arc::new(verifier))
            .with_no_client_auth();
        Ok(TlsConnector::from(Arc::new(settings)))
    }
}

pub(super) fn classify_handshake_error(error: &io::Error) -> HostError {
    let certificate_error = error
        .get_ref()
        .and_then(|source| source.downcast_ref::<Error>())
        .is_some_and(|source| {
            matches!(
                source,
                Error::InvalidCertificate(_) | Error::NoCertificatesPresented
            )
        });
    if certificate_error {
        HostError::CERTIFICATE_INVALID
    } else {
        HostError::CONNECTION_FAILED
    }
}
