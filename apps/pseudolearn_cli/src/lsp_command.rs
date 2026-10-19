use crate::options::CliOptions;
use pseudolearn_api::service::LspServer;
use std::io::{BufRead, BufReader, Write};

pub fn execute_lsp(options: &CliOptions) -> i32 {
    let mut server = LspServer::new();
    server.locale.clone_from(&options.interface_language);

    let standard_input = std::io::stdin();
    let mut reader = BufReader::new(standard_input.lock());
    let mut standard_output = std::io::stdout().lock();

    while let Some(body_payload) = read_next_payload(&mut reader) {
        let Ok(request_json) = serde_json::from_slice::<serde_json::Value>(&body_payload) else {
            continue;
        };

        let method_name = request_json
            .get("method")
            .and_then(serde_json::Value::as_str);

        if let Some(response_json) = server.handle_message(&request_json)
            && send_lsp_response(&mut standard_output, &response_json).is_err()
        {
            return 0;
        }

        if server.is_shutdown && method_name == Some("exit") {
            break;
        }
    }

    0
}

fn read_next_payload<Reader: BufRead>(reader: &mut Reader) -> Option<Vec<u8>> {
    let Ok(Some(content_length)) = read_headers(reader) else {
        return None;
    };
    let mut body_payload = vec![0u8; content_length];
    if reader.read_exact(&mut body_payload).is_err() {
        return None;
    }
    Some(body_payload)
}

fn send_lsp_response<Writer: Write>(
    standard_output: &mut Writer,
    response_json: &serde_json::Value,
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

fn read_headers<Reader: BufRead>(reader: &mut Reader) -> Result<Option<usize>, std::io::Error> {
    let mut content_length: Option<usize> = None;
    let mut line_buffer = String::new();

    loop {
        line_buffer.clear();
        let bytes_read = reader.read_line(&mut line_buffer)?;
        if bytes_read == 0 {
            return Ok(None);
        }
        let trimmed_line = line_buffer.trim();
        if trimmed_line.is_empty() {
            break;
        }
        if let Some(length_part) = trimmed_line.strip_prefix("Content-Length:")
            && let Ok(parsed_length) = length_part.trim().parse::<usize>()
        {
            content_length = Some(parsed_length);
        }
    }

    Ok(content_length)
}
