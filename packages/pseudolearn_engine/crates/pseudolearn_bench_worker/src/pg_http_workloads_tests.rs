use crate::pg_http_workloads::{BODY_SIZES, JSON_DEPTHS, JSON_SIZES, all};
use pseudolearn_api::{execute_prepared, prepare_program};

#[test]
fn workload_matrix_has_the_protocol_sizes_and_unique_names() {
    let workloads = all();
    assert_eq!(workloads.len(), 13);
    for (workload, size) in workloads.iter().take(BODY_SIZES.len()).zip(BODY_SIZES) {
        assert_eq!(workload.body_bytes, size);
        assert_eq!(workload.category, "http_body");
    }
    for size in JSON_SIZES {
        for depth in JSON_DEPTHS {
            assert!(workloads.iter().any(|workload| {
                workload.name == format!("json-{size}-depth-{depth}")
                    && workload.input_bytes == size
                    && workload.json_nodes == depth + 1
            }));
        }
    }
    let mut names = workloads
        .iter()
        .map(|workload| workload.name.as_str())
        .collect::<Vec<_>>();
    names.sort_unstable();
    names.dedup();
    assert_eq!(names.len(), workloads.len());
}

#[test]
fn every_generated_load_executes_with_its_memory_host_or_json_text() -> Result<(), String> {
    for workload in all() {
        let prepared = prepare_program(&workload.request)
            .map_err(|diagnostics| format!("{}: {diagnostics:?}", workload.name))?;
        let response = execute_prepared(&prepared, &workload.request);
        if response.output != workload.expected_output
            || response
                .termination
                .get("kind")
                .and_then(serde_json::Value::as_str)
                != Some("completed")
        {
            return Err(format!(
                "{}: unexpected response {response:?}",
                workload.name
            ));
        }
    }
    Ok(())
}
