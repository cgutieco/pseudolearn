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
}
