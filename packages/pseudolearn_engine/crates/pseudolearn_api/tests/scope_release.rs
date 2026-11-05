use pseudolearn_api::{ExecuteRequest, ExecuteResponse, ExecutionLimits, execute_program};

fn run(program: &str, cells: u64, gc_stress: bool) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "en".to_owned(),
        gc_stress,
        limits: ExecutionLimits {
            cells: Some(cells),
            ..Default::default()
        },
        ..Default::default()
    })
}

fn kind(response: &ExecuteResponse) -> Option<&serde_json::Value> {
    response.termination.get("kind")
}

const LOOP: &str = "algorithm P\nfor i <- 1 to 50 step 1 do\ndimension a[3] as integer;\na[0] <- i;\nendFor\nwrite 1;\nendAlgorithm\n";
const OBJECTS: &str = "class Box\npublic define value as integer;\nendClass\nalgorithm P\nfor i <- 1 to 50 step 1 do\ndefine b as Box <- new Box();\nb.value <- i;\nendFor\nwrite 1;\nendAlgorithm\n";

#[test]
fn a_loop_body_array_costs_only_one_iteration() {
    for stress in [false, true] {
        let response = run(LOOP, 4, stress);
        assert_eq!(kind(&response), Some(&serde_json::json!("completed")));
        assert_eq!(response.output, "1\n");
    }
}

#[test]
fn one_cell_less_than_a_single_iteration_fails() {
    let response = run(LOOP, 3, false);
    assert_eq!(kind(&response), Some(&serde_json::json!("failed")));
}

#[test]
fn block_scoped_objects_are_reclaimed_before_the_next_iteration() {
    for stress in [false, true] {
        let response = run(OBJECTS, 4, stress);
        assert_eq!(kind(&response), Some(&serde_json::json!("completed")));
    }
}

#[test]
fn bindings_still_in_scope_keep_counting() {
    let flat = "algorithm P\ndimension a[3] as integer;\na[0] <- 1;\ndimension b[3] as integer;\nb[0] <- 1;\ndimension c[3] as integer;\nc[0] <- 1;\nwrite 1;\nendAlgorithm\n";
    assert_eq!(
        kind(&run(flat, 11, false)),
        Some(&serde_json::json!("failed"))
    );
    assert_eq!(
        kind(&run(flat, 12, false)),
        Some(&serde_json::json!("completed"))
    );
}
