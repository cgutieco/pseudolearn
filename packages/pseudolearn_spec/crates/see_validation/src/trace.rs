use see_model::{Block, Corpus, field};
use serde_json::Value;

pub const ALPHABET_TERM: &str = "traceEvents";

pub fn catalog(value: &Value) -> Result<(), String> {
    let classes = value.as_object().ok_or("Invalid trace alphabet")?;
    if classes.is_empty() {
        return Err("Empty trace alphabet".to_owned());
    }
    for entry in classes.values() {
        let keys = entry
            .get("datos")
            .and_then(Value::as_array)
            .ok_or("Missing event data keys")?;
        if keys
            .iter()
            .any(|key| key.as_str().is_none_or(str::is_empty))
        {
            return Err("Invalid event data key".to_owned());
        }
    }
    Ok(())
}

pub fn alphabet(corpus: &Corpus) -> Option<&serde_json::Map<String, Value>> {
    corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .find(|block| block.kind == "definicion" && field(block, "termino") == ALPHABET_TERM)
        .and_then(|block| block.fields.get("valor"))
        .and_then(Value::as_object)
}

pub fn check(corpus: &Corpus) -> Vec<String> {
    let alphabet = alphabet(corpus);
    let mut errors = Vec::new();
    for block in corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
    {
        match block.kind.as_str() {
            "caso" => errors.extend(case_events(block, alphabet)),
            "instruccion" => errors.extend(instruction_observation(block, alphabet)),
            _ => (),
        }
    }
    errors
}

fn case_events(case: &Block, alphabet: Option<&serde_json::Map<String, Value>>) -> Vec<String> {
    let traced = field(case, "operacion") == "trace";
    let mut errors = Vec::new();
    for expected in crate::expectations::case_expectations(case) {
        let events = expected.get("eventos").and_then(Value::as_array);
        if traced && events.is_none() && expected.get("estado_en").is_none() {
            errors.push("SEE-SCHEMA: trace case requires events or state".to_owned());
        }
        if !traced && (events.is_some() || expected.get("estado_en").is_some()) {
            errors.push("SEE-TRACE-CLASS: events require trace operation".to_owned());
        }
        for event in events.into_iter().flatten() {
            errors.extend(event_class(event, alphabet));
        }
    }
    errors
}

fn event_class(event: &Value, alphabet: Option<&serde_json::Map<String, Value>>) -> Option<String> {
    let class = event.get("clase").and_then(Value::as_str).unwrap_or("");
    let Some(entry) = alphabet.and_then(|alphabet| alphabet.get(class)) else {
        return Some(format!("SEE-TRACE-CLASS: unknown event class {class}"));
    };
    let allowed = see_model::strings(entry.get("datos"));
    let unknown = event
        .get("datos")
        .and_then(Value::as_object)
        .into_iter()
        .flat_map(|values| values.keys())
        .find(|key| !allowed.contains(&key.as_str()));
    unknown.map(|key| format!("SEE-TRACE-CLASS: {class} has no data {key}"))
}

fn instruction_observation(
    instruction: &Block,
    alphabet: Option<&serde_json::Map<String, Value>>,
) -> Vec<String> {
    see_model::strings(instruction.fields.get("observacion"))
        .into_iter()
        .filter(|observation| !alphabet.is_some_and(|alphabet| alphabet.contains_key(*observation)))
        .map(|observation| format!("SEE-TRACE-CLASS: unknown observation {observation}"))
        .collect()
}
