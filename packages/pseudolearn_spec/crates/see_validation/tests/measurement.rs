mod contracts;
use serde_json::json;

fn blocks(protocol: &str) -> serde_json::Value {
    json!([
        {"kind":"regla","fields":{"id":"R1","fuerza":"DEBE","clase":"sistema","texto":"Protocolo.","verificacion":["M1"]}},
        {"kind":"medicion","fields":{"id":"M1","protocolo":protocol}}
    ])
}

#[test]
fn accepts_measurements_bound_to_a_protocol_rule() -> Result<(), String> {
    let corpus = contracts::corpus("PERF.PROTOCOL", blocks("PERF.PROTOCOL#R1"))?;
    assert!(see_validation::measurement::check(&corpus).is_empty());
    Ok(())
}

#[test]
fn rejects_unknown_protocol_rules_and_foreign_specifications() -> Result<(), String> {
    for (id, protocol) in [
        ("PERF.PROTOCOL", "PERF.PROTOCOL#R9"),
        ("PERF.PROTOCOL", ""),
        ("PERF.VM.THROUGHPUT", "PERF.PROTOCOL#R1"),
        ("PERF.PROTOCOL", "PERF.VM.THROUGHPUT#R1"),
    ] {
        let errors = see_validation::measurement::check(&contracts::corpus(id, blocks(protocol))?);
        assert!(
            errors
                .iter()
                .any(|error| error.starts_with("SEE-MEASUREMENT-PROTOCOL")),
            "{id} {protocol}"
        );
    }
    Ok(())
}
