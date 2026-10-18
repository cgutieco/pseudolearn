use super::baseline::Reference;
use super::summary::{Sample, SummaryInput, summarize};
use serde_json::json;
use std::collections::BTreeMap;

fn field_at(value: &serde_json::Value, path: &str) -> serde_json::Value {
    value
        .pointer(path)
        .cloned()
        .unwrap_or(serde_json::Value::Null)
}

fn reference(family: &str, ceiling: f64, machine_microseconds: f64) -> Reference {
    Reference {
        family: family.to_owned(),
        v1f_process_means: vec![ceiling, ceiling],
        vm_microseconds: machine_microseconds,
    }
}

fn samples(workload: &str, nanoseconds: f64) -> Vec<Sample> {
    (0..2)
        .flat_map(|process| {
            (0..3).map(move |_| Sample {
                workload: workload.to_owned(),
                process,
                nanoseconds,
            })
        })
        .collect()
}

fn run(native: f64, emission: f64) -> Result<serde_json::Value, String> {
    let references = BTreeMap::from([
        ("alpha".to_owned(), reference("numeric", 100.0, 1000.0)),
        ("beta".to_owned(), reference("numeric", 100.0, 1000.0)),
    ]);
    let mut all = samples("alpha", native);
    all.extend(samples("beta", native));
    let emissions = BTreeMap::from([
        ("alpha".to_owned(), emission),
        ("beta".to_owned(), emission),
    ]);
    summarize(&SummaryInput {
        samples: &all,
        references: &references,
        emission_milliseconds: &emissions,
    })
}

#[test]
fn a_native_level_within_the_threshold_reaches_the_target() -> Result<(), String> {
    let summary = run(120.0, 2.0)?;
    assert_eq!(field_at(&summary, "/targetReached"), json!(true));
    let ratio = field_at(&summary, "/families/numeric/ratio")
        .as_f64()
        .ok_or("ratio")?;
    assert!((ratio - 1.2).abs() < 1e-9);
    let speedup = field_at(&summary, "/minimumSpeedupOverMachine")
        .as_f64()
        .ok_or("speedup")?;
    assert!((speedup - 1000.0 * 1000.0 / 120.0).abs() < 1e-6);
    Ok(())
}

#[test]
fn a_family_above_the_threshold_fails_the_target_but_keeps_the_report() -> Result<(), String> {
    let summary = run(200.0, 2.0)?;
    assert_eq!(field_at(&summary, "/criteria/familiesPassed"), json!(false));
    assert_eq!(field_at(&summary, "/targetReached"), json!(false));
    assert_eq!(field_at(&summary, "/criteria/speedupPassed"), json!(true));
    Ok(())
}

#[test]
fn slow_emission_and_a_machine_that_wins_fail_their_own_criteria() -> Result<(), String> {
    let slow = run(120.0, 20.0)?;
    assert_eq!(field_at(&slow, "/criteria/emissionPassed"), json!(false));
    let references = BTreeMap::from([("alpha".to_owned(), reference("numeric", 100.0, 0.01))]);
    let emissions = BTreeMap::from([("alpha".to_owned(), 1.0)]);
    let summary = summarize(&SummaryInput {
        samples: &samples("alpha", 120.0),
        references: &references,
        emission_milliseconds: &emissions,
    })?;
    assert_eq!(field_at(&summary, "/criteria/speedupPassed"), json!(false));
    Ok(())
}

#[test]
fn the_confidence_interval_brackets_the_ratio_and_is_reproducible() -> Result<(), String> {
    let first = run(120.0, 2.0)?;
    let second = run(120.0, 2.0)?;
    assert_eq!(first, second);
    let interval = field_at(&first, "/families/numeric/confidence95");
    let low = field_at(&interval, "/0").as_f64().ok_or("low")?;
    let high = field_at(&interval, "/1").as_f64().ok_or("high")?;
    assert!(low <= 1.2 + 1e-9 && high >= 1.2 - 1e-9);
    Ok(())
}

#[test]
fn missing_samples_or_emission_times_are_rejected() {
    let references = BTreeMap::from([("alpha".to_owned(), reference("numeric", 100.0, 1000.0))]);
    let emissions = BTreeMap::from([("alpha".to_owned(), 1.0)]);
    let without_samples = summarize(&SummaryInput {
        samples: &[],
        references: &references,
        emission_milliseconds: &emissions,
    });
    assert!(without_samples.is_err());
    let without_emission = summarize(&SummaryInput {
        samples: &samples("alpha", 120.0),
        references: &references,
        emission_milliseconds: &BTreeMap::new(),
    });
    assert!(without_emission.is_err());
}
