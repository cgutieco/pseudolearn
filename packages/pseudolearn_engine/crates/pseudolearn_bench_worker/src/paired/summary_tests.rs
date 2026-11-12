use super::summary::summarize;
use serde_json::{Value, json};

fn input(native: u64) -> (Vec<Value>, Value) {
    let mut records = Vec::new();
    let mut emissions = serde_json::Map::new();
    for workload in [
        "sieve",
        "queens",
        "permute",
        "mandelbrot",
        "nbody",
        "towers",
        "list",
        "storage",
        "bounce",
        "richards",
    ] {
        emissions.insert(workload.to_owned(), json!(vec![1.0; 30]));
        for process in 0_u32..10 {
            let pairs: Vec<Value> = (0_u32..30)
                .map(|iteration| {
                    json!({"iteration":iteration,
                "native_first":(process.wrapping_add(iteration))&1 == 0,"native_nanoseconds":native,
                "ceiling_nanoseconds":100,"vm_nanoseconds":1000})
                })
                .collect();
            records.push(json!({"workload":workload,"process":process,"pairs":pairs}));
        }
    }
    (records, json!(emissions))
}

#[test]
fn all_families_must_pass_and_bootstrap_is_reproducible() -> Result<(), String> {
    let (records, emissions) = input(120);
    let first = summarize(&records, &emissions)?;
    assert_eq!(first.get("targetReached"), Some(&json!(true)));
    assert_eq!(first, summarize(&records, &emissions)?);
    let (records, emissions) = input(140);
    assert_eq!(
        summarize(&records, &emissions)?.get("targetReached"),
        Some(&json!(false))
    );
    Ok(())
}

#[test]
fn medians_do_not_become_means_when_one_sample_is_slow() -> Result<(), String> {
    let (mut records, emissions) = input(120);
    if let Some(record) = records.first_mut()
        && let Some(sample) = record
            .get_mut("pairs")
            .and_then(Value::as_array_mut)
            .and_then(|samples| samples.first_mut())
            .and_then(Value::as_object_mut)
    {
        sample.insert("native_nanoseconds".to_owned(), json!(100_000_000));
    }
    let summary = summarize(&records, &emissions)?;
    assert_eq!(summary.get("targetReached"), Some(&json!(true)));
    assert_eq!(summary.pointer("/workloads/sieve/ratio"), Some(&json!(1.2)));
    Ok(())
}

#[test]
fn missing_workloads_emissions_or_duplicate_processes_fail() {
    let (mut records, emissions) = input(120);
    records.pop();
    assert!(summarize(&records, &emissions).is_err());
    let (mut records, _) = input(120);
    assert!(summarize(&records, &json!({})).is_err());
    if let Some(first) = records.first().cloned()
        && let Some(last) = records.last_mut()
    {
        *last = first;
    }
    assert!(summarize(&records, &emissions).is_err());
}

#[test]
fn settlement_interval_uses_the_cranelift_level_without_reinterpreting_old_records()
-> Result<(), String> {
    let (mut records, emissions) = input(170);
    for record in &mut records {
        record
            .as_object_mut()
            .ok_or("Invalid test record")?
            .insert("measurementVersion".to_owned(), json!(2));
    }
    for record in &mut records {
        for pair in record
            .get_mut("pairs")
            .and_then(Value::as_array_mut)
            .ok_or("Missing pairs")?
        {
            pair.as_object_mut()
                .ok_or("Invalid pair")?
                .insert("native_entry_nanoseconds".to_owned(), json!(169));
        }
    }
    let report = summarize(&records, &emissions)?;
    assert_eq!(report.get("targetReached"), Some(&json!(true)));
    assert_eq!(report.get("threshold"), Some(&json!(1.7)));
    if let Some(record) = records.first_mut() {
        record
            .as_object_mut()
            .ok_or("Invalid test record")?
            .remove("measurementVersion");
    }
    assert!(summarize(&records, &emissions).is_err());
    let (records, emissions) = input(170);
    assert_eq!(
        summarize(&records, &emissions)?.get("targetReached"),
        Some(&json!(false))
    );
    Ok(())
}
