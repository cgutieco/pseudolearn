use crate::http_test_server_certificates::ServerIdentity;
use crate::http_test_server_routes::{self, Request, Response, RouteContext};
use rustls::ServerConfig;
use rustls::pki_types::{CertificateDer, PrivateKeyDer, PrivatePkcs8KeyDer};
use rustls::server::ServerConnection;
use std::fmt::Write as FormatWrite;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::Arc;
use std::thread;

pub fn tls_configuration(identity: &ServerIdentity) -> Result<Arc<ServerConfig>, String> {
    let certificate = CertificateDer::from(identity.certificate_der.clone());
    let private_key =
        PrivateKeyDer::Pkcs8(PrivatePkcs8KeyDer::from(identity.private_key_der.clone()));
    ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(vec![certificate], private_key)
        .map(Arc::new)
        .map_err(|error| error.to_string())
}

pub fn serve_http(listener: &TcpListener, context: &Arc<RouteContext>) -> Result<(), String> {
    for incoming in listener.incoming() {
        let stream = incoming.map_err(|error| error.to_string())?;
        let context = Arc::clone(context);
        thread::Builder::new()
            .name("http-test-client".to_owned())
            .spawn(move || handle_connection(stream, &context))
            .map_err(|error| error.to_string())?;
    }
    Ok(())
}

pub fn serve_tls(
    listener: &TcpListener,
    configuration: &Arc<ServerConfig>,
    context: &Arc<RouteContext>,
) -> Result<(), String> {
    for incoming in listener.incoming() {
        let stream = incoming.map_err(|error| error.to_string())?;
        let configuration = Arc::clone(configuration);
        let context = Arc::clone(context);
        thread::Builder::new()
            .name("https-test-client".to_owned())
            .spawn(move || handle_tls_connection(stream, configuration, &context))
            .map_err(|error| error.to_string())?;
    }
    Ok(())
}

fn handle_tls_connection(
    stream: TcpStream,
    configuration: Arc<ServerConfig>,
    context: &RouteContext,
) {
    let Ok(connection) = ServerConnection::new(configuration) else {
        return;
    };
    let tls_stream = rustls::StreamOwned::new(connection, stream);
    handle_connection(tls_stream, context);
}

fn handle_connection<ConnectionStream>(mut stream: ConnectionStream, context: &RouteContext)
where
    ConnectionStream: Read + Write,
{
    let Ok(request) = read_request(&mut stream) else {
        return;
    };
    let request_method = request.method.clone();
    let Ok(response) = http_test_server_routes::respond(request, context) else {
        return;
    };
    if let Some(delay) = response.delay {
        thread::sleep(delay);
    }
    let _ = write_response(&mut stream, &response, &request_method);
}

fn read_request<RequestReader: Read>(stream: &mut RequestReader) -> Result<Request, String> {
    let mut reader = BufReader::new(stream);
    let mut lines = Vec::new();
    let mut total_bytes = 0_usize;
    loop {
        let mut line = Vec::new();
        let count = reader
            .read_until(b'\n', &mut line)
            .map_err(|error| error.to_string())?;
        if count == 0 {
            return Err("The client closed before sending request headers".to_owned());
        }
        total_bytes = total_bytes.saturating_add(count);
        if total_bytes > 65_536 {
            return Err("Request headers exceed the local test server limit".to_owned());
        }
        if line == b"\r\n" {
            break;
        }
        lines.push(line);
    }
    let (method, target) = request_line(&lines)?;
    let headers = request_headers(&lines)?;
    let body_bytes = content_length(&lines)?;
    let body = read_body(&mut reader, body_bytes)?;
    Ok(Request {
        method,
        target,
        headers,
        body,
    })
}

fn request_line(lines: &[Vec<u8>]) -> Result<(String, String), String> {
    let request_line = lines.first().ok_or("The request has no request line")?;
    let request_text = std::str::from_utf8(request_line).map_err(|error| error.to_string())?;
    let mut request_parts = request_text.split_whitespace();
    let method = request_parts
        .next()
        .ok_or("The request has no method")?
        .to_owned();
    let target = request_parts
        .next()
        .ok_or("The request has no path")?
        .to_owned();
    Ok((method, target))
}

fn read_body<RequestReader: Read>(
    reader: &mut RequestReader,
    body_bytes: usize,
) -> Result<Vec<u8>, String> {
    if body_bytes > 16 * 1024 * 1024 {
        return Err("The request body exceeds the local test server limit".to_owned());
    }
    let mut body = Vec::new();
    body.try_reserve_exact(body_bytes)
        .map_err(|error| error.to_string())?;
    body.resize(body_bytes, 0);
    reader
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    Ok(body)
}

fn request_headers(lines: &[Vec<u8>]) -> Result<Vec<(String, String)>, String> {
    let mut headers = Vec::new();
    for line in lines.iter().skip(1) {
        let text = std::str::from_utf8(line).map_err(|error| error.to_string())?;
        let Some((name, value)) = text.split_once(':') else {
            continue;
        };
        headers.push((name.to_ascii_lowercase(), value.trim().to_owned()));
    }
    Ok(headers)
}

fn content_length(lines: &[Vec<u8>]) -> Result<usize, String> {
    for line in lines.iter().skip(1) {
        let text = std::str::from_utf8(line).map_err(|error| error.to_string())?;
        let Some((name, value)) = text.split_once(':') else {
            continue;
        };
        if name.eq_ignore_ascii_case("content-length") {
            let parsed = value
                .trim()
                .parse::<u64>()
                .map_err(|error| error.to_string())?;
            return usize::try_from(parsed).map_err(|error| error.to_string());
        }
    }
    Ok(0)
}

fn write_response<ResponseWriter: Write>(
    stream: &mut ResponseWriter,
    response: &Response,
    request_method: &str,
) -> Result<(), String> {
    if response.close {
        return Ok(());
    }
    let reason = reason_phrase(response.status);
    let mut output = format!("HTTP/1.1 {} {reason}\r\n", response.status);
    output.push_str("Access-Control-Allow-Origin: *\r\n");
    output
        .push_str("Access-Control-Allow-Methods: GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS\r\n");
    output.push_str("Access-Control-Allow-Headers: *\r\n");
    output.push_str("Access-Control-Expose-Headers: x-echo-method, x-echo-path\r\n");
    if response.infinite {
        return write_infinite_response(stream, output);
    }
    for (name, value) in &response.headers {
        let _ = write!(output, "{name}: {value}\r\n");
    }
    let _ = write!(output, "Content-Length: {}\r\n", response.body.len());
    output.push_str("Connection: close\r\n\r\n");
    stream
        .write_all(output.as_bytes())
        .map_err(|error| error.to_string())?;
    if request_method != "HEAD" {
        stream
            .write_all(&response.body)
            .map_err(|error| error.to_string())?;
    }
    stream.flush().map_err(|error| error.to_string())
}

fn write_infinite_response<ResponseWriter: Write>(
    stream: &mut ResponseWriter,
    mut output: String,
) -> Result<(), String> {
    output.push_str("Transfer-Encoding: chunked\r\nConnection: close\r\n\r\n");
    stream
        .write_all(output.as_bytes())
        .map_err(|error| error.to_string())?;
    loop {
        if stream.write_all(b"1\r\nx\r\n").is_err() || stream.flush().is_err() {
            return Ok(());
        }
    }
}

fn reason_phrase(status: u16) -> &'static str {
    match status {
        200 => "OK",
        204 => "No Content",
        302 => "Found",
        404 => "Not Found",
        500 => "Internal Server Error",
        _ => "Test Response",
    }
}
