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
    match arguments.get("encoding").and_then(Value::as_str) {
        Some("json") => {
            validate_events(events, 2)?;
            serde_json::to_string(&canonical_events(events))
                .map(Value::String)
                .map_err(serialization_failure)
        }
        Some("binary") => {
            let version = match arguments.get("version") {
                None => 2,
                Some(value) => value
                    .as_u64()
                    .and_then(|version| u16::try_from(version).ok())
                    .ok_or_else(|| usage("invalid wire version"))?,
            };
            validate_events(events, version)?;
            Ok(json!(crate::event_binary::encode_binary(events, version)?))
        }
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
    validate_events(&events, 2)?;
    Ok(json!(events))
}

fn validate_events(events: &[Value], version: u16) -> Result<(), ApiError> {
    for event in events {
        decode_event(event)?;
        validate_source_version(event, version)?;
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

pub(super) fn validate_source_version(event: &Value, version: u16) -> Result<(), ApiError> {
    let Some(source) = event.get("source") else {
        return Ok(());
    };
    if source.is_null() {
        return Ok(());
    }
    let Some(fields) = source.as_object() else {
        return Err(usage("invalid event source"));
    };
    if fields.get("revision_id").and_then(Value::as_str).is_none()
        || fields.get("node_id").and_then(Value::as_str).is_none()
        || fields.get("span").and_then(Value::as_object).is_none()
    {
        return Err(usage("invalid event source"));
    }
    let identity = fields.get("identity");
    if version == 1 && identity.is_some() {
        return Err(usage("source identity requires wire version 2"));
    }
    if let Some(identity) = identity {
        let Some(identity) = identity.as_object() else {
            return Err(usage("invalid event source identity"));
        };
        let project_id = identity.get("project_id").and_then(decimal_identifier);
        let revision_id = identity.get("revision_id").and_then(decimal_identifier);
        let source_id = identity.get("source_id").and_then(Value::as_u64);
        if !project_id.is_some_and(|value| value > 0)
            || !revision_id.is_some_and(|value| value > 0)
            || !source_id.is_some_and(|value| u32::try_from(value).is_ok_and(|id| id > 0))
        {
            return Err(usage("invalid event source identity"));
        }
    }
    Ok(())
}

fn decimal_identifier(value: &Value) -> Option<u64> {
    let text = value.as_str()?;
    let identifier = text.parse::<u64>().ok()?;
    (identifier.to_string() == text).then_some(identifier)
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
    if let Some(task_payload) = crate::event_task_codec::payload(class, value) {
        return task_payload.map(Some);
    }
    ordinary_payload(class, value)
}

fn ordinary_payload(
    class: TraceClass,
    value: Option<&Value>,
) -> Result<Option<EventPayload>, ApiError> {
    if matches!(
        class,
        TraceClass::Call
            | TraceClass::Return
            | TraceClass::Output
            | TraceClass::InputReceived
            | TraceClass::Failure
    ) {
        return text_payload(class, value);
    }
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
        _ => None,
    })
}

fn text_payload(
    class: TraceClass,
    value: Option<&Value>,
) -> Result<Option<EventPayload>, ApiError> {
    let field = match class {
        TraceClass::Call | TraceClass::Return => "nombre",
        TraceClass::Output | TraceClass::InputReceived => "texto",
        TraceClass::Failure => "codigo",
        _ => return Ok(None),
    };
    let text = value
        .and_then(|value| value.get(field))
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| usage("invalid event payload"))?;
    let payload = match class {
        TraceClass::Call => EventPayload::Call { nombre: text },
        TraceClass::Return => EventPayload::Return { nombre: text },
        TraceClass::Output => EventPayload::Output { texto: text },
        TraceClass::InputReceived => EventPayload::InputReceived { texto: text },
        TraceClass::Failure => EventPayload::Failure { codigo: text },
        _ => return Ok(None),
    };
    Ok(Some(payload))
}

pub(super) fn serialization_failure(error: serde_json::Error) -> ApiError {
    ApiError::SerializationFailure(error.to_string())
}
