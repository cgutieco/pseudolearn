use crate::physical_network_tls::{CertificateValidation, TlsConfiguration};

#[test]
fn requires_certificate_validation_and_accepts_only_host_roots() {
    let roots = vec![vec![1, 2, 3]];
    let configuration = TlsConfiguration::from_host_roots(roots.clone());
    assert_eq!(configuration.validation(), CertificateValidation::Required);
    assert_eq!(configuration.additional_root_certificates(), roots);
}
