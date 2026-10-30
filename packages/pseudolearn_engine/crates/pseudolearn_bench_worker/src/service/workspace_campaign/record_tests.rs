use crate::service::workspace_campaign::record::{RecordInput, build, validate, write_new};
use crate::service::workspace_campaign::scenario::Scenario;
use serde_json::{Value, json};

fn sample_record() -> Value {
    let samples = vec![1.5; 30];
    build(&RecordInput {
        load: "files-10",
        scenario: Scenario::BodyEdit,
        process: 3,
        machine: "macos-aarch64-8cpu",
        resolution_nanos: 41,
        digest: "abc".to_owned(),
        candidate_millis: &samples,
        control_millis: &samples,
    })
}

fn with(field: &str, value: Value) -> Value {
    let mut record = sample_record();
    if let Some(fields) = record.as_object_mut() {
        fields.insert(field.to_owned(), value);
    }
    record
}

#[test]
fn a_synthetic_record_with_full_provenance_validates() {
    assert_eq!(validate(&sample_record()), Ok(()));
}

#[test]
fn records_missing_provenance_or_samples_are_rejected() {
    assert!(validate(&with("protocol", json!("other/1"))).is_err());
    assert!(validate(&with("boundary", json!("host"))).is_err());
    assert!(validate(&with("seed", json!(7))).is_err());
    assert!(validate(&with("scenario", json!("unknown"))).is_err());
    assert!(validate(&with("clock_resolution_ns", json!("0"))).is_err());
    assert!(validate(&with("equivalent", json!(false))).is_err());
    assert!(validate(&with("samples_ms", json!(vec![1.0; 29]))).is_err());
    assert!(validate(&with("control_ms", json!(vec![-1.0; 30]))).is_err());
}

#[test]
fn writing_never_overwrites_an_existing_record() -> Result<(), String> {
    let directory = std::env::temp_dir().join(format!("pg-service-record-{}", std::process::id()));
    let path = directory.join("record.json");
    let _ = std::fs::remove_dir_all(&directory);
    write_new(&path, &sample_record())?;
    assert!(write_new(&path, &sample_record()).is_err());
    std::fs::remove_dir_all(&directory).map_err(|error| error.to_string())
}
