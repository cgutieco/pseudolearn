use rcgen::{
    BasicConstraints, CertificateParams, CertifiedIssuer, IsCa, KeyPair, KeyUsagePurpose,
    date_time_ymd,
};
use std::fs;
use std::path::{Path, PathBuf};

pub struct ServerIdentity {
    pub certificate_der: Vec<u8>,
    pub private_key_der: Vec<u8>,
}

pub struct ServerCertificates {
    pub root_certificate_path: PathBuf,
    pub valid: ServerIdentity,
    pub expired: ServerIdentity,
    pub wrong_host: ServerIdentity,
    pub self_signed: ServerIdentity,
}

struct SignedIdentityOptions {
    name: &'static str,
    names: Vec<String>,
    expired: bool,
}

pub fn generate(directory: &Path) -> Result<ServerCertificates, String> {
    fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    let (root_certificate_path, root_issuer) = generate_root(directory)?;
    let valid = signed_identity(
        directory,
        SignedIdentityOptions {
            name: "valid",
            names: vec!["127.0.0.1".to_owned(), "localhost".to_owned()],
            expired: false,
        },
        &root_issuer,
    )?;
    let expired = signed_identity(
        directory,
        SignedIdentityOptions {
            name: "expired",
            names: vec!["127.0.0.1".to_owned(), "localhost".to_owned()],
            expired: true,
        },
        &root_issuer,
    )?;
    let wrong_host = signed_identity(
        directory,
        SignedIdentityOptions {
            name: "wrong-host",
            names: vec!["wrong.test".to_owned()],
            expired: false,
        },
        &root_issuer,
    )?;
    let self_signed = self_signed_identity(directory)?;
    Ok(ServerCertificates {
        root_certificate_path,
        valid,
        expired,
        wrong_host,
        self_signed,
    })
}

fn generate_root(directory: &Path) -> Result<(PathBuf, CertifiedIssuer<'static, KeyPair>), String> {
    let mut root_parameters = CertificateParams::default();
    root_parameters.is_ca = IsCa::Ca(BasicConstraints::Unconstrained);
    root_parameters.key_usages = vec![KeyUsagePurpose::KeyCertSign, KeyUsagePurpose::CrlSign];
    let root_key = KeyPair::generate().map_err(|error| error.to_string())?;
    let root_issuer = CertifiedIssuer::self_signed(root_parameters, root_key)
        .map_err(|error| error.to_string())?;
    let root_certificate = root_issuer.as_ref().pem();
    let root_certificate_path = directory.join("root.pem");
    write_file(&root_certificate_path, root_certificate.as_bytes())?;
    Ok((root_certificate_path, root_issuer))
}

fn signed_identity(
    directory: &Path,
    options: SignedIdentityOptions,
    issuer: &CertifiedIssuer<'_, KeyPair>,
) -> Result<ServerIdentity, String> {
    let mut parameters =
        CertificateParams::new(options.names).map_err(|error| error.to_string())?;
    if options.expired {
        parameters.not_before = date_time_ymd(2000, 1, 1);
        parameters.not_after = date_time_ymd(2001, 1, 1);
    }
    let key = KeyPair::generate().map_err(|error| error.to_string())?;
    let certificate = parameters
        .signed_by(&key, issuer)
        .map_err(|error| error.to_string())?;
    write_identity(
        directory,
        options.name,
        &certificate.pem(),
        &key.serialize_pem(),
    )?;
    Ok(ServerIdentity {
        certificate_der: certificate.der().to_vec(),
        private_key_der: key.serialize_der(),
    })
}

fn self_signed_identity(directory: &Path) -> Result<ServerIdentity, String> {
    let parameters = CertificateParams::new(vec!["127.0.0.1".to_owned(), "localhost".to_owned()])
        .map_err(|error| error.to_string())?;
    let key = KeyPair::generate().map_err(|error| error.to_string())?;
    let certificate = parameters
        .self_signed(&key)
        .map_err(|error| error.to_string())?;
    write_identity(
        directory,
        "self-signed",
        &certificate.pem(),
        &key.serialize_pem(),
    )?;
    Ok(ServerIdentity {
        certificate_der: certificate.der().to_vec(),
        private_key_der: key.serialize_der(),
    })
}

fn write_identity(
    directory: &Path,
    name: &str,
    certificate: &str,
    private_key: &str,
) -> Result<(), String> {
    write_file(
        &directory.join(format!("{name}.pem")),
        certificate.as_bytes(),
    )?;
    write_file(
        &directory.join(format!("{name}-key.pem")),
        private_key.as_bytes(),
    )
}

fn write_file(path: &Path, contents: &[u8]) -> Result<(), String> {
    fs::write(path, contents).map_err(|error| error.to_string())
}
