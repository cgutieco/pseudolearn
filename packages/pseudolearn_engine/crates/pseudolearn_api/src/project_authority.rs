use crate::ExecutionLimits;
use crate::manifest_wire::located_errors;
use crate::project_resource::ProjectRequest;
use pseudolearn_project::{LimitName, ModuleId, ProjectCatalog};
use serde_json::{Value, json};

pub(crate) fn manifest_failure(request: &ProjectRequest) -> Value {
    json!({
        "diagnostics": [],
        "project_errors": [],
        "manifest_errors": located_errors(&request.manifest_errors),
    })
}

pub(crate) fn with_manifest_status(request: &ProjectRequest, mut value: Value) -> Value {
    if let Some(object) = value.as_object_mut().filter(|_| request.manifests_used) {
        object.insert("manifest_errors".to_owned(), json!([]));
    }
    value
}

pub(crate) fn execution_limits(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    entry: Option<ModuleId>,
) -> ExecutionLimits {
    let mut limits = request.execution.limits.clone();
    let owner = entry
        .and_then(|id| catalog.module(id))
        .and_then(|module| catalog.package(module.package))
        .map(|package| package.name.as_str());
    let configuration = request
        .configurations
        .iter()
        .find(|configuration| Some(configuration.manifest.name.value.as_str()) == owner);
    for (name, authority) in configuration.iter().flat_map(|found| found.limits.iter()) {
        let Some(value) = authority.effective else {
            continue;
        };
        match name {
            LimitName::Cells => limits.cells = Some(value.min(limits.cells.unwrap_or(value))),
            LimitName::Depth => {
                let maximum = usize::try_from(value).unwrap_or(usize::MAX);
                limits.depth = Some(maximum.min(limits.depth.unwrap_or(maximum)));
            }
            LimitName::MicroSteps => {
                limits.micro_steps = Some(value.min(limits.micro_steps.unwrap_or(value)))
            }
            LimitName::Statements => {
                limits.statements = Some(value.min(limits.statements.unwrap_or(value)))
            }
        }
    }
    limits
}
