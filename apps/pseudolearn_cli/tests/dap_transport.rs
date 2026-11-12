use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Read, Write};
use std::process::{Command, Stdio};

fn frame(message: &Value) -> Vec<u8> {
    let body = message.to_string();
    let mut framed = format!("Content-Length: {}\r\n\r\n", body.len()).into_bytes();
    framed.extend_from_slice(body.as_bytes());
    framed
}

fn process(payload: &[u8]) -> Result<(i32, Vec<Value>), Box<dyn std::error::Error>> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("dap")
        .env_clear()
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()?;
    let mut input = child.stdin.take().ok_or("missing debug stdin")?;
    for chunk in payload.chunks(3) {
        if input.write_all(chunk).is_err() {
            break;
        }
    }
    drop(input);
    let output = child.wait_with_output()?;
    Ok((output.status.code().unwrap_or(-1), decode(&output.stdout)?))
}

fn decode(bytes: &[u8]) -> Result<Vec<Value>, Box<dyn std::error::Error>> {
    let mut reader = BufReader::new(bytes);
    let mut messages = Vec::new();
    loop {
        let mut header = String::new();
        if reader.read_line(&mut header)? == 0 {
            return Ok(messages);
        }
        let length: usize = header
            .strip_prefix("Content-Length: ")
            .ok_or("unexpected debug header")?
            .trim()
            .parse()?;
        let mut blank = String::new();
        reader.read_line(&mut blank)?;
        if blank != "\r\n" {
            return Err("invalid debug header terminator".into());
        }
        let mut payload = vec![0; length];
        reader.read_exact(&mut payload)?;
        messages.push(serde_json::from_slice(&payload)?);
    }
}

fn request(sequence: u64, command: &str) -> Value {
    json!({"seq":sequence,"type":"request","command":command})
}

#[test]
fn fragmented_transport_initializes_and_closes_exactly_once()
-> Result<(), Box<dyn std::error::Error>> {
    let payload = [
        frame(&request(1, "initialize")),
        frame(&request(2, "disconnect")),
    ]
    .concat();
    let (status, messages) = process(&payload)?;
    assert_eq!(status, 0);
    assert_eq!(
        messages
            .iter()
            .filter(|message| message["type"] == "response" && message["success"] == true)
            .count(),
        2
    );
    assert_eq!(
        messages
            .iter()
            .filter(|message| message["event"] == "terminated")
            .count(),
        1
    );
    assert!(
        messages
            .iter()
            .map(|message| message["seq"].as_u64())
            .collect::<Option<Vec<_>>>()
            .is_some_and(|sequence| sequence.windows(2).all(|pair| pair.first() < pair.get(1)))
    );
    Ok(())
}

#[test]
fn invalid_lifecycle_and_utf8_requests_remain_framed_values()
-> Result<(), Box<dyn std::error::Error>> {
    let payload = [
        frame(&request(1, "configurationDone")),
        frame(&request(2, "µ")),
        frame(&request(3, "disconnect")),
    ]
    .concat();
    let (status, messages) = process(&payload)?;
    assert_eq!(status, 0);
    assert_eq!(
        messages
            .iter()
            .filter(|message| message["success"] == false)
            .count(),
        2
    );
    assert!(messages.iter().any(|message| message["command"] == "µ"));
    Ok(())
}

#[test]
fn framing_rejects_invalid_lengths_and_abnormal_eof() -> Result<(), Box<dyn std::error::Error>> {
    for payload in [
        &b"Content-Length: -1\r\n\r\n"[..],
        &b"Content-Length: 1\r\nContent-Length: 1\r\n\r\n{}"[..],
        &b"Content-Length: 8388609\r\n\r\n"[..],
        &b"Content-Length: 2\r\n\r\n{"[..],
        &b"Content-Length: 1\r\n\r\nx"[..],
        &b""[..],
    ] {
        let (status, _) = process(payload)?;
        assert_eq!(status, 1);
    }
    Ok(())
}
