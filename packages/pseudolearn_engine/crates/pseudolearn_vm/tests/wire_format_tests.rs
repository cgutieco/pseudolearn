use pseudolearn_vm::{EventPayload, TraceClass, TraceEvent, decode_plev, encode_plev};

#[test]
fn encodes_and_decodes_empty_event_trace() {
    let empty_events: Vec<TraceEvent> = Vec::new();
    let encoded = encode_plev(&empty_events);
    let decoded = decode_plev(&encoded);
    assert_eq!(decoded, Ok(empty_events));
}

#[test]
fn encodes_and_decodes_all_trace_classes_and_payloads() {
    let events = vec![
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 1,
            depth: 1,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::StatementExited,
            line: 1,
            depth: 1,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::InputRequested,
            line: 2,
            depth: 1,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::InputReceived,
            line: 2,
            depth: 1,
            payload: Some(EventPayload::InputReceived {
                texto: "42".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::Decision,
            line: 3,
            depth: 1,
            payload: Some(EventPayload::Decision {
                rama: "verdadero".to_owned(),
                indice: None,
            }),
        },
        TraceEvent {
            class: TraceClass::Decision,
            line: 4,
            depth: 1,
            payload: Some(EventPayload::Decision {
                rama: "caso".to_owned(),
                indice: Some(2),
            }),
        },
        TraceEvent {
            class: TraceClass::Call,
            line: 5,
            depth: 1,
            payload: Some(EventPayload::Call {
                nombre: "calcular".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::Output,
            line: 6,
            depth: 2,
            payload: Some(EventPayload::Output {
                texto: "hola\n\"mundo\"".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::Return,
            line: 7,
            depth: 2,
            payload: Some(EventPayload::Return {
                nombre: "calcular".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::Failure,
            line: 8,
            depth: 1,
            payload: Some(EventPayload::Failure {
                codigo: "divisionByZero".to_owned(),
            }),
        },
    ];

    let encoded = encode_plev(&events);
    let decoded = decode_plev(&encoded);
    assert_eq!(decoded, Ok(events));
}

#[test]
fn rejects_short_header() {
    let short_bytes = *b"PLEV";
    let result = decode_plev(&short_bytes);
    assert!(result.is_err());
}

#[test]
fn rejects_invalid_signature() {
    let mut bytes = encode_plev(&[]);
    if let Some(first_byte) = bytes.get_mut(0) {
        *first_byte = b'X';
    }
    let result = decode_plev(&bytes);
    assert_eq!(result, Err("Invalid wire signature"));
}

#[test]
fn rejects_unsupported_version() {
    let mut bytes = encode_plev(&[]);
    if let Some(version_byte) = bytes.get_mut(4) {
        *version_byte = 99;
    }
    let result = decode_plev(&bytes);
    assert_eq!(result, Err("Unsupported wire version"));
}

#[test]
fn rejects_corrupted_pool_length() {
    let events = vec![TraceEvent {
        class: TraceClass::Output,
        line: 1,
        depth: 1,
        payload: Some(EventPayload::Output {
            texto: "mensaje".to_owned(),
        }),
    }];
    let mut bytes = encode_plev(&events);
    let last_position = bytes.len().saturating_sub(1);
    if let Some(last_byte) = bytes.get_mut(last_position) {
        *last_byte = b'!';
    }
    bytes.push(b'?');
    let result = decode_plev(&bytes);
    assert!(result.is_err());
}
