use crate::physical_network_resolver::{AddressLookup, AddressResolver};
use crate::physical_network_send::{NetworkRequest, send_with_resolver};
use crate::physical_network_tls::TlsConfiguration;
use rustls::pki_types::{CertificateDer, PrivateKeyDer, pem::PemObject};
use serde_json::json;
use std::net::{Ipv4Addr, SocketAddr, TcpListener};
use std::process::Command;
use std::sync::{Arc, mpsc};
use std::thread;
use std::time::Duration;
use tokio_rustls::TlsAcceptor;

const ROOT_CERTIFICATE: &[u8] = include_bytes!("../tests/fixtures/tls/trusted_root.pem");
const PROXY_CHILD_MARKER: &str = "PSEUDOLEARN_PROXY_TEST_CHILD";

struct LoopbackResolver(SocketAddr);

impl AddressResolver for LoopbackResolver {
    fn resolve(&self, _hostname: &str, _port: u16) -> AddressLookup {
        AddressLookup::Addresses(vec![self.0])
    }
}

struct TlsTestServer {
    address: SocketAddr,
    result: mpsc::Receiver<Result<(), String>>,
}

impl TlsTestServer {
    fn wait(self) -> Result<(), String> {
        self.result
            .recv_timeout(Duration::from_secs(3))
            .map_err(|error| error.to_string())?
    }
}

fn start_server(certificate: &[u8], key: &[u8]) -> Result<TlsTestServer, String> {
    let certificate_chain = CertificateDer::pem_slice_iter(certificate)
        .collect::<Result<Vec<_>, _>>()
        .map_err(|error| error.to_string())?;
    let private_key = PrivateKeyDer::from_pem_slice(key).map_err(|error| error.to_string())?;
    let server_config = rustls::ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(certificate_chain, private_key)
        .map_err(|error| error.to_string())?;
    let acceptor = TlsAcceptor::from(Arc::new(server_config));
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    listener
        .set_nonblocking(true)
        .map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let (sender, result) = mpsc::channel();
    thread::spawn(move || {
        let _sent = sender.send(serve_tls_once(listener, acceptor));
    });
    Ok(TlsTestServer { address, result })
}

fn serve_tls_once(listener: TcpListener, acceptor: TlsAcceptor) -> Result<(), String> {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| error.to_string())?;
    runtime.block_on(async move {
        use tokio::io::AsyncWriteExt;
        let listener =
            tokio::net::TcpListener::from_std(listener).map_err(|error| error.to_string())?;
        let (stream, _) = listener.accept().await.map_err(|error| error.to_string())?;
        let mut stream = acceptor
            .accept(stream)
            .await
            .map_err(|error| error.to_string())?;
        read_tls_request(&mut stream).await?;
        stream
            .write_all(b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok")
            .await
            .map_err(|error| error.to_string())
    })
}

async fn read_tls_request(
    stream: &mut tokio_rustls::server::TlsStream<tokio::net::TcpStream>,
) -> Result<(), String> {
    use tokio::io::AsyncReadExt;
    let mut received = Vec::new();
    let mut buffer = [0; 1024];
    while !received.windows(4).any(|window| window == b"\r\n\r\n") {
        let count = stream
            .read(&mut buffer)
            .await
            .map_err(|error| error.to_string())?;
        if count == 0 {
            return Err("TLS client closed before sending HTTP headers".to_owned());
        }
        received.extend_from_slice(&buffer[..count]);
    }
    Ok(())
}

fn request(url: String) -> NetworkRequest {
    NetworkRequest {
        method: "GET".to_owned(),
        url,
        headers: Vec::new(),
        body: None,
        response_limit: Some(1024),
        timeout_nanos: Some(2_000_000_000),
        effective_response_limit: Some(1024),
        effective_timeout_nanos: Some(2_000_000_000),
        wire_limit: Some(4096),
        headers_limit: Some(16),
        header_bytes_limit: Some(4096),
    }
}

