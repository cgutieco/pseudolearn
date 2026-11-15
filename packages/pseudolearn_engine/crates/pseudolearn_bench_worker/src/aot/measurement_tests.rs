use super::measurement::{ITERATIONS, parse};

fn lines(count: u32) -> String {
    (0..count)
        .map(|iteration| format!("{}\n", u64::from(iteration).saturating_add(100)))
        .collect()
}

#[test]
fn a_complete_report_becomes_one_sample_per_iteration() -> Result<(), String> {
    let samples = parse("sieve", 3, &lines(ITERATIONS))?;
    assert_eq!(
        samples.len(),
        usize::try_from(ITERATIONS).map_err(|error| error.to_string())?
    );
    assert!(
        samples
            .iter()
            .all(|sample| sample.process == 3 && sample.workload == "sieve")
    );
    assert_eq!(
        samples.first().map(|sample| sample.nanoseconds),
        Some(100.0)
    );
    Ok(())
}

#[test]
fn a_short_report_is_rejected() {
    assert!(parse("sieve", 0, &lines(ITERATIONS - 1)).is_err());
}

#[test]
fn malformed_lines_are_rejected() {
    assert!(parse("sieve", 0, "not a number\n").is_err());
    assert!(parse("sieve", 0, "-5\n").is_err());
}
