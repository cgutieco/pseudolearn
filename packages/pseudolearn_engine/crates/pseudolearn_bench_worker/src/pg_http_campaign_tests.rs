use crate::pg_http_campaign::{clock_resolution, validate_response};
use crate::pg_http_workloads::Workload;
use pseudolearn_api::ExecuteRequest;
use serde_json::json;

fn workload() -> Workload {
    Workload {
        name: "http-body-0".to_owned(),
        category: "http_body".to_owned(),
        request: ExecuteRequest::default(),
        expected_output: "0\n".to_owned(),
        body_bytes: 0,
        input_bytes: 0,
        json_nodes: 0,
    }
}

#[test]
fn accepts_completed_responses_matching_the_expected_output() -> Result<(), String> {
    validate_response(&workload(), &json!({"kind":"completed"}), "0\n")
}

#[test]
fn rejects_failed_or_different_responses() {
    assert!(validate_response(&workload(), &json!({"kind":"failed"}), "0\n").is_err());
    assert!(validate_response(&workload(), &json!({"kind":"completed"}), "1\n").is_err());
}

#[test]
fn measures_a_positive_monotonic_clock_resolution() -> Result<(), String> {
    if clock_resolution()? == 0 {
        return Err("Clock resolution must be positive".to_owned());
    }
    Ok(())
}
