use crate::LanguagePack;
use reference_model::{TraceLine, TraceRecord};
use serde_json::Value;

const SHOWN: [&str; 8] = [
    "statement_entered",
    "decision",
    "output",
    "call",
    "return",
    "failure",
    "input_requested",
    "input_received",
];

pub fn trace_lines(pack: &LanguagePack, records: &[TraceRecord]) -> Vec<TraceLine> {
    records
        .iter()
        .filter(|record| SHOWN.contains(&record.class.as_str()))
        .map(|record| TraceLine {
            line: record.line,
            class: record.class.clone(),
            detail: detail(pack, record),
        })
        .collect()
}

fn detail(pack: &LanguagePack, record: &TraceRecord) -> String {
    let label = pack.phrase(&format!("trace.{}", record.class));
    let fields: Value = serde_json::from_str(&record.detail).unwrap_or(Value::Null);
    let value = ["texto", "nombre", "rama", "codigo"]
        .iter()
        .find_map(|key| fields.get(*key).and_then(Value::as_str))
        .map(|text| text.trim_end_matches('\n').replace('\n', "\\n"));
    match value {
        Some(text) if record.class == "decision" => {
            format!("{label} · {}", pack.phrase(&format!("trace.branch.{text}")))
        }
        Some(text) => format!("{label} · {text}"),
        None => label,
    }
}
