use crate::physical_error::HostError;
use rustls::pki_types::{CertificateDer, pem::PemObject};
use rustls::{ClientConfig, Error, RootCertStore};
use std::io;
use std::sync::Arc;
use tokio_rustls::TlsConnector;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CertificateValidation {
    Required,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TlsConfiguration {
    validation: CertificateValidation,
    additional_root_certificates: Vec<Vec<u8>>,
}

impl TlsConfiguration {
    #[must_use]
    pub fn from_host_roots(additional_root_certificates: Vec<Vec<u8>>) -> Self {
        Self {
            validation: CertificateValidation::Required,
            additional_root_certificates,
        }
    }

    #[must_use]
    pub fn validation(&self) -> CertificateValidation {
        self.validation
    }

    #[must_use]
    pub fn additional_root_certificates(&self) -> &[Vec<u8>] {
        &self.additional_root_certificates
    }

    pub(crate) fn connector(&self) -> Result<TlsConnector, HostError> {
        let loaded = rustls_native_certs::load_native_certs();
        let mut roots = RootCertStore::empty();
        roots.add_parsable_certificates(loaded.certs);
        for certificate in self.additional_root_certificates() {
            add_host_roots(&mut roots, certificate)?;
        }
        if roots.is_empty() {
            return Err(HostError::PERMISSION_DENIED);
        }
        let settings = ClientConfig::builder()
            .with_root_certificates(roots)
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

fn add_host_roots(roots: &mut RootCertStore, certificate: &[u8]) -> Result<(), HostError> {
    let mut found = false;
    for root in CertificateDer::pem_slice_iter(certificate) {
        roots
            .add(root.map_err(|_| HostError::INVALID_PATH)?)
            .map_err(|_| HostError::INVALID_PATH)?;
        found = true;
    }
    if found {
        Ok(())
    } else {
        Err(HostError::INVALID_PATH)
    }
}
