use pseudolearn_api::{ExecuteRequest, ExecutionLimits, execute_program};
use serde_json::json;

fn fan_out(spawns: usize) -> String {
    let body = "Lanzar Work();\n".repeat(spawns);
    format!(
        "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\n{body}FinTareas\nEscribir \"end\";\nFinAlgoritmo\n"
    )
}

fn channel(capacity: usize) -> String {
    format!(
        "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal({capacity});\nEscribir \"ok\";\nFinAlgoritmo\n"
    )
}

fn limited(program: String, limits: ExecutionLimits) -> pseudolearn_api::ExecuteResponse {
    execute_program(&ExecuteRequest {
        program,
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        limits,
        ..Default::default()
    })
}

#[test]
fn live_tasks_equal_to_the_limit_complete() {
    let response = limited(
        fan_out(3),
        ExecutionLimits {
            tasks: Some(3),
            ..Default::default()
        },
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "w\nw\nw\nend\n");
}

#[test]
fn one_live_task_above_the_limit_fails_at_the_spawn_without_later_effects() {
    let response = limited(
        fan_out(4),
        ExecutionLimits {
            tasks: Some(3),
            ..Default::default()
        },
    );
    assert_eq!(
        response.termination.get("code"),
        Some(&json!("taskLimitExceeded")),
        "{response:?}"
    );
    assert_eq!(response.output, "");
}

#[test]
fn channel_capacity_at_the_maximum_passes_and_above_it_fails() {
    let at_limit = limited(
        channel(8),
        ExecutionLimits {
            channel_capacity: Some(8),
            ..Default::default()
        },
    );
    assert_eq!(
        at_limit.termination.get("kind"),
        Some(&json!("completed")),
        "{at_limit:?}"
    );
    let above = limited(
        channel(9),
        ExecutionLimits {
            channel_capacity: Some(8),
            ..Default::default()
        },
    );
    assert_eq!(
        above.termination.get("code"),
        Some(&json!("channelCapacityExceeded")),
        "{above:?}"
    );
}

#[test]
fn default_limits_admit_a_hundred_live_tasks() {
    let response = limited(fan_out(100), ExecutionLimits::default());
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
}

#[test]
fn the_task_limit_diagnostic_names_the_configured_maximum() {
    let response = limited(
        fan_out(4),
        ExecutionLimits {
            tasks: Some(3),
            ..Default::default()
        },
    );
    let limit = response
        .diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == "taskLimitExceeded")
        .and_then(|diagnostic| diagnostic.arguments.get("limit").cloned());
    assert_eq!(limit, Some(json!(3)), "{response:?}");
}
