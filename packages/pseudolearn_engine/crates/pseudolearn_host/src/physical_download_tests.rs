use crate::physical_download::{DownloadError, DownloadRequest, download_to_file};
use crate::physical_network_tls::TlsConfiguration;
use std::io::{Read, Write};
use std::net::{Ipv4Addr, SocketAddr, TcpListener};
use std::path::PathBuf;
use std::thread;
use std::time::Duration;

struct Scratch(PathBuf);

impl Drop for Scratch {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}

fn scratch(label: &str) -> Result<Scratch, String> {
    let directory = std::env::temp_dir().join(format!(
        "pseudolearn_download_{label}_{}",
        std::process::id()
    ));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    Ok(Scratch(directory))
}

fn serve(responses: Vec<Vec<u8>>) -> Result<SocketAddr, String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    thread::spawn(move || {
        for response in responses {
            let Ok((mut stream, _)) = listener.accept() else {
                return;
            };
            let _ = stream.set_read_timeout(Some(Duration::from_secs(3)));
            let mut received = Vec::new();
            let mut buffer = [0; 1024];
            while !received.windows(4).any(|window| window == b"\r\n\r\n") {
                match stream.read(&mut buffer) {
                    Ok(0) | Err(_) => break,
                    Ok(count) => received.extend_from_slice(buffer.get(..count).unwrap_or(&[])),
                }
            }
            let _ = stream.write_all(&response);
        }
    });
    Ok(address)
}

fn ok_response(body: &[u8]) -> Vec<u8> {
    let mut response = format!(
        "HTTP/1.1 200 OK\r\ncontent-length: {}\r\nconnection: close\r\n\r\n",
        body.len()
    )
    .into_bytes();
    response.extend_from_slice(body);
    response
}

fn redirect_response(location: &str) -> Vec<u8> {
    format!("HTTP/1.1 302 Found\r\nlocation: {location}\r\ncontent-length: 0\r\nconnection: close\r\n\r\n")
        .into_bytes()
}

fn request(url: String, byte_limit: u64) -> DownloadRequest {
    DownloadRequest {
        url,
        byte_limit,
        redirect_limit: 2,
        timeout: Duration::from_secs(5),
        user_agent: "pseudolearn-test".to_owned(),
    }
}

fn tls() -> TlsConfiguration {
    TlsConfiguration::from_host_roots(Vec::new())
}

#[test]
fn a_successful_response_is_stored_whole() -> Result<(), String> {
    let directory = scratch("ok")?;
    let address = serve(vec![ok_response(b"linker bytes")])?;
    let target = directory.0.join("asset");
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 64),
        &target,
        &tls(),
    );
    assert_eq!(stored, Ok(12));
    assert_eq!(
        std::fs::read(&target).map_err(|error| error.to_string())?,
        b"linker bytes"
    );
    Ok(())
}

#[test]
fn a_relative_redirect_is_followed_on_the_same_origin() -> Result<(), String> {
    let directory = scratch("redirect")?;
    let address = serve(vec![redirect_response("/final"), ok_response(b"moved")])?;
    let target = directory.0.join("asset");
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 64),
        &target,
        &tls(),
    );
    assert_eq!(stored, Ok(5));
    Ok(())
}

#[test]
fn a_missing_asset_reports_its_status() -> Result<(), String> {
    let directory = scratch("missing")?;
    let address = serve(vec![
        b"HTTP/1.1 404 Not Found\r\ncontent-length: 0\r\nconnection: close\r\n\r\n".to_vec(),
    ])?;
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 64),
        &directory.0.join("asset"),
        &tls(),
    );
    assert_eq!(stored, Err(DownloadError::Status(404)));
    Ok(())
}

#[test]
fn a_body_above_the_limit_is_rejected() -> Result<(), String> {
    let directory = scratch("large")?;
    let address = serve(vec![ok_response(b"0123456789")])?;
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 4),
        &directory.0.join("asset"),
        &tls(),
    );
    assert_eq!(stored, Err(DownloadError::TooLarge));
    Ok(())
}

#[test]
fn a_redirect_chain_longer_than_the_limit_stops() -> Result<(), String> {
    let directory = scratch("loop")?;
    let address = serve(vec![
        redirect_response("/a"),
        redirect_response("/b"),
        redirect_response("/c"),
    ])?;
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 64),
        &directory.0.join("asset"),
        &tls(),
    );
    assert_eq!(stored, Err(DownloadError::TooManyRedirects));
    Ok(())
}

#[test]
fn a_closed_port_is_unreachable() -> Result<(), String> {
    let directory = scratch("closed")?;
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    drop(listener);
    let stored = download_to_file(
        &request(format!("http://{address}/asset"), 64),
        &directory.0.join("asset"),
        &tls(),
    );
    assert_eq!(stored, Err(DownloadError::Unreachable));
    Ok(())
}

#[test]
fn a_non_http_address_is_invalid() -> Result<(), String> {
    let directory = scratch("invalid")?;
    let stored = download_to_file(
        &request("ftp://example.invalid/asset".to_owned(), 64),
        &directory.0.join("asset"),
        &tls(),
    );
    assert_eq!(stored, Err(DownloadError::InvalidAddress));
    Ok(())
}
