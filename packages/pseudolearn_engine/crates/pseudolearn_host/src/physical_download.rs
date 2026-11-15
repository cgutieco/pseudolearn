use crate::physical_network_resolver::{self, NetworkResolution, SystemAddressResolver};
use crate::physical_network_tls::TlsConfiguration;
use crate::physical_network_transport_support as support;
use bytes::Bytes;
use http::{Request, StatusCode, Uri, header};
use http_body_util::{BodyExt, Empty};
use hyper::client::conn::http1;
use hyper_util::rt::TokioIo;
use rustls::pki_types::ServerName;
use std::io::Write;
use std::net::SocketAddr;
use std::path::Path;
use std::time::Duration;
use tokio::io::{AsyncRead, AsyncWrite};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DownloadError {
    InvalidAddress,
    Unreachable,
    Status(u16),
    TooLarge,
    TooManyRedirects,
    TimedOut,
    Storage,
}

#[derive(Clone, Debug)]
pub struct DownloadRequest {
    pub url: String,
    pub byte_limit: u64,
    pub redirect_limit: u8,
    pub timeout: Duration,
    pub user_agent: String,
}

enum Fetched {
    Stored(u64),
    Redirect(String),
}

struct ConnectionTask(tokio::task::JoinHandle<()>);

impl Drop for ConnectionTask {
    fn drop(&mut self) {
        self.0.abort();
    }
}

pub fn download_to_file(
    request: &DownloadRequest,
    destination: &Path,
    tls: &TlsConfiguration,
) -> Result<u64, DownloadError> {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|_| DownloadError::Unreachable)?;
    runtime.block_on(async {
        tokio::time::timeout(request.timeout, follow(request, destination, tls))
            .await
            .map_err(|_| DownloadError::TimedOut)?
    })
}

async fn follow(
    request: &DownloadRequest,
    destination: &Path,
    tls: &TlsConfiguration,
) -> Result<u64, DownloadError> {
    let mut current =
        support::request_uri(&request.url).map_err(|_| DownloadError::InvalidAddress)?;
    for _ in 0..=request.redirect_limit {
        match fetch_once(&current, request, destination, tls).await? {
            Fetched::Stored(bytes) => return Ok(bytes),
            Fetched::Redirect(location) => current = next_location(&current, &location)?,
        }
    }
    Err(DownloadError::TooManyRedirects)
}

fn next_location(current: &Uri, location: &str) -> Result<Uri, DownloadError> {
    let absolute = if location.starts_with('/') {
        let scheme = current.scheme_str().ok_or(DownloadError::InvalidAddress)?;
        let authority = current.authority().ok_or(DownloadError::InvalidAddress)?;
        format!("{scheme}://{authority}{location}")
    } else {
        location.to_owned()
    };
    let next = support::request_uri(&absolute).map_err(|_| DownloadError::InvalidAddress)?;
    if current.scheme_str() == Some("https") && next.scheme_str() != Some("https") {
        return Err(DownloadError::InvalidAddress);
    }
    Ok(next)
}

async fn fetch_once(
    uri: &Uri,
    request: &DownloadRequest,
    destination: &Path,
    tls: &TlsConfiguration,
) -> Result<Fetched, DownloadError> {
    let hostname = uri.host().ok_or(DownloadError::InvalidAddress)?.to_owned();
    let port = uri.port_u16().unwrap_or_else(|| support::default_port(uri));
    let address = resolve(hostname.clone(), port).await?;
    let stream = tokio::net::TcpStream::connect(address)
        .await
        .map_err(|_| DownloadError::Unreachable)?;
    if uri.scheme_str() != Some("https") {
        return exchange(stream, uri, request, destination).await;
    }
    let connector = tls.connector().map_err(|_| DownloadError::Unreachable)?;
    let server_name = ServerName::try_from(hostname).map_err(|_| DownloadError::InvalidAddress)?;
    let secured = connector
        .connect(server_name, stream)
        .await
        .map_err(|_| DownloadError::Unreachable)?;
    exchange(secured, uri, request, destination).await
}

async fn resolve(hostname: String, port: u16) -> Result<SocketAddr, DownloadError> {
    let resolution = tokio::task::spawn_blocking(move || {
        physical_network_resolver::resolve_checked(&SystemAddressResolver, &hostname, port)
    })
    .await
    .map_err(|_| DownloadError::Unreachable)?;
    match resolution {
        NetworkResolution::Addresses(addresses) => {
            addresses.first().copied().ok_or(DownloadError::Unreachable)
        }
        NetworkResolution::InvalidHost => Err(DownloadError::InvalidAddress),
        NetworkResolution::ConnectionFailed => Err(DownloadError::Unreachable),
    }
}

async fn exchange<Stream>(
    stream: Stream,
    uri: &Uri,
    request: &DownloadRequest,
    destination: &Path,
) -> Result<Fetched, DownloadError>
where
    Stream: AsyncRead + AsyncWrite + Unpin + Send + 'static,
{
    let (mut sender, connection) = http1::handshake(TokioIo::new(stream))
        .await
        .map_err(|_| DownloadError::Unreachable)?;
    let _connection_task = ConnectionTask(tokio::spawn(async move {
        let _ = connection.await;
    }));
    let response = sender
        .send_request(outgoing(uri, &request.user_agent)?)
        .await
        .map_err(|_| DownloadError::Unreachable)?;
    let status = response.status();
    if status.is_redirection() {
        let location = response
            .headers()
            .get(header::LOCATION)
            .and_then(|value| value.to_str().ok())
            .ok_or(DownloadError::Status(status.as_u16()))?;
        return Ok(Fetched::Redirect(location.to_owned()));
    }
    if status != StatusCode::OK {
        return Err(DownloadError::Status(status.as_u16()));
    }
    store(response.into_body(), destination, request.byte_limit)
        .await
        .map(Fetched::Stored)
}

fn outgoing(uri: &Uri, user_agent: &str) -> Result<Request<Empty<Bytes>>, DownloadError> {
    let authority = uri
        .authority()
        .ok_or(DownloadError::InvalidAddress)?
        .as_str()
        .to_owned();
    let target = support::origin_form(uri).map_err(|_| DownloadError::InvalidAddress)?;
    Request::builder()
        .method(http::Method::GET)
        .uri(target)
        .header(header::HOST, authority)
        .header(header::USER_AGENT, user_agent)
        .header(header::CONNECTION, "close")
        .body(Empty::new())
        .map_err(|_| DownloadError::InvalidAddress)
}

async fn store(
    mut body: hyper::body::Incoming,
    destination: &Path,
    byte_limit: u64,
) -> Result<u64, DownloadError> {
    let mut file = std::fs::File::create(destination).map_err(|_| DownloadError::Storage)?;
    let mut total: u64 = 0;
    while let Some(frame) = body.frame().await {
        let frame = frame.map_err(|_| DownloadError::Unreachable)?;
        let Ok(chunk) = frame.into_data() else {
            continue;
        };
        total = u64::try_from(chunk.len())
            .ok()
            .and_then(|length| total.checked_add(length))
            .filter(|sum| *sum <= byte_limit)
            .ok_or(DownloadError::TooLarge)?;
        file.write_all(&chunk).map_err(|_| DownloadError::Storage)?;
    }
    file.flush().map_err(|_| DownloadError::Storage)?;
    Ok(total)
}
