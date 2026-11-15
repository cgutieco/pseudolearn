#[path = "support/http.rs"]
mod http;
#[path = "support/process.rs"]
mod process;

use http::{header, send_request};
use process::{address, start_server};
use std::io::{BufRead, BufReader, Read, Write};
use std::net::TcpStream;
use std::time::Duration;

#[test]
fn http_test_server_serves_the_loopback_route_matrix() -> Result<(), String> {
    let server = start_server("valid")?;
    let http_address = address(&server, "http_address")?;
    if !http_address.starts_with("http://127.0.0.1:") {
        return Err(format!("Unexpected HTTP bind address: {http_address}"));
    }
    let certificate = server
        .metadata
        .get("root_certificate")
        .and_then(serde_json::Value::as_str)
        .ok_or("Missing generated root certificate path")?;
    if !std::path::Path::new(certificate).is_file() {
        return Err("The test root certificate was not generated".to_owned());
    }
    let certificate_directory = server
        .metadata
        .get("certificate_directory")
        .and_then(serde_json::Value::as_str)
        .ok_or("Missing generated certificate directory")?;
    for file_name in [
        "valid.pem",
        "valid-key.pem",
        "expired.pem",
        "wrong-host.pem",
        "self-signed.pem",
    ] {
        if !std::path::Path::new(certificate_directory)
            .join(file_name)
            .is_file()
        {
            return Err(format!("Missing generated test certificate: {file_name}"));
        }
    }
    let text = send_request(&http_address, "GET", "/texto", &[], &[])?;
    assert_eq!(text.status, "200");
    assert_eq!(text.body, b"Hello from PseudoLearn test server\n");
    assert_eq!(header(&text, "access-control-allow-origin"), Some("*"));
    assert_eq!(
        send_request(&http_address, "GET", "/binario", &[], &[])?.body,
        [0, 255, 13, 10]
    );
    let empty = send_request(&http_address, "GET", "/vacio", &[], &[])?;
    assert_eq!(empty.status, "204");
    assert_eq!(empty.body.as_slice(), b"");
    for (path, status) in [("/estado/404", "404"), ("/estado/500", "500")] {
        assert_eq!(
            send_request(&http_address, "GET", path, &[], &[])?.status,
            status
        );
    }
    let echo = send_request(
        &http_address,
        "POST",
        "/eco",
        &[("x-probe", "present")],
        b"payload",
    )?;
    let echo_body = std::str::from_utf8(&echo.body).map_err(|error| error.to_string())?;
    assert!(echo_body.contains("method=POST\npath=/eco\n"));
    assert!(echo_body.contains("x-probe: present"));
    assert!(echo_body.ends_with("body:\npayload"));
    assert_eq!(header(&echo, "x-echo-method"), Some("POST"));
    assert_eq!(header(&echo, "x-echo-path"), Some("/eco"));
    for (path, location) in [
        ("/redireccion/mismo", "/texto".to_owned()),
        ("/redireccion/otro-origen", "https://localhost:".to_owned()),
        ("/redireccion/http", "http://127.0.0.1:".to_owned()),
    ] {
        let redirect = send_request(&http_address, "GET", path, &[], &[])?;
        assert_eq!(redirect.status, "302");
        assert!(header(&redirect, "location").is_some_and(|value| value.starts_with(&location)));
    }
    let large = send_request(&http_address, "GET", "/grande", &[], &[])?;
    assert_eq!(header(&large, "content-length"), Some("8388609"));
    let gzip = send_request(&http_address, "GET", "/bomba-gzip", &[], &[])?;
    assert_eq!(header(&gzip, "content-encoding"), Some("gzip"));
    assert_ne!(gzip.body.as_slice(), b"");
    let deep = send_request(&http_address, "GET", "/json-profundo", &[], &[])?;
    let expected_deep = format!("{}0{}", "[".repeat(65), "]".repeat(65));
    assert_eq!(deep.body, expected_deep.as_bytes());
    let many_headers = send_request(&http_address, "GET", "/cabeceras-muchas", &[], &[])?;
    assert_eq!(
        many_headers
            .headers
            .iter()
            .filter(|(name, _)| name.starts_with("x-test-"))
            .count(),
        65
    );
    for expected in ["1", "2"] {
        assert_eq!(
            send_request(&http_address, "GET", "/contador", &[], &[])?.body,
            expected.as_bytes()
        );
    }
    if send_request(&http_address, "POST", "/cerrar-a-mitad", &[], b"payload").is_ok() {
        return Err("The mid-body close route unexpectedly returned a response".to_owned());
    }
    Ok(())
}

#[test]
fn http_test_server_streams_infinite_and_delayed_routes() -> Result<(), String> {
    let server = start_server("valid")?;
    let authority = address(&server, "http_address")?
        .strip_prefix("http://")
        .ok_or("The HTTP address has an unexpected scheme")?
        .to_owned();
    let mut stream = TcpStream::connect(&authority).map_err(|error| error.to_string())?;
    stream
        .set_read_timeout(Some(Duration::from_secs(2)))
        .map_err(|error| error.to_string())?;
    stream
        .write_all(format!("GET /infinito HTTP/1.1\r\nHost: {authority}\r\n\r\n").as_bytes())
        .map_err(|error| error.to_string())?;
    let mut reader = BufReader::new(stream);
    let mut line = String::new();
    reader
        .read_line(&mut line)
        .map_err(|error| error.to_string())?;
    assert!(line.contains("200"));
    loop {
        line.clear();
        reader
            .read_line(&mut line)
            .map_err(|error| error.to_string())?;
        if line == "\r\n" || line.is_empty() {
            break;
        }
    }
    line.clear();
    reader
        .read_line(&mut line)
        .map_err(|error| error.to_string())?;
    assert_eq!(line, "1\r\n");
    drop(reader);
    let mut delayed = TcpStream::connect(&authority).map_err(|error| error.to_string())?;
    delayed
        .set_read_timeout(Some(Duration::from_millis(50)))
        .map_err(|error| error.to_string())?;
    delayed
        .write_all(format!("GET /lento HTTP/1.1\r\nHost: {authority}\r\n\r\n").as_bytes())
        .map_err(|error| error.to_string())?;
    let mut byte = [0];
    if delayed.read(&mut byte).is_ok() {
        return Err("The delayed route returned before the client deadline".to_owned());
    }
    Ok(())
}
