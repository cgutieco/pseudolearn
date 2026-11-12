use serde_json::Value;
use std::io::{BufRead, Write};

const HEADER_LIMIT: usize = 8192;
const BODY_LIMIT: usize = 8 * 1024 * 1024;

pub fn write_message(client: &mut impl Write, message: &Value) -> Result<(), String> {
    let body = serde_json::to_vec(message).map_err(|error| error.to_string())?;
    client
        .write_all(format!("Content-Length: {}\r\n\r\n", body.len()).as_bytes())
        .and_then(|()| client.write_all(&body))
        .and_then(|()| client.flush())
        .map_err(|error| error.to_string())
}

pub fn read_message(server: &mut impl BufRead) -> Result<Option<Value>, String> {
    let Some(length) = read_content_length(server)? else {
        return Ok(None);
    };
    if length > BODY_LIMIT {
        return Err("response body exceeds limit".to_owned());
    }
    let mut body = vec![0; length];
    server
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    serde_json::from_slice(&body)
        .map(Some)
        .map_err(|error| error.to_string())
}

fn read_content_length(server: &mut impl BufRead) -> Result<Option<usize>, String> {
    let mut length = None;
    loop {
        let mut line = String::new();
        let read = server
            .read_line(&mut line)
            .map_err(|error| error.to_string())?;
        if read == 0 {
            return Ok(None);
        }
        if read > HEADER_LIMIT {
            return Err("response header exceeds limit".to_owned());
        }
        let trimmed = line.trim_end();
        if trimmed.is_empty() {
            return length
                .map(Some)
                .ok_or_else(|| "missing content length".to_owned());
        }
        if let Some(digits) = trimmed.strip_prefix("Content-Length: ") {
            length = Some(digits.parse::<usize>().map_err(|error| error.to_string())?);
        }
    }
}
