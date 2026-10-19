use crate::service::measurement_file::{Measurement, entry, record};
use serde_json::Value;

fn sample<'sample>(reference: &'sample str, comparator: &'sample str) -> Measurement<'sample> {
    Measurement {
        reference,
        metric: "latencia_p95",
        unit: "milisegundos",
        comparator,
    }
}

#[test]
fn entries_report_the_comparator_outcome() {
    let within = entry(&sample("A@1#M1", "<="), (50.0, 10.0));
    assert_eq!(within.get("status").and_then(Value::as_str), Some("cumple"));
    let above = entry(&sample("A@1#M1", "<="), (50.0, 60.0));
    assert_eq!(
        above.get("status").and_then(Value::as_str),
        Some("incumple")
    );
    let enough = entry(&sample("A@1#M2", ">="), (85.0, 90.0));
    assert_eq!(enough.get("status").and_then(Value::as_str), Some("cumple"));
    let short = entry(&sample("A@1#M2", ">="), (85.0, 80.0));
    assert_eq!(
        short.get("status").and_then(Value::as_str),
        Some("incumple")
    );
}

#[test]
fn recording_replaces_entries_with_the_same_reference_and_sorts() -> Result<(), String> {
    let path = std::env::temp_dir().join(format!("measurements-{}.json", std::process::id()));
    let location = path.to_string_lossy().into_owned();
    let _ = std::fs::remove_file(&path);
    record(&location, vec![entry(&sample("B@1#M1", "<="), (5.0, 9.0))])?;
    record(
        &location,
        vec![
            entry(&sample("A@1#M1", "<="), (5.0, 1.0)),
            entry(&sample("B@1#M1", "<="), (5.0, 2.0)),
        ],
    )?;
    let document: Value =
        serde_json::from_str(&std::fs::read_to_string(&path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let rows = document
        .get("measurements")
        .and_then(Value::as_array)
        .ok_or("Missing rows")?;
    let references: Vec<&str> = rows
        .iter()
        .filter_map(|row| row.get("reference").and_then(Value::as_str))
        .collect();
    assert_eq!(references, vec!["A@1#M1", "B@1#M1"]);
    assert_eq!(
        rows.get(1).and_then(|row| row.get("measured")),
        Some(&Value::from(2.0))
    );
    std::fs::remove_file(&path).map_err(|error| error.to_string())
}

#[test]
fn a_corrupt_measurement_file_is_an_error_not_an_overwrite() {
    let path = std::env::temp_dir().join(format!("corrupt-{}.json", std::process::id()));
    let _ = std::fs::write(&path, "not json");
    let outcome = record(&path.to_string_lossy(), Vec::new());
    assert!(outcome.is_err());
    let _ = std::fs::remove_file(&path);
}
