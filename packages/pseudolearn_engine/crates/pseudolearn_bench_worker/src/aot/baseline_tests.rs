use super::baseline::parse;
use serde_json::json;

fn machine() -> serde_json::Value {
    json!({"measurements": {"native/sieve/false": {"meanWallMicroseconds": 300.0}}})
}

#[test]
fn the_framed_native_ceiling_is_averaged_per_process() -> Result<(), String> {
    let ceiling = json!([
        {"variant":4,"workload":"sieve","family":"arrays","process":0,"nanoseconds":10.0},
        {"variant":4,"workload":"sieve","family":"arrays","process":0,"nanoseconds":20.0},
        {"variant":4,"workload":"sieve","family":"arrays","process":1,"nanoseconds":30.0},
        {"variant":5,"workload":"sieve","family":"arrays","process":0,"nanoseconds":999.0}
    ]);
    let references = parse(&ceiling, &machine())?;
    let sieve = references.get("sieve").ok_or("Missing sieve")?;
    assert_eq!(sieve.family, "arrays");
    assert_eq!(sieve.v1f_process_means, vec![15.0, 30.0]);
    assert_eq!(sieve.vm_microseconds, 300.0);
    Ok(())
}

#[test]
fn a_workload_without_a_virtual_machine_baseline_is_rejected() {
    let ceiling = json!([
        {"variant":4,"workload":"queens","family":"arrays","process":0,"nanoseconds":10.0}
    ]);
    assert!(parse(&ceiling, &machine()).is_err());
}

#[test]
fn malformed_ceiling_samples_are_rejected() {
    assert!(parse(&json!({}), &machine()).is_err());
    let missing_time = json!([{"variant":4,"workload":"sieve","family":"arrays","process":0}]);
    assert!(parse(&missing_time, &machine()).is_err());
}
