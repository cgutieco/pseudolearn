use pseudolearn_runtime::{
    EffectTape, ExecutionIdentity, ReplayError, TapeEntry, decode_effect_tape, delivery_order,
    encode_effect_tape, operation_may_write,
};

fn identity() -> ExecutionIdentity {
    ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
        source_digest: "abcd".to_owned(),
        package_graph_digest: "none".to_owned(),
        profile: "es".to_owned(),
        seed: 42,
        statement_limit: None,
        permissions: Vec::new(),
    }
}

fn entry(sequence: u64, kind: &str, operation: &str, outcome: &str) -> TapeEntry {
    TapeEntry {
        effect_seq: sequence,
        task_id: sequence,
        delivery_seq: None,
        source_node_id: 1,
        capability_kind: kind.to_owned(),
        operation: operation.to_owned(),
        request_digest: "digest".to_owned(),
        secret_reference: None,
        outcome: outcome.to_owned(),
        payload_bytes: Vec::new(),
        entry_hash: String::new(),
    }
}

fn reversed_tape() -> EffectTape {
    let mut tape = EffectTape::new(identity());
    for sequence in [3, 2, 1] {
        tape.append(entry(sequence, "timer", "request_timer", "committed"));
    }
    tape
}

#[test]
fn append_marks_only_entries_delivered_out_of_request_order() {
    let tape = reversed_tape();
    let marks: Vec<_> = tape
        .entries()
        .iter()
        .map(|entry| entry.delivery_seq)
        .collect();
    assert_eq!(marks, vec![Some(1), None, Some(3)]);
}

#[test]
fn out_of_order_tape_survives_an_encode_decode_round_trip() -> Result<(), ReplayError> {
    let tape = reversed_tape();
    let decoded = decode_effect_tape(&encode_effect_tape(&tape)?)?;
    assert_eq!(decoded.entries(), tape.entries());
    Ok(())
}

#[test]
fn decoding_rejects_a_forged_delivery_sequence() -> Result<(), ReplayError> {
    let mut tape = reversed_tape();
    if let Some(first) = tape.entries.first_mut() {
        first.delivery_seq = Some(2);
    }
    assert_eq!(
        decode_effect_tape(&encode_effect_tape(&tape)?),
        Err(ReplayError::CorruptedTape)
    );
    Ok(())
}

#[test]
fn decoding_rejects_duplicate_request_sequences() -> Result<(), ReplayError> {
    let mut tape = EffectTape::new(identity());
    tape.append(entry(1, "timer", "request_timer", "committed"));
    tape.append(entry(1, "timer", "request_timer", "committed"));
    assert_eq!(
        decode_effect_tape(&encode_effect_tape(&tape)?),
        Err(ReplayError::CorruptedTape)
    );
    Ok(())
}

#[test]
fn delivery_order_lists_request_ranks_in_delivery_order_and_skips_console_records() {
    let mut tape = EffectTape::new(identity());
    tape.append(entry(1, "console", "write", "committed"));
    tape.append(entry(4, "timer", "request_timer", "committed"));
    tape.append(entry(2, "timer", "request_timer", "committed"));
    tape.append(entry(3, "timer", "request_timer", "committed"));
    assert_eq!(delivery_order(&tape), vec![3, 1, 2]);
}

#[test]
fn delivery_order_of_an_empty_tape_is_empty() {
    assert!(delivery_order(&EffectTape::new(identity())).is_empty());
}

#[test]
fn abandoned_writes_make_the_state_uncertain_but_reads_do_not() {
    let mut read = EffectTape::new(identity());
    read.append(entry(1, "file", "file_read_bytes", "abandoned"));
    assert!(read.is_reproducible());
    let mut write = EffectTape::new(identity());
    write.append(entry(1, "file", "file_write_bytes", "abandoned"));
    assert!(!write.is_reproducible());
    assert!(operation_may_write("file_write_bytes"));
    assert!(!operation_may_write("request_timer"));
}
