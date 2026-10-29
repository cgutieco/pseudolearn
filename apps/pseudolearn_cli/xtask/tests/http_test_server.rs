#[path = "support/process.rs"]
mod process;
#[path = "support/tls.rs"]
mod tls;

use process::{address, start_server};
use std::io::{BufRead, BufReader, Read, Write};
use std::process::{Command, Stdio};
use tls::tls_stream;

#[test]
fn http_test_server_rejects_non_loopback_bind_addresses() -> Result<(), String> {
    let output = Command::new(env!("CARGO_BIN_EXE_xtask"))
        .args(["http-test-server", "--bind", "0.0.0.0"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .map_err(|error| error.to_string())?;
    if output.status.success() {
        return Err("The test server accepted a non-loopback address".to_owned());
    }
    Ok(())
}

#[test]
fn http_test_server_serves_trusted_tls_and_rejects_invalid_certificates() -> Result<(), String> {
    let server = start_server("valid")?;
    let mut stream = tls_stream(&server, true, "127.0.0.1")?;
    let authority = address(&server, "https_address")?
        .strip_prefix("https://")
        .ok_or("The HTTPS address has an unexpected scheme")?
        .to_owned();
    stream
        .write_all(format!("GET /texto HTTP/1.1\r\nHost: {authority}\r\n\r\n").as_bytes())
        .map_err(|error| error.to_string())?;
    let mut response = BufReader::new(stream);
    let body = read_response_body(&mut response)?;
    if body != b"Hello from PseudoLearn test server\n" {
        return Err("The trusted TLS test server returned an unexpected body".to_owned());
    }
    for (certificate, trust_root, name) in [
        ("expired", true, "127.0.0.1"),
        ("wrong-host", true, "127.0.0.1"),
        ("self-signed", false, "127.0.0.1"),
    ] {
        let server = start_server(certificate)?;
        let mut stream = tls_stream(&server, trust_root, name)?;
        let authority = address(&server, "https_address")?
            .strip_prefix("https://")
            .ok_or("The HTTPS address has an unexpected scheme")?
            .to_owned();
        let _ = stream
            .write_all(format!("GET /texto HTTP/1.1\r\nHost: {authority}\r\n\r\n").as_bytes());
        let mut response = [0];
        if stream.read(&mut response).is_ok() {
            return Err(format!("The {certificate} test certificate was accepted"));
        }
    }
    Ok(())
}

fn read_response_body(stream: &mut BufReader<impl Read>) -> Result<Vec<u8>, String> {
    let mut line = String::new();
    stream
        .read_line(&mut line)
        .map_err(|error| error.to_string())?;
    let mut content_length = None;
    loop {
        line.clear();
        stream
            .read_line(&mut line)
            .map_err(|error| error.to_string())?;
        if line == "\r\n" {
            break;
        }
        if let Some((name, value)) = line.split_once(':')
            && name.eq_ignore_ascii_case("content-length")
        {
            content_length = Some(
                value
                    .trim()
                    .parse::<usize>()
                    .map_err(|error| error.to_string())?,
            );
        }
    }
    let length = content_length.ok_or("The TLS response has no content length")?;
    let mut body = Vec::new();
    body.try_reserve_exact(length)
        .map_err(|error| error.to_string())?;
    body.resize(length, 0);
    stream
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    Ok(body)
}
