use super::*;

fn tape_fixture(operation: &str) -> Value {
    json!({
        "effect_tape": {
            "entries": [
                {"entry_hash":"prior"},
                {
                    "effect_seq":2,
                    "task_id":0,
                    "source_node_id":9,
                    "capability_kind":"network",
                    "operation":operation,
                    "request_digest":"original",
                    "secret_reference":null,
                    "outcome":"committed",
                    "payload_bytes":[],
                    "entry_hash":"original-hash"
                }
            ]
        }
    })
}

#[test]
fn request_digest_alteration_rebuilds_the_final_entry_hash() -> Result<(), String> {
    let mut replay = tape_fixture("network_send");
    alter_request_digest(&mut replay)?;
    assert_eq!(
        replay.pointer("/effect_tape/entries/1/request_digest"),
        Some(&json!("altered-request-digest"))
    );
    assert_ne!(
        replay.pointer("/effect_tape/entries/1/entry_hash"),
        Some(&json!("original-hash"))
    );
    Ok(())
}

#[test]
fn request_digest_alteration_rejects_missing_or_non_http_entries() {
    let mut missing = json!({"effect_tape":{"entries":[]}});
    let mut non_http = tape_fixture("request_network");
    assert!(alter_request_digest(&mut missing).is_err());
    assert!(alter_request_digest(&mut non_http).is_err());
}
