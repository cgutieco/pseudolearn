use crate::transcript::Transcript;
use serde_json::Value;

const REFERENCE_TEXT: &str = include_str!("../fixtures/lsp_interop/transcript_reference.json");
pub const REFERENCE_ROOT: &str = "file:///tmp/clientA-1/";

pub fn reference_document() -> Result<Value, String> {
    serde_json::from_str(REFERENCE_TEXT).map_err(|error| error.to_string())
}

pub fn reference_transcript() -> Result<Transcript, String> {
    Transcript::from_value(REFERENCE_ROOT, &reference_document()?)
}

pub fn relocated_transcript(root: &str) -> Result<Transcript, String> {
    let text = REFERENCE_TEXT.replace(REFERENCE_ROOT, root);
    let document: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let mut transcript = Transcript::from_value(root, &document)?;
    for entry in &mut transcript.steps {
        let step = Transcript::step_number(entry).unwrap_or_default();
        if let Some(message) = entry.get_mut("message").and_then(Value::as_object_mut) {
            message.insert("id".to_owned(), Value::from(step + 1000));
        }
    }
    Ok(transcript)
}
