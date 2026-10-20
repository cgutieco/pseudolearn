use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_vm::{EventPayload, TraceClass, TraceEvent};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) fn encode(arguments: &Value) -> Result<Value, ApiError> {
    let events = arguments
        .get("events")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing events"))?;
    validate_events(events)?;
    match arguments.get("encoding").and_then(Value::as_str) {
        Some("json") => serde_json::to_string(&canonical_events(events))
            .map(Value::String)
            .map_err(serialization_failure),
        Some("binary") => Ok(json!(crate::event_binary::encode_binary(events)?)),
        _ => Err(usage("unsupported encoding")),
    }
}

pub(crate) fn decode(arguments: &Value) -> Result<Value, ApiError> {
    let encoded = arguments
        .get("encoded")
        .ok_or_else(|| usage("missing encoded events"))?;
    match arguments.get("encoding").and_then(Value::as_str) {
        Some("json") => decode_json(encoded),
        Some("binary") => {
            let bytes: Vec<u8> = serde_json::from_value(encoded.clone())
                .map_err(|error| usage(&error.to_string()))?;
            Ok(json!(crate::event_binary::decode_binary(&bytes)?))
        }
        _ => Err(usage("unsupported encoding")),
    }
}

fn decode_json(encoded: &Value) -> Result<Value, ApiError> {
    let text = encoded
        .as_str()
        .ok_or_else(|| usage("invalid JSON event batch"))?;
    let events: Vec<Value> =
        serde_json::from_str(text).map_err(|error| usage(&error.to_string()))?;
    validate_events(&events)?;
    Ok(json!(events))
}

fn validate_events(events: &[Value]) -> Result<(), ApiError> {
    for event in events {
        decode_event(event)?;
        validate_source(event)?;
    }
    Ok(())
}

fn canonical_events(events: &[Value]) -> Vec<Value> {
    events.iter().cloned().map(canonical_value).collect()
}

pub(super) fn canonical_value(value: Value) -> Value {
    match value {
        Value::Array(values) => Value::Array(values.into_iter().map(canonical_value).collect()),
        Value::Object(fields) => {
            let ordered = fields
                .into_iter()
                .map(|(key, value)| (key, canonical_value(value)))
                .collect::<BTreeMap<_, _>>();
            Value::Object(ordered.into_iter().collect())
        }
        value => value,
    }
}

pub(super) fn validate_source(event: &Value) -> Result<(), ApiError> {
    if event
        .get("source")
        .is_some_and(|source| !source.is_null() && !source.is_object())
    {
        return Err(usage("invalid event source"));
    }
    Ok(())
}

pub(super) fn decode_event(value: &Value) -> Result<TraceEvent, ApiError> {
    let class = value
        .get("class")
        .and_then(Value::as_str)
        .and_then(TraceClass::from_name)
        .ok_or_else(|| usage("invalid event class"))?;
    let number = |field| {
        value
            .get(field)
            .and_then(Value::as_u64)
            .and_then(|number| u32::try_from(number).ok())
            .ok_or_else(|| usage("invalid event position"))
    };
    Ok(TraceEvent {
        class,
        line: number("line")?,
        depth: number("depth")?,
        span: None,
        payload: payload(class, value.get("data"))?,
    })
}

fn payload(class: TraceClass, value: Option<&Value>) -> Result<Option<EventPayload>, ApiError> {
    let text = |name| {
        value
            .and_then(|value| value.get(name))
            .and_then(Value::as_str)
            .map(str::to_owned)
            .ok_or_else(|| usage("invalid event payload"))
    };
    Ok(match class {
        TraceClass::StatementEntered | TraceClass::StatementExited | TraceClass::InputRequested => {
            if value.is_some() {
                return Err(usage("unexpected event payload"));
            }
            None
        }
        TraceClass::Decision => Some(EventPayload::Decision {
            rama: text("rama")?,
            indice: value
                .and_then(|value| value.get("indice"))
                .and_then(Value::as_u64),
        }),
        TraceClass::Call => Some(EventPayload::Call {
            nombre: text("nombre")?,
        }),
        TraceClass::Return => Some(EventPayload::Return {
            nombre: text("nombre")?,
        }),
        TraceClass::Output => Some(EventPayload::Output {
            texto: text("texto")?,
        }),
        TraceClass::InputReceived => Some(EventPayload::InputReceived {
            texto: text("texto")?,
        }),
        TraceClass::Failure => Some(EventPayload::Failure {
            codigo: text("codigo")?,
        }),
    })
}

pub(super) fn serialization_failure(error: serde_json::Error) -> ApiError {
    ApiError::SerializationFailure(error.to_string())
}
