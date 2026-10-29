use crate::{EffectTape, ExecutionIdentity, ReproducibilityStatus, TapeEntry};
use std::collections::BTreeMap;

fn identity() -> ExecutionIdentity {
    ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: BTreeMap::new(),
        source_digest: String::new(),
        package_graph_digest: String::new(),
        profile: "en".to_owned(),
        seed: 0,
        statement_limit: None,
        permissions: vec!["red".to_owned()],
    }
}

#[test]
fn abandoned_network_send_marks_external_state_uncertain() {
    let mut tape = EffectTape::new(identity());
    tape.append(TapeEntry {
        effect_seq: 1,
        task_id: 1,
        delivery_seq: None,
        source_node_id: 1,
        capability_kind: "network".to_owned(),
        operation: "network_send".to_owned(),
        request_digest: "request".to_owned(),
        secret_reference: None,
        outcome: "abandoned".to_owned(),
        payload_bytes: Vec::new(),
        entry_hash: String::new(),
    });
    assert_eq!(tape.status, ReproducibilityStatus::UncertainExternalState);
}
