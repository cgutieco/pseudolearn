use super::validation::{pairs, records};
use serde_json::{Value, json};

fn samples() -> Vec<Value> {
    (0..30)
        .map(|iteration| {
            json!({"iteration":iteration,"native_first":iteration & 1 == 0,
        "native_nanoseconds":100,"ceiling_nanoseconds":100,"vm_nanoseconds":200})
        })
        .collect()
}

#[test]
fn complete_pairs_are_validated() -> Result<(), String> {
    pairs(&samples(), 0)
}

#[test]
fn missing_duplicate_nonfinite_and_wrong_order_samples_are_rejected() {
    let mut input = samples();
    input.pop();
    assert!(pairs(&input, 0).is_err());
    let mut input = samples();
    if let Some(sample) = input.last_mut() {
        sample["iteration"] = json!(0);
    }
    assert!(pairs(&input, 0).is_err());
    let mut input = samples();
    if let Some(sample) = input.first_mut() {
        sample["native_nanoseconds"] = Value::Null;
    }
    assert!(pairs(&input, 0).is_err());
    assert!(pairs(&samples(), 1).is_err());
    assert!(records(&[]).is_err());
}
