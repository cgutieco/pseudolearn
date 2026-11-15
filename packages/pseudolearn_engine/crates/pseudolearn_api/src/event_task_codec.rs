use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_vm::{EventField, EventPayload, TraceClass};
use serde_json::Value;

#[derive(Clone, Copy)]
enum Kind {
    Number,
    Text,
    Flag,
}

type Schema = &'static [(&'static str, Kind)];

fn schema(class: TraceClass) -> Option<Schema> {
    Some(match class {
        TraceClass::TaskSpawned => &[
            ("task", Kind::Number),
            ("parent", Kind::Number),
            ("scope", Kind::Number),
        ],
        TraceClass::TaskSuspended => &[
            ("task", Kind::Number),
            ("cause", Kind::Text),
            ("target", Kind::Number),
        ],
        TraceClass::TaskReady => &[("task", Kind::Number), ("cause", Kind::Text)],
        TraceClass::TaskResumed => &[("task", Kind::Number)],
        TraceClass::TaskCompleted => &[("task", Kind::Number), ("outcome", Kind::Text)],
        TraceClass::TaskCancelRequested => &[
            ("task", Kind::Number),
            ("reason", Kind::Text),
            ("origin", Kind::Number),
        ],
        TraceClass::ScopeJoined => &[("task", Kind::Number), ("outcome", Kind::Text)],
        TraceClass::ChannelCreated => &[("channel", Kind::Number), ("capacity", Kind::Number)],
        TraceClass::ChannelSent | TraceClass::ChannelClosed => &[("channel", Kind::Number)],
        TraceClass::ChannelReceived => &[("channel", Kind::Number), ("present", Kind::Flag)],
        TraceClass::EffectDelivered => &[
            ("effect_seq", Kind::Number),
            ("delivery_seq", Kind::Number),
            ("task", Kind::Number),
        ],
        _ => return None,
    })
}

pub(crate) fn payload(
    class: TraceClass,
    body: Option<&Value>,
) -> Option<Result<EventPayload, ApiError>> {
    let fields = schema(class)?;
    Some(decode(fields, body))
}

fn decode(schema: Schema, body: Option<&Value>) -> Result<EventPayload, ApiError> {
    let object = body
        .and_then(Value::as_object)
        .filter(|object| object.len() == schema.len())
        .ok_or_else(|| usage("invalid event payload"))?;
    let mut decoded = Vec::with_capacity(schema.len());
    for (name, kind) in schema {
        let value = object
            .get(*name)
            .ok_or_else(|| usage("invalid event payload"))?;
        decoded.push((*name, field(*kind, value)?));
    }
    Ok(EventPayload::Fields(decoded))
}

fn field(kind: Kind, value: &Value) -> Result<EventField, ApiError> {
    match kind {
        Kind::Number => value.as_u64().map(EventField::Number),
        Kind::Text => value.as_str().map(|text| EventField::Text(text.to_owned())),
        Kind::Flag => value.as_bool().map(EventField::Flag),
    }
    .ok_or_else(|| usage("invalid event payload"))
}
