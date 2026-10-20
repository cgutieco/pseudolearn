use serde_json::{Value, json};

pub(crate) fn verify(request: &Value) -> Value {
    match serde_json::from_value::<pseudolearn_api::IrRequest>(request.clone()) {
        Ok(request) => serde_json::to_value(pseudolearn_api::execute_ir(&request))
            .unwrap_or_else(|error| json!({"kind":"error","message":error.to_string()})),
        Err(error) => json!({"kind":"error","message":error.to_string()}),
    }
}

#[cfg(test)]
#[path = "adapter_ir_tests.rs"]
mod adapter_ir_tests;
