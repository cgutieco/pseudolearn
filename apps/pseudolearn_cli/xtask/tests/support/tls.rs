use crate::process::ServerProcess;
use rustls::pki_types::{CertificateDer, ServerName, pem::PemObject};
use std::net::TcpStream;
use std::sync::Arc;
use std::time::Duration;

pub fn tls_stream(
    server: &ServerProcess,
    trust_root: bool,
    server_name: &str,
) -> Result<rustls::StreamOwned<rustls::ClientConnection, TcpStream>, String> {
    let mut roots = rustls::RootCertStore::empty();
    if trust_root {
        let root_path = server
            .metadata
            .get("root_certificate")
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing generated root certificate path")?;
        let certificates = std::fs::read(root_path).map_err(|error| error.to_string())?;
        for certificate in CertificateDer::pem_slice_iter(&certificates) {
            roots
                .add(certificate.map_err(|error| error.to_string())?)
                .map_err(|error| error.to_string())?;
        }
    }
    let configuration = rustls::ClientConfig::builder()
        .with_root_certificates(roots)
        .with_no_client_auth();
    let identity =
        ServerName::try_from(server_name.to_owned()).map_err(|error| error.to_string())?;
    let connection = rustls::ClientConnection::new(Arc::new(configuration), identity)
        .map_err(|error| error.to_string())?;
    let https_address = crate::process::address(server, "https_address")?;
    let authority = https_address
        .strip_prefix("https://")
        .ok_or("The HTTPS address has an unexpected scheme")?;
    let stream = TcpStream::connect(authority).map_err(|error| error.to_string())?;
    stream
        .set_read_timeout(Some(Duration::from_secs(3)))
        .map_err(|error| error.to_string())?;
    Ok(rustls::StreamOwned::new(connection, stream))
}
