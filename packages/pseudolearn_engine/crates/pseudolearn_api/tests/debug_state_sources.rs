use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str =
    "Algoritmo Probe\nDefinir value Como Entero <- 41;\nEscribir value + 1;\nFinAlgoritmo\n";

fn stopped_debug_state(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource")}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| started.to_string())?;
    session.call(
        "debug_configure",
        &json!({"resource":resource,"stop_on_entry":true,"breakpoints":[]}),
    );
    for _ in 0..100 {
        let response = session.call("advance", &json!({"resource":resource,"batch_size":64}));
        if response.pointer("/value/debug/stopped") == Some(&json!(true)) {
            return response
                .pointer("/value/debug")
                .cloned()
                .ok_or_else(|| response.to_string());
        }
    }
    Err("the execution never stopped".to_owned())
}

#[test]
fn a_debug_stop_lists_source_identities_without_their_text() -> Result<(), String> {
    let state = stopped_debug_state(PROGRAM)?;
    let sources = state
        .get("sources")
        .and_then(Value::as_array)
        .ok_or_else(|| state.to_string())?;
    assert!(!sources.is_empty(), "{state}");
    for source in sources {
        assert!(
            source.get("source_id").is_some_and(Value::is_u64),
            "{source}"
        );
        assert!(source.get("path").is_some(), "{source}");
        assert!(source.get("revision").is_some(), "{source}");
        assert!(source.get("text").is_none(), "{source}");
    }
    Ok(())
}

#[test]
fn a_debug_stop_does_not_grow_with_the_program_text() -> Result<(), String> {
    let short = stopped_debug_state(PROGRAM)?.to_string();
    let padded = format!("{PROGRAM}// {}\n", "x".repeat(20_000));
    let long = stopped_debug_state(&padded)?.to_string();
    assert!(
        long.len().abs_diff(short.len()) < 256,
        "{} vs {}",
        short.len(),
        long.len()
    );
    Ok(())
}
