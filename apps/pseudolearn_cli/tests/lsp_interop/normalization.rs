use crate::transcript::Transcript;
use serde_json::{Map, Value};

pub const NORMALIZED_ROOT: &str = "file:///ROOT/";

pub fn normalize(transcript: &Transcript) -> Transcript {
    let steps = transcript
        .steps
        .iter()
        .map(|entry| normalize_step(entry, &transcript.root))
        .collect();
    let diagnostics = transcript
        .diagnostics
        .iter()
        .map(|(uri, published)| {
            (
                uri.replace(&transcript.root, NORMALIZED_ROOT),
                replace_root(published, &transcript.root),
            )
        })
        .collect();
    Transcript {
        root: NORMALIZED_ROOT.to_owned(),
        steps,
        diagnostics,
    }
}

fn normalize_step(entry: &Value, root: &str) -> Value {
    let mut replaced = replace_root(entry, root);
    let step = Transcript::step_number(entry);
    let message = replaced.get_mut("message").and_then(Value::as_object_mut);
    if let (Some(number), Some(object)) = (step, message)
        && object.contains_key("id")
    {
        object.insert("id".to_owned(), Value::from(number));
    }
    replaced
}

fn replace_root(value: &Value, root: &str) -> Value {
    match value {
        Value::String(text) => Value::String(text.replace(root, NORMALIZED_ROOT)),
        Value::Array(entries) => Value::Array(
            entries
                .iter()
                .map(|entry| replace_root(entry, root))
                .collect(),
        ),
        Value::Object(fields) => {
            let mut replaced = Map::new();
            for (key, field) in fields {
                replaced.insert(
                    key.replace(root, NORMALIZED_ROOT),
                    replace_root(field, root),
                );
            }
            Value::Object(replaced)
        }
        other => other.clone(),
    }
}
