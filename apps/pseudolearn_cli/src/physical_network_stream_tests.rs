use crate::physical_network_resolver::{AddressLookup, AddressResolver};
use crate::physical_network_send::{NetworkRequest, send_with_resolver};
use crate::physical_network_tls::TlsConfiguration;
use flate2::Compression;
use flate2::write::GzEncoder;
use serde_json::json;
use std::io::{self, Read, Write};
use std::net::{Ipv4Addr, SocketAddr, TcpListener, TcpStream};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

struct LoopbackResolver(SocketAddr);

impl AddressResolver for LoopbackResolver {
    fn resolve(&self, _hostname: &str, _port: u16) -> AddressLookup {
        AddressLookup::Addresses(vec![self.0])
    }
}

fn request(url: String, body_limit: u64, wire_limit: u64, timeout_nanos: i64) -> NetworkRequest {
    NetworkRequest {
        method: "GET".to_owned(),
        url,
        headers: Vec::new(),
        body: None,
        response_limit: Some(i64::try_from(body_limit).unwrap_or(i64::MAX)),
        timeout_nanos: Some(timeout_nanos),
        effective_response_limit: Some(body_limit),
        effective_timeout_nanos: u64::try_from(timeout_nanos).ok(),
        wire_limit: Some(wire_limit),
        headers_limit: Some(16),
        header_bytes_limit: Some(4096),
    }
}

fn response_server(
    body: Vec<u8>,
    compressed: bool,
    delay: Duration,
) -> Result<(SocketAddr, mpsc::Receiver<bool>), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let (sender, receiver) = mpsc::channel();
    thread::spawn(move || match listener.accept() {
        Ok((mut stream, _)) => {
            let accepted = stream
                .set_read_timeout(Some(Duration::from_secs(3)))
                .and_then(|()| read_request_headers(&mut stream))
                .is_ok();
            let _sent = sender.send(accepted);
            if accepted {
                let _responded = respond(&mut stream, &body, compressed, delay);
            }
        }
        Err(_) => {
            let _sent = sender.send(false);
        }
    });
    Ok((address, receiver))
}

fn respond(
    stream: &mut TcpStream,
    body: &[u8],
    compressed: bool,
    delay: Duration,
) -> io::Result<()> {
    thread::sleep(delay);
    let encoding = if compressed {
        "Content-Encoding: gzip\r\n"
    } else {
        ""
    };
    let headers = format!(
        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\n{}Connection: close\r\n\r\n",
        body.len(),
        encoding
    );
    stream.write_all(headers.as_bytes())?;
    stream.write_all(body)
}

fn read_request_headers(stream: &mut TcpStream) -> io::Result<()> {
    let mut received = Vec::new();
    let mut buffer = [0; 1024];
    while !received.windows(4).any(|window| window == b"\r\n\r\n") {
        let count = stream.read(&mut buffer)?;
        if count == 0 {
            return Err(io::Error::from(io::ErrorKind::UnexpectedEof));
        }
        received.extend_from_slice(&buffer[..count]);
    }
    Ok(())
}

fn send_request(request: NetworkRequest, address: SocketAddr) -> Result<serde_json::Value, String> {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| error.to_string())?;
    Ok(runtime.block_on(send_with_resolver(
        request,
        LoopbackResolver(address),
        true,
        TlsConfiguration::from_host_roots(Vec::new()),
    )))
}

fn await_request(receiver: &mpsc::Receiver<bool>) -> Result<bool, String> {
    receiver
        .recv_timeout(Duration::from_secs(3))
        .map_err(|error| error.to_string())
}

fn gzip(body: &[u8]) -> Result<Vec<u8>, String> {
    let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
    encoder.write_all(body).map_err(|error| error.to_string())?;
    encoder.finish().map_err(|error| error.to_string())
}

#[test]
fn limits_a_large_streamed_identity_response() -> Result<(), String> {
    let (address, accepted) = response_server(vec![b'x'; 1024], false, Duration::ZERO)?;
    let url = format!("http://localhost:{}/grande", address.port());
    let reply = send_request(request(url, 64, 2048, 2_000_000_000), address)?;
    assert_eq!(
        reply.pointer("/value/code"),
        Some(&json!("limite_excedido"))
    );
    assert!(await_request(&accepted)?);
    Ok(())
}

#[test]
fn limits_a_gzip_expansion_while_decoding_the_stream() -> Result<(), String> {
    let (address, accepted) = response_server(gzip(&vec![b'x'; 8192])?, true, Duration::ZERO)?;
    let url = format!("http://localhost:{}/bomba-gzip", address.port());
    let reply = send_request(request(url, 128, 4096, 2_000_000_000), address)?;
    assert_eq!(
        reply.pointer("/value/code"),
        Some(&json!("limite_excedido"))
    );
    assert!(await_request(&accepted)?);
    Ok(())
}

#[test]
fn times_out_a_slow_in_flight_response() -> Result<(), String> {
    let (address, accepted) = response_server(b"ok".to_vec(), false, Duration::from_millis(200))?;
    let url = format!("http://localhost:{}/lento", address.port());
    let reply = send_request(request(url, 64, 128, 20_000_000), address)?;
    assert_eq!(reply.pointer("/value/code"), Some(&json!("tiempo_agotado")));
    assert!(await_request(&accepted)?);
    Ok(())
}

#[test]
fn times_out_when_server_never_sends_a_response() -> Result<(), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let (sender, accepted) = mpsc::channel();
    thread::spawn(move || {
        let result = listener.accept().map(|(mut stream, _)| {
            stream
                .set_read_timeout(Some(Duration::from_secs(3)))
                .and_then(|()| read_request_headers(&mut stream))
                .map(|()| {
                    let _sent = sender.send(true);
                    let mut buffer = [0; 1024];
                    let _received = stream.read(&mut buffer);
                })
        });
        if result.is_err() {
            let _sent = sender.send(false);
        }
    });
    let url = format!("http://localhost:{}/never", address.port());
    let reply = send_request(request(url, 64, 128, 20_000_000), address)?;
    assert_eq!(reply.pointer("/value/code"), Some(&json!("tiempo_agotado")));
    assert!(await_request(&accepted)?);
    Ok(())
}
