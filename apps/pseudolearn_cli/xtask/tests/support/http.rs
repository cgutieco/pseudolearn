use std::fmt::Write as FormatWrite;
use std::io::{Read, Write};
use std::net::TcpStream;
use std::time::Duration;

pub struct HttpResponse {
    pub status: String,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}

pub fn send_request(
    address: &str,
    method: &str,
    path: &str,
    headers: &[(&str, &str)],
    body: &[u8],
) -> Result<HttpResponse, String> {
    let authority = address
        .strip_prefix("http://")
        .ok_or("The HTTP address has an unexpected scheme")?;
    let mut stream = TcpStream::connect(authority).map_err(|error| error.to_string())?;
    stream
        .set_read_timeout(Some(Duration::from_secs(5)))
        .map_err(|error| error.to_string())?;
    let mut request = format!("{method} {path} HTTP/1.1\r\nHost: {authority}\r\n");
    for (name, value) in headers {
        let _ = write!(request, "{name}: {value}\r\n");
    }
    let _ = write!(
        request,
        "Content-Length: {}\r\nConnection: close\r\n\r\n",
        body.len()
    );
    stream
        .write_all(request.as_bytes())
        .and_then(|()| stream.write_all(body))
        .map_err(|error| error.to_string())?;
    let mut response = Vec::new();
    stream
        .read_to_end(&mut response)
        .map_err(|error| error.to_string())?;
    parse_response(&response)
}

pub fn parse_response(bytes: &[u8]) -> Result<HttpResponse, String> {
    let separator = bytes
        .windows(4)
        .position(|window| window == b"\r\n\r\n")
        .ok_or("The server response has no header terminator")?;
    let header_bytes = bytes
        .get(..separator)
        .ok_or("The server response header is incomplete")?;
    let header_text = std::str::from_utf8(header_bytes).map_err(|error| error.to_string())?;
    let mut lines = header_text.lines();
    let status_line = lines
        .next()
        .ok_or("The server response has no status line")?;
    let status = status_line
        .split_whitespace()
        .nth(1)
        .ok_or("The server response has no status code")?
        .to_owned();
    let headers = lines
        .filter_map(|line| line.split_once(':'))
        .map(|(name, value)| (name.to_ascii_lowercase(), value.trim().to_owned()))
        .collect();
    let body_start = separator.saturating_add(4);
    let body = bytes
        .get(body_start..)
        .ok_or("The server response body is incomplete")?
        .to_vec();
    Ok(HttpResponse {
        status,
        headers,
        body,
    })
}

pub fn header<'response>(response: &'response HttpResponse, name: &str) -> Option<&'response str> {
    response
        .headers
        .iter()
        .find(|(header_name, _)| header_name == name)
        .map(|(_, value)| value.as_str())
}
