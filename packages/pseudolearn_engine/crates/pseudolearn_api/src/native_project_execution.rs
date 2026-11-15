use crate::native_execution::conformance_build_request;
use crate::project_compile::{Outcome, compile};
use crate::project_operations::execution_request;
use crate::{ExecuteRequest, ExecuteResponse, NativeObject, build_native_project_object};
use serde_json::{Value, json};

pub enum NativeProjectPlan {
    Finished(Value),
    Ready(Box<NativeProjectRun>),
}

pub struct NativeProjectRun {
    pub object: NativeObject,
    pub execution: ExecuteRequest,
    manifests_used: bool,
}

impl NativeProjectRun {
    pub fn complete(&self, response: &ExecuteResponse) -> Value {
        let mut value = serde_json::to_value(response).unwrap_or(Value::Null);
        if let Some(object) = value.as_object_mut() {
            object.insert("project_errors".to_owned(), json!([]));
            if self.manifests_used {
                object.insert("manifest_errors".to_owned(), json!([]));
            }
        }
        json!({"value": value})
    }
}

pub fn prepare_native_project(arguments: &Value) -> NativeProjectPlan {
    let compiled = match compile(arguments) {
        Ok(Outcome::Compiled(compiled)) => compiled,
        Ok(Outcome::Failed(failure)) => {
            return NativeProjectPlan::Finished(json!({"value": failure}));
        }
        Err(error) => return NativeProjectPlan::Finished(crate::resources::failure(&error)),
    };
    let execution = execution_request(&compiled);
    let names: Vec<(u32, String)> = compiled
        .request
        .input
        .files
        .iter()
        .map(|file| (file.source_id, file.path.clone()))
        .collect();
    let build = conformance_build_request(&execution);
    match build_native_project_object(arguments, &build, &names) {
        Ok(object) => NativeProjectPlan::Ready(Box::new(NativeProjectRun {
            object,
            execution,
            manifests_used: compiled.request.manifests_used,
        })),
        Err(_) => NativeProjectPlan::Finished(crate::resources::failure(
            &crate::ApiError::InternalFault("internalFault".to_owned()),
        )),
    }
}
