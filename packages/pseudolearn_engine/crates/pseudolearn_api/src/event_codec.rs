use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_vm::{EventPayload, TraceClass, TraceEvent, decode_plev, encode_plev};
use serde_json::{Value, json};

pub(crate) fn encode(arguments: &Value) -> Result<Value, ApiError> {
    let events = arguments
        .get("events")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing events"))?;
    let decoded = events
        .iter()
        .map(decode_event)
        .collect::<Result<Vec<_>, _>>()?;
    match arguments.get("encoding").and_then(Value::as_str) {
        Some("json") => serde_json::to_string(events)
            .map(Value::String)
            .map_err(|error| ApiError::SerializationFailure(error.to_string())),
        Some("binary") => Ok(json!(encode_plev(&decoded))),
        _ => Err(usage("unsupported encoding")),
    }
}

pub(crate) fn decode(arguments: &Value) -> Result<Value, ApiError> {
    let encoded = arguments
        .get("encoded")
        .ok_or_else(|| usage("missing encoded events"))?;
    let events = match arguments.get("encoding").and_then(Value::as_str) {
        Some("json") => {
            let events: Vec<Value> = serde_json::from_str(
                encoded
                    .as_str()
                    .ok_or_else(|| usage("invalid JSON event batch"))?,
            )
            .map_err(|error| usage(&error.to_string()))?;
            events
                .iter()
                .map(decode_event)
                .collect::<Result<Vec<_>, _>>()?
        }
        Some("binary") => {
            let bytes: Vec<u8> = serde_json::from_value(encoded.clone())
                .map_err(|error| usage(&error.to_string()))?;
            decode_plev(&bytes).map_err(|error| usage(&format!("{error:?}")))?
        }
        _ => return Err(usage("unsupported encoding")),
    };
    Ok(json!(
        events
            .iter()
            .map(crate::execution_wire::event)
            .collect::<Vec<_>>()
    ))
}

fn decode_event(value: &Value) -> Result<TraceEvent, ApiError> {
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
