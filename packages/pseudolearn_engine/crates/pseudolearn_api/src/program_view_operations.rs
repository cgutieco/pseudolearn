use crate::execution_resource::usage;
use crate::program_view::ProgramView;
use crate::resources::Resource;
use crate::{ApiError, ApiSession};
use serde_json::{Value, json};

pub fn analysis_program_view(request: &crate::AnalyzeRequest) -> Option<Value> {
    ProgramView::build(request, "rev0".to_owned())
        .ok()
        .map(|view| view.to_json())
}

pub(crate) fn revision_of(document: u64) -> String {
    format!("rev{document:x}")
}

impl ApiSession {
    pub(crate) fn program_view_operation(
        &self,
        operation: &str,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        let document = arguments
            .get("resource")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing resource"))?;
        let Some(Resource::Document(request)) = self.resources.get(&document) else {
            return Err(usage("invalid document"));
        };
        let view = ProgramView::build(request, revision_of(document))?;
        if operation == "program_view" {
            return Ok(view.to_json());
        }
        let identifier = arguments
            .get("node_id")
            .and_then(Value::as_str)
            .ok_or_else(|| usage("missing node identifier"))?;
        let ordinal = view
            .ordinal_of(identifier)
            .ok_or_else(|| usage("unknown node identifier"))?;
        view.node_json(ordinal)
            .map(|node| json!({"node": node}))
            .ok_or_else(|| usage("unknown node identifier"))
    }
}

impl ApiSession {
    pub(crate) fn query_page_operation(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let identifier = arguments
            .get("resource")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing resource"))?;
        let scope = format!("{:x}|{identifier:x}", self.session_nonce());
        let Some(Resource::Execution { execution, .. }) = self.resources.get(&identifier) else {
            return Err(usage("invalid execution"));
        };
        execution.query_page(arguments, &scope)
    }
}