fn send_tls(
    certificate: &[u8],
    key: &[u8],
    roots: Vec<Vec<u8>>,
) -> Result<(serde_json::Value, Result<(), String>), String> {
    let server = start_server(certificate, key)?;
    let url = format!("https://localhost:{}/resource", server.address.port());
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| error.to_string())?;
    let reply = runtime.block_on(send_with_resolver(
        request(url),
        LoopbackResolver(server.address),
        true,
        TlsConfiguration::from_host_roots(roots),
    ));
    Ok((reply, server.wait()))
}

#[test]
fn accepts_a_valid_host_certificate_from_a_declared_test_root() -> Result<(), String> {
    let certificate = include_bytes!("../tests/fixtures/tls/valid_certificate.pem");
    let key = include_bytes!("../tests/fixtures/tls/valid_key.pem");
    let (reply, server_result) = send_tls(certificate, key, vec![ROOT_CERTIFICATE.to_vec()])?;
    assert_eq!(reply["outcome"], "committed");
    assert_eq!(reply.pointer("/value/value/status"), Some(&json!(200)));
    server_result
}

#[test]
fn rejects_expired_wrong_host_and_untrusted_self_signed_certificates() -> Result<(), String> {
    let cases = [
        (
            include_bytes!("../tests/fixtures/tls/expired_certificate.pem").as_slice(),
            include_bytes!("../tests/fixtures/tls/expired_key.pem").as_slice(),
            vec![ROOT_CERTIFICATE.to_vec()],
        ),
        (
            include_bytes!("../tests/fixtures/tls/wrong_host_certificate.pem").as_slice(),
            include_bytes!("../tests/fixtures/tls/wrong_host_key.pem").as_slice(),
            vec![ROOT_CERTIFICATE.to_vec()],
        ),
        (
            include_bytes!("../tests/fixtures/tls/self_signed_certificate.pem").as_slice(),
            include_bytes!("../tests/fixtures/tls/self_signed_key.pem").as_slice(),
            Vec::new(),
        ),
    ];
    for (certificate, key, roots) in cases {
        let (reply, _server_result) = send_tls(certificate, key, roots)?;
        assert_eq!(reply["outcome"], "failed");
        assert_eq!(
            reply.pointer("/value/code"),
            Some(&json!("certificado_invalido"))
        );
    }
    Ok(())
}

#[test]
fn ignores_the_https_proxy_environment_variable() -> Result<(), String> {
    if std::env::var_os(PROXY_CHILD_MARKER).is_some() {
        let certificate = include_bytes!("../tests/fixtures/tls/valid_certificate.pem");
        let key = include_bytes!("../tests/fixtures/tls/valid_key.pem");
        let (reply, server_result) = send_tls(certificate, key, vec![ROOT_CERTIFICATE.to_vec()])?;
        assert_eq!(reply["outcome"], "committed");
        return server_result;
    }
    run_proxy_child()
}

fn run_proxy_child() -> Result<(), String> {
    let proxy = TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    proxy
        .set_nonblocking(true)
        .map_err(|error| error.to_string())?;
    let proxy_url = format!(
        "http://{}",
        proxy.local_addr().map_err(|error| error.to_string())?
    );
    let executable = std::env::current_exe().map_err(|error| error.to_string())?;
    let output = Command::new(executable)
        .args([
            "--exact",
            "physical_network_tls_send_tests::ignores_the_https_proxy_environment_variable",
            "--nocapture",
        ])
        .env(PROXY_CHILD_MARKER, "1")
        .env("HTTPS_PROXY", &proxy_url)
        .env("https_proxy", &proxy_url)
        .env("NO_PROXY", "")
        .env("no_proxy", "")
        .output()
        .map_err(|error| error.to_string())?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(output.status.success(), "{stdout}{stderr}");
    assert!(proxy.accept().is_err());
    Ok(())
}
