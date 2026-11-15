use serde_json::Value;
use std::io::{BufRead, Write};

const HEADER_LIMIT: usize = 8192;
const BODY_LIMIT: usize = 64 * 1024 * 1024;

pub fn write_message(output: &mut impl Write, message: &Value) -> Result<(), String> {
    let body = serde_json::to_vec(message).map_err(|error| error.to_string())?;
    output
        .write_all(format!("Content-Length: {}\r\n\r\n", body.len()).as_bytes())
        .and_then(|()| output.write_all(&body))
        .and_then(|()| output.flush())
        .map_err(|error| error.to_string())
}

pub fn read_message(input: &mut impl BufRead) -> Result<Value, String> {
    let length = read_content_length(input)?;
    if length > BODY_LIMIT {
        return Err("response body exceeds the limit".to_owned());
    }
    let mut body = vec![0; length];
    input
        .read_exact(&mut body)
        .map_err(|error| error.to_string())?;
    serde_json::from_slice(&body).map_err(|error| error.to_string())
}

fn read_content_length(input: &mut impl BufRead) -> Result<usize, String> {
    let mut length = None;
    loop {
        let mut line = String::new();
        let read = input
            .read_line(&mut line)
            .map_err(|error| error.to_string())?;
        if read == 0 {
            return Err("server closed the stream".to_owned());
        }
        if read > HEADER_LIMIT {
            return Err("response header exceeds the limit".to_owned());
        }
        let trimmed = line.trim_end();
        if trimmed.is_empty() {
            return length.ok_or_else(|| "missing content length".to_owned());
        }
        if let Some(digits) = trimmed.strip_prefix("Content-Length: ") {
            length = Some(digits.parse().map_err(|_| "invalid content length")?);
        }
    }
}
