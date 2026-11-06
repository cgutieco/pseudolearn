#![forbid(unsafe_code)]

use crate::native_cache::ExecutableCache;
use crate::native_run::{NativeLaunch, run_executable};
use pseudolearn_api::{
    ApiSession, NativeProjectPlan, native_effect_input, native_execute_response,
};
use serde_json::{Value, json};

const ANALYSIS_OPERATIONS: &[&str] = &["analyze_project"];

pub(crate) fn respond(request: &Value, cache: &mut ExecutableCache) -> Value {
    let mut session = ApiSession::default();
    let calls = request
        .get("calls")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_else(|| vec![request.clone()]);
    let results: Vec<Value> = calls
        .iter()
        .map(|call| {
            let operation = call.get("operation").and_then(Value::as_str).unwrap_or("");
            let arguments = call.get("arguments").cloned().unwrap_or(Value::Null);
            dispatch(&mut session, (operation, &arguments), cache)
        })
        .collect();
    if request.get("calls").is_some() {
        json!({"kind": "api", "results": results})
    } else {
        json!({"kind": "api", "result": results.into_iter().next().unwrap_or(Value::Null)})
    }
}

fn dispatch(
    session: &mut ApiSession,
    (operation, arguments): (&str, &Value),
    cache: &mut ExecutableCache,
) -> Value {
    if operation == "execute_project" {
        return execute_project(arguments, cache);
    }
    if ANALYSIS_OPERATIONS.contains(&operation) {
        return session.call(operation, arguments);
    }
    json!({"failure": {"family": "usage", "detail": "operation not offered by the native subject"}})
}

fn execute_project(arguments: &Value, cache: &mut ExecutableCache) -> Value {
    let run = match pseudolearn_api::prepare_native_project(arguments) {
        NativeProjectPlan::Finished(value) => return value,
        NativeProjectPlan::Ready(run) => run,
    };
    let report = cache
        .executable_for(&run.object.bytes)
        .ok()
        .and_then(|executable| {
            let effects = native_effect_input(&run.execution).ok()?;
            run_executable(
                &executable,
                cache.directory(),
                (&run.execution.inputs, &effects),
                &NativeLaunch {
                    seed: run.execution.seed,
                    ..NativeLaunch::default()
                },
            )
            .ok()
        })
        .unwrap_or_default();
    let response = native_execute_response(&run.execution, run.object.warnings.clone(), &report);
    run.complete(&response)
}
