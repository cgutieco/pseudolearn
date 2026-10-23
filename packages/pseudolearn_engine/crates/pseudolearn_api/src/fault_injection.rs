use crate::execution_resource::usage;
use crate::{AnalyzeRequest, ApiError, ExecuteRequest};
use serde_json::{Value, json};

pub(crate) const STAGES: [&str; 5] = ["analysis", "lowering", "bytecode", "load", "execution"];

pub(crate) fn stages() -> Value {
    json!(STAGES)
}

pub(crate) fn inject(arguments: &Value) -> Result<Value, ApiError> {
    let stage = arguments
        .get("stage")
        .and_then(Value::as_str)
        .filter(|stage| STAGES.contains(stage))
        .ok_or_else(|| usage("unknown fault stage"))?;
    let request: ExecuteRequest = serde_json::from_value(
        arguments
            .get("request")
            .cloned()
            .ok_or_else(|| usage("missing request"))?,
    )
    .map_err(|error| usage(&error.to_string()))?;
    let analysis = AnalyzeRequest {
        program: request.program.clone(),
        profile: request.profile.clone(),
        strictness: request.strictness.clone(),
        source: request.source,
    };
    let _ = crate::execute_analyze(&analysis);
    strike(stage, "analysis");
    let module =
        crate::compile_source_to_module(&request.program, &request.profile, &request.strictness);
    strike(stage, "lowering");
    let bytecode = module
        .ok()
        .and_then(|module| pseudolearn_bytecode::compile_module(&module).ok());
    strike(stage, "bytecode");
    let loaded = bytecode.as_ref().map(pseudolearn_vm::load);
    strike(stage, "load");
    let _ = crate::execute_program(&request);
    strike(stage, "execution");
    drop(loaded);
    Ok(Value::Null)
}

fn strike(requested: &str, current: &str) {
    if requested == current {
        std::panic::resume_unwind(Box::new(format!("injected fault at {current}")));
    }
}
