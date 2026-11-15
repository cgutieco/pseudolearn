use serde_json::Value;
use std::io::{self, BufRead, Write};

const MAXIMUM_HEADER_BYTES: usize = 8 * 1024;
const MAXIMUM_BODY_BYTES: usize = 8 * 1024 * 1024;

pub(crate) fn read_next_payload<Reader: BufRead>(
    reader: &mut Reader,
) -> io::Result<Option<Vec<u8>>> {
    let Some(content_length) = read_headers(reader)? else {
        return Ok(None);
    };
    let mut body_payload = vec![0u8; content_length];
    reader.read_exact(&mut body_payload)?;
    Ok(Some(body_payload))
}

pub(crate) fn parse_lsp_message(body_payload: &[u8]) -> Result<Value, serde_json::Error> {
    serde_json::from_slice(body_payload)
}

pub(crate) fn send_lsp_response<Writer: Write>(
    standard_output: &mut Writer,
    response_json: &Value,
) -> Result<(), ()> {
    let response_string = serde_json::to_string(response_json).map_err(|_| ())?;
    let response_bytes = response_string.as_bytes();
    let header = format!("Content-Length: {}\r\n\r\n", response_bytes.len());
    standard_output
        .write_all(header.as_bytes())
        .map_err(|_| ())?;
    standard_output.write_all(response_bytes).map_err(|_| ())?;
    standard_output.flush().map_err(|_| ())
}

fn read_headers<Reader: BufRead>(reader: &mut Reader) -> io::Result<Option<usize>> {
    let mut header_bytes = 0usize;
    let mut content_length = None;
    loop {
        let remaining_bytes = MAXIMUM_HEADER_BYTES.saturating_sub(header_bytes);
        let Some(line) = read_header_line(reader, remaining_bytes)? else {
            return incomplete_headers(header_bytes);
        };
        header_bytes = header_bytes.saturating_add(line.len());
        let line = line.strip_suffix(b"\n").unwrap_or(&line);
        let line = line.strip_suffix(b"\r").unwrap_or(line);
        if line.is_empty() {
            return content_length.map(Some).ok_or_else(|| {
                io::Error::new(io::ErrorKind::InvalidData, "missing Content-Length")
            });
        }
        content_length = read_content_length(line, content_length)?;
    }
}

fn incomplete_headers(header_bytes: usize) -> io::Result<Option<usize>> {
    if header_bytes == 0 {
        return Ok(None);
    }
    Err(io::Error::new(
        io::ErrorKind::UnexpectedEof,
        "incomplete language server headers",
    ))
}

fn read_content_length(line: &[u8], current_length: Option<usize>) -> io::Result<Option<usize>> {
    let Some(separator_index) = line.iter().position(|byte| *byte == b':') else {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "malformed language server header",
        ));
    };
    let name = &line[..separator_index];
    if !name.eq_ignore_ascii_case(b"content-length") {
        return Ok(current_length);
    }
    if current_length.is_some() {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "duplicate Content-Length",
        ));
    }
    let value = trim_ascii_whitespace(&line[separator_index + 1..]);
    if value.is_empty() || !value.iter().all(u8::is_ascii_digit) {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "invalid Content-Length",
        ));
    }
    let parsed_length = std::str::from_utf8(value)
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "invalid Content-Length"))?
        .parse::<usize>()
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "invalid Content-Length"))?;
    if parsed_length > MAXIMUM_BODY_BYTES {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "language server body exceeds 8 MiB",
        ));
    }
    Ok(Some(parsed_length))
}

fn read_header_line<Reader: BufRead>(
    reader: &mut Reader,
    remaining_bytes: usize,
) -> io::Result<Option<Vec<u8>>> {
    let mut line = Vec::new();
    loop {
        let available_bytes = reader.fill_buf()?;
        if available_bytes.is_empty() {
            return incomplete_header_line(&line);
        }
        let bytes_to_consume = available_bytes
            .iter()
            .position(|byte| *byte == b'\n')
            .map_or(available_bytes.len(), |index| index + 1);
        if line.len().saturating_add(bytes_to_consume) > remaining_bytes {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "language server headers exceed 8 KiB",
            ));
        }
        let ends_line = available_bytes[..bytes_to_consume].last() == Some(&b'\n');
        line.extend_from_slice(&available_bytes[..bytes_to_consume]);
        reader.consume(bytes_to_consume);
        if ends_line {
            return Ok(Some(line));
        }
    }
}

fn incomplete_header_line(line: &[u8]) -> io::Result<Option<Vec<u8>>> {
    if line.is_empty() {
        return Ok(None);
    }
    Err(io::Error::new(
        io::ErrorKind::UnexpectedEof,
        "incomplete language server header line",
    ))
}

fn trim_ascii_whitespace(value: &[u8]) -> &[u8] {
    let first_non_whitespace = value
        .iter()
        .position(|byte| !byte.is_ascii_whitespace())
        .unwrap_or(value.len());
    let last_non_whitespace = value
        .iter()
        .rposition(|byte| !byte.is_ascii_whitespace())
        .map_or(first_non_whitespace, |index| index + 1);
    &value[first_non_whitespace..last_non_whitespace]
}
