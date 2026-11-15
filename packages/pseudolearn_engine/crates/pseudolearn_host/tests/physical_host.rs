use pseudolearn_host::PhysicalHost;
use serde_json::{Value, json};
use std::io::{Read, Write};
use std::net::TcpListener;
use std::sync::atomic::Ordering;
use std::time::{Duration, Instant};

fn host() -> PhysicalHost {
    PhysicalHost::new(std::env::temp_dir(), vec!["".to_owned(), "á b".to_owned()])
}

fn effect(operation: &str, arguments: Value) -> Value {
    json!({"effect_seq":1,"operation":operation,"arguments":arguments,
        "receiver":null,"result_capability":null})
}

#[test]
fn arguments_preserve_empty_unicode_and_spaces() {
    let response = host().perform(&effect("arguments_values", json!([])));
    assert_eq!(response.pointer("/value/value"), Some(&json!(["", "á b"])));
}

#[test]
fn timer_waits_and_clock_reads_the_system_again() -> Result<(), String> {
    let mut host = host();
    let before = host.perform(&effect("clock_now", json!([])));
    let start = Instant::now();
    let after = host.perform(&effect(
        "timer_wait",
        json!([{"kind":"integer","value":10_000_000}]),
    ));
    assert!(start.elapsed() >= Duration::from_millis(10));
    assert!(
        after.pointer("/value/value").and_then(Value::as_i64)
            > before.pointer("/value/value").and_then(Value::as_i64)
    );
    assert_eq!(
        host.perform(&effect(
            "timer_wait",
            json!([{"kind":"integer","value":-1}])
        ))
        .get("outcome"),
        Some(&json!("failed"))
    );
    Ok(())
}

#[test]
fn cancelled_host_does_not_dispatch() {
    let mut host = host();
    host.cancellation().store(true, Ordering::SeqCst);
    assert_eq!(
        host.perform(&effect("clock_now", json!([])))
            .pointer("/value/code"),
        Some(&json!("interrumpido"))
    );
}

#[test]
fn real_loopback_response_needs_no_origin_configuration() -> Result<(), String> {
    let listener = TcpListener::bind("127.0.0.1:0").map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let server = std::thread::spawn(move || -> std::io::Result<()> {
        let (mut stream, _) = listener.accept()?;
        let mut request = [0_u8; 4096];
        let count = stream.read(&mut request)?;
        if count == 0 {
            return Err(std::io::Error::from(std::io::ErrorKind::UnexpectedEof));
        }
        stream.write_all(b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok")
    });
    let request = json!([{"kind":"http_request","value":{
        "method":"GET","url":format!("http://{address}/"), "headers":[["cookie","demo=1"]],
        "body":null,"effective_timeout_nanos":1_000_000_000
    }}]);
    let response = host().perform(&effect("network_send", request));
    assert_eq!(
        response.get("outcome"),
        Some(&json!("committed")),
        "{response}"
    );
    assert_eq!(response.pointer("/value/value/status"), Some(&json!(200)));
    assert_eq!(
        response.pointer("/value/value/body"),
        Some(&json!([111, 107]))
    );
    server
        .join()
        .map_err(|_| "server failed")?
        .map_err(|error| error.to_string())?;
    Ok(())
}
