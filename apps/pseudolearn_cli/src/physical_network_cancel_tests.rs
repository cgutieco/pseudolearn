use super::{await_cancellable, network_failure};
use crate::physical_error::HostError;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};

#[test]
fn completed_operation_preserves_its_result() -> Result<(), Box<dyn std::error::Error>> {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?;
    assert_eq!(
        runtime.block_on(await_cancellable(std::future::ready(7), None)),
        Some(7)
    );
    Ok(())
}

#[test]
fn cancellation_drops_an_in_flight_future_within_the_host_budget()
-> Result<(), Box<dyn std::error::Error>> {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?;
    let cancellation = Arc::new(AtomicBool::new(false));
    let signal = cancellation.clone();
    let worker = std::thread::spawn(move || {
        std::thread::sleep(std::time::Duration::from_millis(10));
        signal.store(true, Ordering::SeqCst);
    });
    let started = std::time::Instant::now();
    let outcome = runtime.block_on(await_cancellable(
        std::future::pending::<()>(),
        Some(&cancellation),
    ));
    assert_eq!(outcome, None);
    assert!(started.elapsed() < std::time::Duration::from_millis(250));
    assert!(worker.join().is_ok());
    Ok(())
}

#[test]
fn cancelled_mutating_request_keeps_uncertainty_only_after_send() {
    let sent = AtomicBool::new(true);
    assert_eq!(
        network_failure(HostError::INTERRUPTED, &sent, "POST")["outcome"],
        "uncertain"
    );
    assert_eq!(
        network_failure(HostError::INTERRUPTED, &sent, "GET")["outcome"],
        "failed"
    );
    sent.store(false, Ordering::SeqCst);
    assert_eq!(
        network_failure(HostError::INTERRUPTED, &sent, "POST")["outcome"],
        "failed"
    );
}
