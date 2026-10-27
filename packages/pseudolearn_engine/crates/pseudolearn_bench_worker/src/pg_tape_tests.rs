use crate::pg_tape_collect::{linearity, measure};
use crate::pg_tape_loads::{EFFECT_COUNTS, effect_loads, grows_linearly};
use serde_json::json;

#[test]
fn every_kind_and_count_has_a_load() {
    assert_eq!(effect_loads().len(), EFFECT_COUNTS.len() * 3);
}

#[test]
fn smallest_loads_complete_with_a_reproducible_tape_and_one_entry_per_effect() -> Result<(), String> {
    for load in effect_loads().iter().filter(|load| load.count == EFFECT_COUNTS[0]) {
        let record = measure(load)?;
        let entries = record
            .get("recorded_entries")
            .and_then(serde_json::Value::as_u64)
            .ok_or("entries")?;
        assert!(entries >= u64::from(load.count), "{}: {entries}", load.name);
        assert_eq!(record.get("reproducible"), Some(&json!(true)), "{}", load.name);
    }
    Ok(())
}

#[test]
fn linear_series_is_accepted() {
    assert!(grows_linearly(&[(100, 11_000), (1000, 101_000), (10_000, 1_001_000)]));
}

#[test]
fn quadratic_series_is_rejected() {
    assert!(!grows_linearly(&[(100, 10_000), (1000, 1_000_000), (10_000, 100_000_000)]));
}

#[test]
fn degenerate_series_are_rejected() {
    assert!(!grows_linearly(&[]));
    assert!(!grows_linearly(&[(100, 5), (100, 5), (100, 5)]));
    assert!(!grows_linearly(&[(100, 5), (1000, 5), (10_000, 5)]));
    assert!(!grows_linearly(&[(100, 50), (1000, 10), (10_000, 5)]));
}

#[test]
fn linearity_reports_each_kind_and_rejects_malformed_records() -> Result<(), String> {
    let records = vec![
        json!({"kind": "console", "recorded_entries": 100, "tape_bytes": 11_000}),
        json!({"kind": "console", "recorded_entries": 1000, "tape_bytes": 101_000}),
        json!({"kind": "console", "recorded_entries": 10_000, "tape_bytes": 1_001_000}),
    ];
    assert_eq!(linearity(&records)?.get("console"), Some(&true));
    assert!(linearity(&[json!({"kind": "console"})]).is_err());
    Ok(())
}
