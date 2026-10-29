use crate::physical_error::HostError;
use crate::physical_network_tls::{
    CertificateValidation, TlsConfiguration, classify_handshake_error,
};
use rustls::{CertificateError, Error};
use std::io;

#[test]
fn requires_certificate_validation_and_stores_host_roots() {
    let roots = vec![vec![1, 2, 3]];
    let configuration = TlsConfiguration::from_host_roots(roots.clone());
    assert_eq!(configuration.validation(), CertificateValidation::Required);
    assert_eq!(configuration.additional_root_certificates(), roots);
}

#[test]
fn distinguishes_invalid_certificates_from_other_tls_failures() {
    let certificate_error = io::Error::new(
        io::ErrorKind::InvalidData,
        Error::InvalidCertificate(CertificateError::Expired),
    );
    let connection_error = io::Error::other("handshake failed");
    assert_eq!(
        classify_handshake_error(&certificate_error),
        HostError::CERTIFICATE_INVALID
    );
    assert_eq!(
        classify_handshake_error(&connection_error),
        HostError::CONNECTION_FAILED
    );
}

#[test]
fn rejects_invalid_host_root_pem() {
    let configuration = TlsConfiguration::from_host_roots(vec![b"invalid pem".to_vec()]);
    assert_eq!(
        configuration.connector().err(),
        Some(HostError::INVALID_PATH)
    );
}
