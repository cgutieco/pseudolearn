use crate::physical_error::HostError;
use crate::physical_network_resolver::{self, AddressResolver, NetworkResolution};
use crate::physical_network_send::NetworkRequest;
use crate::physical_network_tls::TlsConfiguration;
use crate::physical_network_transport_support::{self, TrackedIo};
use bytes::Bytes;
use http::{HeaderName, HeaderValue, Request, Uri};
use http_body_util::Full;
use hyper::client::conn::http1;
use hyper_util::rt::TokioIo;
use rustls::pki_types::ServerName;
use serde_json::{Value, json};
use std::net::SocketAddr;
use std::sync::Arc;
use std::sync::atomic::AtomicBool;
use std::time::Duration;
use tokio::io::{AsyncRead, AsyncWrite};
use tokio::task::JoinHandle;

struct ConnectionTask(JoinHandle<()>);

struct ResponseLimits {
    headers_count: usize,
    headers_bytes: usize,
    wire_bytes: usize,
    body_bytes: usize,
}

struct PreparedRequest {
    outgoing: Request<Full<Bytes>>,
    uri: Uri,
    limits: ResponseLimits,
}

pub(super) struct TransportOptions {
    pub(super) local_test_origin: bool,
    pub(super) tls_configuration: TlsConfiguration,
    pub(super) sent: Arc<AtomicBool>,
}

impl Drop for ConnectionTask {
    fn drop(&mut self) {
        self.0.abort();
    }
}

pub(super) fn request_timeout(request: &NetworkRequest) -> Result<Duration, HostError> {
    let nanos = request
        .effective_timeout_nanos
        .or_else(|| {
            request
                .timeout_nanos
                .and_then(|value| u64::try_from(value).ok())
        })
        .unwrap_or(30_000_000_000);
    if nanos == 0 {
        return Err(HostError::TIMED_OUT);
    }
    Ok(Duration::from_nanos(nanos))
}

pub(super) async fn send_once<Resolver: AddressResolver + Send + 'static>(
    request: NetworkRequest,
    resolver: Resolver,
    options: TransportOptions,
) -> Result<Value, HostError> {
    let uri = physical_network_transport_support::request_uri(&request.url)?;
    let prepared = PreparedRequest {
        limits: response_limits(&request)?,
        outgoing: build_request(&request, &uri)?,
        uri: uri.clone(),
    };
    let hostname = uri.host().ok_or(HostError::INVALID_PATH)?.to_owned();
    let port = uri
        .port_u16()
        .unwrap_or_else(|| physical_network_transport_support::default_port(&uri));
    let address =
        resolve_address(resolver, hostname.clone(), port, options.local_test_origin).await?;
    let stream = tokio::net::TcpStream::connect(address)
        .await
        .map_err(|_| HostError::INTERRUPTED)?;
    if uri.scheme_str() == Some("https") {
        let connector = options.tls_configuration.connector()?;
        let server_name = ServerName::try_from(hostname).map_err(|_| HostError::INVALID_PATH)?;
        let stream = connector
            .connect(server_name, stream)
            .await
            .map_err(|error| crate::physical_network_tls::classify_handshake_error(&error))?;
        send_over_stream(stream, prepared, options.sent).await
    } else {
        send_over_stream(stream, prepared, options.sent).await
    }
}

async fn resolve_address<Resolver: AddressResolver + Send + 'static>(
    resolver: Resolver,
    hostname: String,
    port: u16,
    local_test_origin: bool,
) -> Result<SocketAddr, HostError> {
    let resolution = tokio::task::spawn_blocking(move || {
        physical_network_resolver::resolve_checked(&resolver, &hostname, port, local_test_origin)
    })
    .await
    .map_err(|_| HostError::INTERRUPTED)?;
    match resolution {
        NetworkResolution::Addresses(addresses) => {
            addresses.first().copied().ok_or(HostError::INTERRUPTED)
        }
        other => Err(physical_network_transport_support::resolution_error(&other)),
    }
}

async fn send_over_stream<Stream>(
    stream: Stream,
    prepared: PreparedRequest,
    sent: Arc<AtomicBool>,
) -> Result<Value, HostError>
where
    Stream: AsyncRead + AsyncWrite + Unpin + Send + 'static,
{
    let PreparedRequest {
        outgoing,
        uri,
        limits,
    } = prepared;
    let mut connection = http1::Builder::new();
    connection.max_headers(limits.headers_count);
    let tracked = TrackedIo {
        inner: stream,
        sent: sent.clone(),
    };
    let (mut sender, connection_future) = connection
        .handshake(TokioIo::new(tracked))
        .await
        .map_err(|_| HostError::INTERRUPTED)?;
    let connection_task = ConnectionTask(tokio::spawn(async move {
        let _ = connection_future.await;
    }));
    let response = sender
        .send_request(outgoing)
        .await
        .map_err(|_| HostError::INTERRUPTED)?;
    let result = collect_response(response, uri, limits).await;
    drop(connection_task);
    result
}

