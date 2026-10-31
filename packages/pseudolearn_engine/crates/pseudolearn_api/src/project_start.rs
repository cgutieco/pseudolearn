use crate::execution_resource::ExecutionResource;
use crate::project_compile::{Outcome, compile};
use crate::project_operations::{execution_request, load_compiled};
use crate::resources::Resource;
use crate::{ApiError, ApiSession};
use serde_json::{Value, json};

impl ApiSession {
    pub(crate) fn start_project(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let compiled = match compile(arguments)? {
            Outcome::Failed(failure) => return Ok(failure),
            Outcome::Compiled(compiled) => *compiled,
        };
        let request = execution_request(&compiled);
        let program = load_compiled(&compiled)?;
        let sources = crate::execution_sources::ExecutionSources::project(&compiled.request)?;
        let mut execution = ExecutionResource::from_loaded(&request, program, compiled.warnings)?;
        execution.attach_sources(sources);
        let resource = self.insert(Resource::Execution {
            analysis: 0,
            execution: Box::new(execution),
        })?;
        Ok(json!({"resource": resource, "project_errors": []}))
    }
}
