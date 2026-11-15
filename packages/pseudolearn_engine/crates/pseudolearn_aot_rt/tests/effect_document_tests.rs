use pseudolearn_aot_rt::{EffectChannel, EffectInput, EffectOutput};
use serde_json::{Value, json};

fn identity(seed: i64) -> Value {
    json!({"limits":{},"source_digest":"abc","package_graph_digest":"none",
        "profile":"es","seed":seed,"statement_limit":null,})
}

fn live_input() -> Vec<u8> {
    json!({"host":{"clock":[7]},"identity":identity(1),
        "max_tape_bytes":null,"tape":null})
    .to_string()
    .into_bytes()
}

#[test]
fn live_input_builds_a_channel_with_configured_host() -> Result<(), String> {
    let channel = EffectInput::parse(&live_input())
        .ok_or("input rejected")?
        .into_channel(Vec::new())?;
    assert_eq!(channel.host_observation().0, 0);
    assert!(channel.failure().is_none());
    Ok(())
}

#[test]
fn malformed_input_is_rejected() {
    assert!(EffectInput::parse(b"not json").is_none());
    assert!(EffectInput::parse(b"{\"unknown\":1}").is_none());
}

#[test]
fn replay_with_another_identity_is_rejected_before_running() -> Result<(), String> {
    let recorded = EffectOutput::from_channel(&EffectChannel::standalone())
        .render()
        .ok_or("render failed")?;
    let tape = serde_json::from_slice::<Value>(&recorded).map_err(|error| error.to_string())?;
    let input = json!({"host":null,"identity":identity(2),"max_tape_bytes":null,
        "tape":tape.get("tape")})
    .to_string();
    let parsed = EffectInput::parse(input.as_bytes()).ok_or("input rejected")?;
    assert_eq!(
        parsed.into_channel(Vec::new()).err().as_deref(),
        Some("replay_identity_mismatch")
    );
    Ok(())
}

#[test]
fn rejected_output_carries_the_failure_code() -> Result<(), String> {
    let bytes = EffectOutput::rejected("replay_divergence".to_owned())
        .render()
        .ok_or("render failed")?;
    let document: Value = serde_json::from_slice(&bytes).map_err(|error| error.to_string())?;
    assert_eq!(
        document.get("replay_error"),
        Some(&json!("replay_divergence"))
    );
    assert_eq!(document.get("host_calls"), Some(&json!(0)));
    assert_eq!(document.get("exit_code"), None);
    Ok(())
}

#[test]
fn retired_host_authority_configuration_is_rejected() -> Result<(), String> {
    let input = json!({"host":{"permissions":[]},"identity":identity(1),
        "max_tape_bytes":null,"tape":null})
    .to_string();
    let parsed = EffectInput::parse(input.as_bytes()).ok_or("input rejected")?;
    assert!(parsed.into_channel(Vec::new()).is_err());
    Ok(())
}
