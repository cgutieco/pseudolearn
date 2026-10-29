use crate::physical_network_resolver::{AddressLookup, AddressResolver};
use crate::physical_network_send::{NetworkRequest, send_with_resolver};
use crate::physical_network_tls::TlsConfiguration;
use serde_json::json;
use std::io::{Read, Write};
use std::net::{Ipv4Addr, SocketAddr, TcpListener};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

struct LoopbackResolver(SocketAddr);

impl AddressResolver for LoopbackResolver {
    fn resolve(&self, _hostname: &str, _port: u16) -> AddressLookup {
        AddressLookup::Addresses(vec![self.0])
    }
}

struct DelayedResolver(Duration);

impl AddressResolver for DelayedResolver {
    fn resolve(&self, _hostname: &str, _port: u16) -> AddressLookup {
        thread::sleep(self.0);
        AddressLookup::Addresses(vec![SocketAddr::from((Ipv4Addr::LOCALHOST, 1))])
    }
}

fn request(method: &str) -> NetworkRequest {
    NetworkRequest {
        method: method.to_owned(),
        url: String::new(),
        headers: Vec::new(),
        body: (method != "GET").then(|| b"payload".to_vec()),
        response_limit: Some(1024),
        timeout_nanos: Some(2_000_000_000),
        effective_response_limit: Some(1024),
        effective_timeout_nanos: Some(2_000_000_000),
        wire_limit: Some(4096),
        headers_limit: Some(16),
        header_bytes_limit: Some(4096),
    }
}

fn server(
    close_after_request: bool,
    delay_response: bool,
) -> Result<(SocketAddr, mpsc::Receiver<(usize, bool)>), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let (connection_count_sender, connection_count_receiver) = mpsc::channel();
    thread::spawn(move || {
        let mut connections = 0;
        if let Ok((mut stream, _)) = listener.accept() {
            connections += 1;
            let _ = stream.set_read_timeout(Some(Duration::from_secs(3)));
            let mut request_bytes = Vec::new();
            let mut buffer = [0; 1024];
            while !request_bytes.windows(4).any(|window| window == b"\r\n\r\n") {
                match stream.read(&mut buffer) {
                    Ok(0) | Err(_) => break,
                    Ok(count) => request_bytes.extend_from_slice(&buffer[..count]),
                }
            }
            if !close_after_request && delay_response {
                thread::sleep(Duration::from_millis(100));
                let mut byte = [0; 1];
                let _ = stream.read(&mut byte);
                let _ = connection_count_sender.send((connections, true));
                return;
            }
            if !close_after_request && !delay_response {
                let _ = stream.write_all(
                    b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok",
                );
            }
        }
        let _ = connection_count_sender.send((connections, false));
    });
    Ok((address, connection_count_receiver))
}

fn run_send(request: NetworkRequest, address: SocketAddr) -> Result<serde_json::Value, String> {
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

#[test]
fn opens_exactly_one_connection_per_completed_send() -> Result<(), String> {
    for method in ["GET", "POST", "DELETE"] {
        let (address, connections) = server(false, false)?;
        let mut current = request(method);
        current.url = format!("http://localhost:{}/resource", address.port());
        let reply = run_send(current, address)?;
        assert_eq!(reply["outcome"], "committed", "{method}: {reply}");
        assert_eq!(connections.recv().map_err(|error| error.to_string())?.0, 1);
    }
    Ok(())
}

#[test]
fn records_uncertain_only_when_a_mutating_request_was_sent() -> Result<(), String> {
    for (method, expected) in [
        ("POST", "uncertain"),
        ("GET", "failed"),
        ("DELETE", "uncertain"),
    ] {
        let (address, connections) = server(true, false)?;
        let mut current = request(method);
        current.url = format!("http://localhost:{}/resource", address.port());
        let reply = run_send(current, address)?;
        assert_eq!(reply["outcome"], expected, "{method}: {reply}");
        assert_eq!(
            reply.pointer("/value/uncertain"),
            Some(&json!(expected == "uncertain"))
        );
        assert_eq!(connections.recv().map_err(|error| error.to_string())?.0, 1);
    }
    Ok(())
}

#[test]
fn connection_failure_before_http_bytes_is_certain() -> Result<(), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    drop(listener);
    let mut current = request("POST");
    current.url = format!("http://localhost:{}/resource", address.port());
    let reply = run_send(current, address)?;
    assert_eq!(reply["outcome"], "failed");
    assert_eq!(reply.pointer("/value/uncertain"), Some(&json!(false)));
    Ok(())
}

#[test]
fn aborting_an_in_flight_request_closes_its_single_connection() -> Result<(), String> {
    let (address, connections) = server(false, true)?;
    let mut current = request("POST");
    current.url = format!("http://localhost:{}/resource", address.port());
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| error.to_string())?;
    let task = runtime.spawn(send_with_resolver(
        current,
        LoopbackResolver(address),
        true,
        TlsConfiguration::from_host_roots(Vec::new()),
    ));
    runtime.block_on(async {
        tokio::time::sleep(Duration::from_millis(50)).await;
        task.abort();
    });
    assert_eq!(
        connections.recv().map_err(|error| error.to_string())?,
        (1, true)
    );
    Ok(())
}

#[test]
fn deadline_covers_name_resolution() -> Result<(), String> {
    let mut current = request("GET");
    current.url = "http://localhost/resource".to_owned();
    current.timeout_nanos = Some(1_000_000);
    current.effective_timeout_nanos = Some(1_000_000);
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|error| error.to_string())?;
    let reply = runtime.block_on(send_with_resolver(
        current,
        DelayedResolver(Duration::from_millis(50)),
        true,
        TlsConfiguration::from_host_roots(Vec::new()),
    ));
    assert_eq!(reply["outcome"], "failed");
    assert_eq!(reply.pointer("/value/code"), Some(&json!("tiempo_agotado")));
    Ok(())
}

#[test]
fn rejects_redirects_as_responses_without_following_them() -> Result<(), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    thread::spawn(move || {
        if let Ok((mut stream, _)) = listener.accept() {
            let _ = stream.set_read_timeout(Some(Duration::from_secs(3)));
            let mut bytes = [0; 1024];
            let _ = stream.read(&mut bytes);
            let _ = stream.write_all(b"HTTP/1.1 302 Found\r\nLocation: http://127.0.0.1/other\r\nContent-Length: 0\r\nConnection: close\r\n\r\n");
        }
    });
    let mut current = request("GET");
    current.url = format!("http://localhost:{}/resource", address.port());
    let reply = run_send(current, address)?;
    assert_eq!(reply["outcome"], "committed");
    assert_eq!(reply.pointer("/value/value/status"), Some(&json!(302)));
    Ok(())
}
