#![cfg(not(feature = "test-host"))]

use pseudolearn_aot_rt::AotHostProvider;
use pseudolearn_runtime::{
    HostCapability, HostEffectProvider, HostEffectRequest, HostReply, HostValue, HttpMethod,
    HttpRequestValue,
};
use std::io::{Read, Write};
use std::net::{Ipv4Addr, TcpListener};
use std::path::PathBuf;

const READ_WRITE: u8 = 3;

struct Scratch(PathBuf);

impl Drop for Scratch {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}

fn scratch(label: &str) -> Result<Scratch, String> {
    let directory = std::env::temp_dir().join(format!(
        "pseudolearn_provider_{label}_{}",
        std::process::id()
    ));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    Ok(Scratch(directory))
}

fn capability(slot: u32) -> HostCapability {
    HostCapability {
        slot,
        generation: 1,
        rights: READ_WRITE,
        kind: 0,
    }
}

fn request(
    operation: &str,
    receiver: Option<HostCapability>,
    arguments: Vec<HostValue>,
    result_capability: Option<HostCapability>,
) -> HostEffectRequest {
    HostEffectRequest {
        effect_seq: 1,
        operation: operation.to_owned(),
        receiver,
        arguments,
        result_capability,
        source_node_id: 0,
    }
}

fn text(value: &str) -> HostValue {
    HostValue::Text(value.to_owned())
}

fn open_directory(provider: &mut AotHostProvider, directory: &Scratch) -> HostReply {
    provider.perform(&request(
        "request_directory",
        None,
        vec![text(&directory.0.to_string_lossy())],
        Some(capability(1)),
    ))
}

fn open_file(provider: &mut AotHostProvider, (name, mode): (&str, &str), slot: u32) -> HostReply {
    provider.perform(&request(
        "file_open",
        Some(capability(1)),
        vec![text(name), text(mode)],
        Some(capability(slot)),
    ))
}

#[test]
fn a_file_written_in_a_real_directory_is_read_back() -> Result<(), String> {
    let directory = scratch("roundtrip")?;
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    assert!(matches!(
        open_directory(&mut provider, &directory),
        HostReply::Committed(_)
    ));
    assert!(matches!(
        open_file(&mut provider, ("note.txt", "write"), 2),
        HostReply::Committed(_)
    ));
    let written = provider.perform(&request(
        "file_write_text",
        Some(capability(2)),
        vec![text("hola")],
        None,
    ));
    assert!(matches!(written, HostReply::Committed(_)), "{written:?}");
    provider.perform(&request(
        "file_close",
        Some(capability(2)),
        Vec::new(),
        None,
    ));
    assert_eq!(
        std::fs::read_to_string(directory.0.join("note.txt")).map_err(|error| error.to_string())?,
        "hola"
    );
    assert!(matches!(
        open_file(&mut provider, ("note.txt", "read"), 3),
        HostReply::Committed(_)
    ));
    let read = provider.perform(&request(
        "file_read_text",
        Some(capability(3)),
        Vec::new(),
        None,
    ));
    assert_eq!(read, HostReply::Committed(text("hola")));
    Ok(())
}

#[test]
fn opening_a_missing_file_for_reading_fails() -> Result<(), String> {
    let directory = scratch("missing")?;
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    assert!(matches!(
        open_directory(&mut provider, &directory),
        HostReply::Committed(_)
    ));
    assert!(matches!(
        open_file(&mut provider, ("absent.txt", "read"), 2),
        HostReply::Failed(_)
    ));
    Ok(())
}

#[test]
fn requesting_a_directory_that_does_not_exist_fails() -> Result<(), String> {
    let directory = scratch("absent")?;
    let missing = Scratch(directory.0.join("nowhere"));
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    assert!(matches!(
        open_directory(&mut provider, &missing),
        HostReply::Failed(_)
    ));
    Ok(())
}

#[test]
fn the_process_arguments_reach_the_program() {
    let mut provider =
        AotHostProvider::with_arguments(vec!["uno".to_owned(), "dos tres".to_owned()]);
    assert_eq!(
        provider.perform(&request("arguments_values", None, Vec::new(), None)),
        HostReply::Committed(HostValue::TextList(vec![
            "uno".to_owned(),
            "dos tres".to_owned()
        ]))
    );
    assert_eq!(provider.calls, 1);
}

#[test]
fn the_real_clock_advances_across_a_timer_wait() -> Result<(), String> {
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    let before = provider.perform(&request("clock_now", None, Vec::new(), None));
    let waited = provider.perform(&request(
        "timer_wait",
        None,
        vec![HostValue::Integer(5_000_000)],
        None,
    ));
    match (before, waited) {
        (
            HostReply::Committed(HostValue::Integer(start)),
            HostReply::Committed(HostValue::Integer(end)),
        ) => {
            assert!(end >= start.saturating_add(5_000_000));
        }
        other => return Err(format!("{other:?}")),
    }
    let negative = provider.perform(&request(
        "timer_wait",
        None,
        vec![HostValue::Integer(-1)],
        None,
    ));
    assert!(matches!(negative, HostReply::Failed(_)));
    Ok(())
}

fn http_request(url: String) -> HostValue {
    HostValue::HttpRequest(HttpRequestValue {
        method: HttpMethod::Get,
        url,
        headers: Vec::new(),
        body: None,
        response_limit: Some(1024),
        timeout_nanos: Some(5_000_000_000),
        effective_response_limit: Some(1024),
        effective_timeout_nanos: Some(5_000_000_000),
        wire_limit: Some(4096),
        header_bytes_limit: Some(4096),
        headers_limit: Some(16),
    })
}

#[test]
fn an_http_request_to_a_loopback_server_returns_its_response() -> Result<(), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    std::thread::spawn(move || {
        if let Ok((mut stream, _)) = listener.accept() {
            let mut received = [0_u8; 2048];
            let _read = stream.read(&mut received);
            let _sent = stream
                .write_all(b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok");
        }
    });
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    let reply = provider.perform(&request(
        "network_send",
        None,
        vec![http_request(format!("http://{address}/status"))],
        None,
    ));
    let HostReply::Committed(HostValue::HttpResponse(response)) = reply else {
        return Err(format!("{reply:?}"));
    };
    assert_eq!(response.status, 200);
    assert_eq!(response.body, b"ok");
    Ok(())
}

#[test]
fn an_http_request_to_a_closed_port_fails() -> Result<(), String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    drop(listener);
    let mut provider = AotHostProvider::with_arguments(Vec::new());
    let reply = provider.perform(&request(
        "network_send",
        None,
        vec![http_request(format!("http://{address}/status"))],
        None,
    ));
    assert!(!matches!(reply, HostReply::Committed(_)), "{reply:?}");
    Ok(())
}