async fn collect_response(
    response: http::Response<hyper::body::Incoming>,
    uri: Uri,
    limits: ResponseLimits,
) -> Result<Value, HostError> {
    let status = response.status().as_u16();
    let compressed = crate::physical_network_body::is_gzip(response.headers())?;
    let headers = response_headers(response.headers(), &limits)?;
    let body = crate::physical_network_body::collect(
        response.into_body(),
        limits.wire_bytes,
        limits.body_bytes,
        compressed,
    )
    .await?;
    Ok(json!({"status":status,"headers":headers,"body":body,"final_url":uri.to_string()}))
}

fn response_headers(
    response: &http::HeaderMap,
    limits: &ResponseLimits,
) -> Result<Vec<(String, String)>, HostError> {
    let headers = response
        .iter()
        .map(|(name, value)| {
            value
                .to_str()
                .map(|value| (name.to_string(), value.to_owned()))
                .map_err(|_| HostError::INTERRUPTED)
        })
        .collect::<Result<Vec<_>, _>>()?;
    let byte_count = headers.iter().try_fold(0_usize, |total, (name, value)| {
        total.checked_add(name.len())?.checked_add(value.len())
    });
    if headers.len() > limits.headers_count
        || byte_count.is_none_or(|bytes| bytes > limits.headers_bytes)
    {
        return Err(HostError::INTERRUPTED);
    }
    Ok(headers)
}

fn build_request(request: &NetworkRequest, uri: &Uri) -> Result<Request<Full<Bytes>>, HostError> {
    if !matches!(
        request.method.as_str(),
        "GET" | "HEAD" | "POST" | "PUT" | "PATCH" | "DELETE"
    ) {
        return Err(HostError::INVALID_PATH);
    }
    let method =
        http::Method::from_bytes(request.method.as_bytes()).map_err(|_| HostError::INVALID_PATH)?;
    let body = request.body.clone().unwrap_or_default();
    let wire_limit = physical_network_transport_support::limit(request.wire_limit, 8_388_608)?;
    if body.len() > wire_limit
        || request.headers.len()
            > physical_network_transport_support::limit(request.headers_limit, 64)?
    {
        return Err(HostError::INVALID_PATH);
    }
    let authority = uri
        .authority()
        .ok_or(HostError::INVALID_PATH)?
        .as_str()
        .to_owned();
    let target = physical_network_transport_support::origin_form(uri)?;
    let mut outgoing = Request::builder()
        .method(method)
        .uri(target)
        .header(http::header::CONNECTION, "close")
        .header(http::header::HOST, authority)
        .body(Full::new(Bytes::from(body)))
        .map_err(|_| HostError::INVALID_PATH)?;
    append_headers(&mut outgoing, &request.headers)?;
    validate_header_size(
        &outgoing,
        physical_network_transport_support::limit(request.header_bytes_limit, 16_384)?,
    )?;
    Ok(outgoing)
}

fn append_headers(
    request: &mut Request<Full<Bytes>>,
    headers: &[(String, String)],
) -> Result<(), HostError> {
    for (name, value) in headers {
        if physical_network_transport_support::is_reserved_header(name) {
            return Err(HostError::INVALID_PATH);
        }
        let name = HeaderName::from_bytes(name.as_bytes()).map_err(|_| HostError::INVALID_PATH)?;
        let value =
            HeaderValue::from_bytes(value.as_bytes()).map_err(|_| HostError::INVALID_PATH)?;
        request.headers_mut().append(name, value);
    }
    Ok(())
}

fn validate_header_size(request: &Request<Full<Bytes>>, limit: usize) -> Result<(), HostError> {
    let bytes = request
        .headers()
        .iter()
        .try_fold(0_usize, |total, (name, value)| {
            total
                .checked_add(name.as_str().len())?
                .checked_add(value.as_bytes().len())
        })
        .ok_or(HostError::INVALID_PATH)?;
    if bytes > limit {
        return Err(HostError::INVALID_PATH);
    }
    Ok(())
}

fn response_limits(request: &NetworkRequest) -> Result<ResponseLimits, HostError> {
    Ok(ResponseLimits {
        headers_count: physical_network_transport_support::limit(request.headers_limit, 64)?,
        headers_bytes: physical_network_transport_support::limit(
            request.header_bytes_limit,
            16_384,
        )?,
        wire_bytes: physical_network_transport_support::limit(request.wire_limit, 8_388_608)?,
        body_bytes: physical_network_transport_support::limit(
            request.effective_response_limit,
            request
                .response_limit
                .and_then(|value| u64::try_from(value).ok())
                .unwrap_or(8_388_608),
        )?,
    })
}
