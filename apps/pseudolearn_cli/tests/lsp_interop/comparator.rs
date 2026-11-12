use crate::normalization::normalize;
use crate::transcript::Transcript;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Debug, PartialEq)]
pub enum Difference {
    MissingStep(u64),
    ExtraStep(u64),
    StepMismatch { step: u64, pointer: String },
    MissingDiagnostics(String),
    ExtraDiagnostics(String),
    DiagnosticsMismatch { uri: String, pointer: String },
}

pub fn compare(left: &Transcript, right: &Transcript) -> Vec<Difference> {
    let left = normalize(left);
    let right = normalize(right);
    let mut differences = compare_steps(&left, &right);
    differences.extend(compare_diagnostics(&left, &right));
    differences
}

fn compare_steps(left: &Transcript, right: &Transcript) -> Vec<Difference> {
    let left_steps = by_step(left);
    let right_steps = by_step(right);
    let mut differences = Vec::new();
    for (step, entry) in &left_steps {
        match right_steps.get(step) {
            None => differences.push(Difference::MissingStep(*step)),
            Some(other) => {
                if let Some(pointer) = first_difference(entry, other, "") {
                    differences.push(Difference::StepMismatch {
                        step: *step,
                        pointer,
                    });
                }
            }
        }
    }
    differences.extend(
        right_steps
            .keys()
            .filter(|step| !left_steps.contains_key(step))
            .map(|step| Difference::ExtraStep(*step)),
    );
    differences
}

fn compare_diagnostics(left: &Transcript, right: &Transcript) -> Vec<Difference> {
    let mut differences = Vec::new();
    for (uri, published) in &left.diagnostics {
        match right.diagnostics.get(uri) {
            None => differences.push(Difference::MissingDiagnostics(uri.clone())),
            Some(other) => {
                if let Some(pointer) = first_difference(published, other, "") {
                    differences.push(Difference::DiagnosticsMismatch {
                        uri: uri.clone(),
                        pointer,
                    });
                }
            }
        }
    }
    differences.extend(
        right
            .diagnostics
            .keys()
            .filter(|uri| !left.diagnostics.contains_key(*uri))
            .map(|uri| Difference::ExtraDiagnostics(uri.clone())),
    );
    differences
}

fn by_step(transcript: &Transcript) -> BTreeMap<u64, &Value> {
    transcript
        .steps
        .iter()
        .filter_map(|entry| Transcript::step_number(entry).map(|step| (step, entry)))
        .collect()
}

fn first_difference(left: &Value, right: &Value, pointer: &str) -> Option<String> {
    match (left, right) {
        (Value::Object(left_fields), Value::Object(right_fields)) => {
            object_difference(left_fields, right_fields, pointer)
        }
        (Value::Array(left_entries), Value::Array(right_entries)) => {
            array_difference(left_entries, right_entries, pointer)
        }
        _ => (left != right).then(|| pointer.to_owned()),
    }
}

fn object_difference(
    left: &serde_json::Map<String, Value>,
    right: &serde_json::Map<String, Value>,
    pointer: &str,
) -> Option<String> {
    let mut keys: Vec<&String> = left.keys().chain(right.keys()).collect();
    keys.sort();
    keys.dedup();
    keys.into_iter().find_map(|key| {
        let child = format!("{pointer}/{key}");
        match (left.get(key), right.get(key)) {
            (Some(one), Some(other)) => first_difference(one, other, &child),
            _ => Some(child),
        }
    })
}

fn array_difference(left: &[Value], right: &[Value], pointer: &str) -> Option<String> {
    if left.len() != right.len() {
        return Some(format!("{pointer}/length"));
    }
    left.iter()
        .zip(right)
        .enumerate()
        .find_map(|(index, (one, other))| {
            first_difference(one, other, &format!("{pointer}/{index}"))
        })
}
