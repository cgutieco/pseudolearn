use crate::service::workspace_campaign::observation::observe;
use crate::service::workspace_campaign::test_support::{ScriptedTransport, SteppingClock};
use crate::service::workspace_campaign::wire::{change_document, workspace_symbols};

#[test]
fn observation_measures_with_the_injected_clock_and_collects_diagnostics() -> Result<(), String> {
    let mut transport = ScriptedTransport::new("warning");
    let mut clock = SteppingClock::new(5_000_000);
    let steps = [change_document("lib/m1", 2, "text"), workspace_symbols(9)];
    let observation = observe(&mut transport, &mut clock, &steps)?;
    assert_eq!(observation.nanos, 5_000_000);
    assert_eq!(observation.published.len(), 1);
    Ok(())
}

#[test]
fn observation_rejects_empty_steps_and_steps_without_a_final_request() {
    let mut clock = SteppingClock::new(1);
    let mut transport = ScriptedTransport::new("warning");
    assert!(observe(&mut transport, &mut clock, &[]).is_err());
    let only_notification = [change_document("lib/m1", 2, "text")];
    assert!(observe(&mut transport, &mut clock, &only_notification).is_err());
}

#[test]
fn observation_reports_a_closed_stream_instead_of_waiting_forever() {
    struct Closed;
    impl crate::service::workspace_campaign::transport::Transport for Closed {
        fn send(&mut self, _: &serde_json::Value) -> Result<(), String> {
            Ok(())
        }
        fn receive(&mut self) -> Result<serde_json::Value, String> {
            Err("server closed the stream".to_owned())
        }
    }
    let result = observe(
        &mut Closed,
        &mut SteppingClock::new(1),
        &[workspace_symbols(9)],
    );
    assert!(result.is_err());
}

#[test]
fn zero_duration_is_kept_as_zero_not_discarded() -> Result<(), String> {
    let mut transport = ScriptedTransport::new("warning");
    let observation = observe(
        &mut transport,
        &mut SteppingClock::new(0),
        &[workspace_symbols(9)],
    )?;
    assert_eq!(observation.nanos, 0);
    Ok(())
}
