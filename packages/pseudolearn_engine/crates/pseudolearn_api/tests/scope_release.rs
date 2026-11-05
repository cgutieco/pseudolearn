use pseudolearn_api::{
    ApiSession, ExecuteRequest, ExecuteResponse, ExecutionLimits, execute_program,
};
use serde_json::{Value, json};

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

fn final_variables(program: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let analysis = session
        .call(
            "create_analysis",
            &json!({"program":program,"profile":"en"}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let execution = session
        .call("start", &json!({"analysis":analysis}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing execution")?;
    session.call("advance", &json!({"resource":execution,"batch_size":4096}));
    let last = session
        .call("horizon", &json!({"resource":execution}))
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or("missing horizon")?;
    session
        .call("query_state", &json!({"resource":execution,"event":last}))
        .pointer("/value/marcos/0/variables")
        .cloned()
        .ok_or_else(|| "missing variables".to_owned())
}

#[test]
fn the_state_after_a_block_no_longer_lists_its_bindings() -> Result<(), String> {
    let program = "class Box\npublic define value as integer;\nendClass\nalgorithm P\ndefine mutable total as integer <- 0;\nfor i <- 1 to 3 step 1 do\ndefine b as Box <- new Box();\nb.value <- i;\ntotal <- total + b.value;\nendFor\nwrite total;\nendAlgorithm\n";
    let variables = final_variables(program)?;
    assert_eq!(variables.pointer("/total/valor"), Some(&json!("6")));
    assert_eq!(variables.get("b"), None);
    Ok(())
}

#[test]
fn a_binding_of_an_enclosing_scope_is_still_listed() -> Result<(), String> {
    let program = "algorithm P\ndefine kept as integer <- 4;\nif kept > 1 then\ndefine inner as integer <- kept;\nwrite inner;\nendIf\nwrite kept;\nendAlgorithm\n";
    let variables = final_variables(program)?;
    assert_eq!(variables.pointer("/kept/valor"), Some(&json!("4")));
    assert_eq!(variables.get("inner"), None);
    Ok(())
}
