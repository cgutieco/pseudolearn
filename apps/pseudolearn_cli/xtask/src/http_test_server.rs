use crate::http_test_server_certificates::{ServerCertificates, ServerIdentity};
use crate::http_test_server_listener::{serve_http, serve_tls, tls_configuration};
use crate::http_test_server_routes::RouteContext;
use serde_json::json;
use std::net::{IpAddr, SocketAddr, TcpListener};
use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::thread;

struct ServerOptions {
    bind_address: IpAddr,
    certificate_kind: String,
}

struct ServerAnnouncement<'server> {
    plain_address: SocketAddr,
    tls_address: SocketAddr,
    certificates: &'server ServerCertificates,
    certificate_directory: &'server Path,
    certificate_kind: &'server str,
}

type ServerThread = thread::JoinHandle<Result<(), String>>;

pub fn run(arguments: &[String]) -> Result<(), String> {
    let options = parse_options(arguments)?;
    let certificate_directory = certificate_directory()?;
    let certificates = crate::http_test_server_certificates::generate(&certificate_directory)?;
    let identity = choose_identity(&certificates, &options.certificate_kind)?;
    let tls_config = tls_configuration(identity)?;
    let http_listener = bind_loopback(options.bind_address)?;
    let tls_listener = bind_loopback(options.bind_address)?;
    let plain_address = http_listener
        .local_addr()
        .map_err(|error| error.to_string())?;
    let tls_address = tls_listener
        .local_addr()
        .map_err(|error| error.to_string())?;
    let context = Arc::new(RouteContext::new(plain_address, tls_address));
    let (http_thread, tls_thread) =
        launch_listeners(http_listener, tls_listener, tls_config, &context)?;
    publish_addresses(&ServerAnnouncement {
        plain_address,
        tls_address,
        certificates: &certificates,
        certificate_directory: &certificate_directory,
        certificate_kind: &options.certificate_kind,
    })?;
    let http_result = http_thread
        .join()
        .map_err(|_| "The HTTP test server stopped unexpectedly".to_owned())?;
    let tls_result = tls_thread
        .join()
        .map_err(|_| "The HTTPS test server stopped unexpectedly".to_owned())?;
    http_result?;
    tls_result
}

fn launch_listeners(
    http_listener: TcpListener,
    tls_listener: TcpListener,
    tls_config: Arc<rustls::ServerConfig>,
    context: &Arc<RouteContext>,
) -> Result<(ServerThread, ServerThread), String> {
    let http_context = Arc::clone(context);
    let tls_context = Arc::clone(context);
    let http_thread = thread::Builder::new()
        .name("http-test-listener".to_owned())
        .spawn(move || serve_http(&http_listener, &http_context))
        .map_err(|error| error.to_string())?;
    let tls_thread = thread::Builder::new()
        .name("https-test-listener".to_owned())
        .spawn(move || serve_tls(&tls_listener, &tls_config, &tls_context))
        .map_err(|error| error.to_string())?;
    Ok((http_thread, tls_thread))
}

fn parse_options(arguments: &[String]) -> Result<ServerOptions, String> {
    let mut bind_address = IpAddr::V4(std::net::Ipv4Addr::LOCALHOST);
    let mut certificate_kind = "valid".to_owned();
    let mut position = 0;
    while let Some(option) = arguments.get(position) {
        position = position.saturating_add(1);
        match option.as_str() {
            "--bind" => {
                let value = arguments.get(position).ok_or("Missing value for --bind")?;
                position = position.saturating_add(1);
                bind_address = value.parse::<IpAddr>().map_err(|error| error.to_string())?;
                if !bind_address.is_loopback() {
                    return Err("The HTTP test server only accepts loopback addresses".to_owned());
                }
            }
            "--tls-certificate" => {
                let value = arguments
                    .get(position)
                    .ok_or("Missing value for --tls-certificate")?;
                position = position.saturating_add(1);
                if !["valid", "expired", "wrong-host", "self-signed"].contains(&value.as_str()) {
                    return Err("Unknown TLS test certificate".to_owned());
                }
                certificate_kind.clone_from(value);
            }
            _ => return Err("Unknown HTTP test server option".to_owned()),
        }
    }
    Ok(ServerOptions {
        bind_address,
        certificate_kind,
    })
}

fn choose_identity<'certificate>(
    certificates: &'certificate ServerCertificates,
    certificate_kind: &str,
) -> Result<&'certificate ServerIdentity, String> {
    match certificate_kind {
        "valid" => Ok(&certificates.valid),
        "expired" => Ok(&certificates.expired),
        "wrong-host" => Ok(&certificates.wrong_host),
        "self-signed" => Ok(&certificates.self_signed),
        _ => Err("Unknown TLS test certificate".to_owned()),
    }
}

fn bind_loopback(address: IpAddr) -> Result<TcpListener, String> {
    if !address.is_loopback() {
        return Err("The HTTP test server only accepts loopback addresses".to_owned());
    }
    TcpListener::bind(SocketAddr::new(address, 0)).map_err(|error| error.to_string())
}

fn certificate_directory() -> Result<PathBuf, String> {
    let cli_root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .ok_or("The CLI root directory is unavailable")?;
    Ok(cli_root
        .join("target")
        .join("http-test-server")
        .join(std::process::id().to_string()))
}

fn publish_addresses(announcement: &ServerAnnouncement<'_>) -> Result<(), String> {
    println!(
        "{}",
        json!({
            "http_address": format!("http://{}", announcement.plain_address),
            "https_address": format!("https://{}", announcement.tls_address),
            "certificate_directory": announcement.certificate_directory,
            "root_certificate": announcement.certificates.root_certificate_path,
            "tls_certificate": announcement.certificate_kind
        })
    );
    std::io::Write::flush(&mut std::io::stdout()).map_err(|error| error.to_string())
}
