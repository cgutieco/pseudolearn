use crate::ApiError;
use crate::resources::ApiSession;
use serde_json::{Value, json};

impl ApiSession {
    pub(crate) fn service_operation(
        &mut self,
        operation: &str,
        arguments: &Value,
    ) -> Option<Result<Value, ApiError>> {
        let outcome = match operation {
            "open_edit_session" => self.open_edit_session(arguments),
            "apply_edit"
            | "edit_complete"
            | "edit_accept"
            | "edit_insert_template"
            | "edit_on_type"
            | "edit_navigate_stop" => self.edit_operation(operation, arguments),
            "complete" => crate::service_completion::complete(arguments),
            "completion_templates" => crate::service_completion::templates(arguments),
            "editor_vocabulary" => crate::editor_vocabulary::query(arguments),
            "reference_vocabulary" => crate::reference_vocabulary::query(arguments),
            "diagnostic_template" => crate::diagnostic_template::query(arguments),
            "version" => Ok(
                json!({"version": crate::ENGINE_VERSION, "editions": ["2026"],
                "capabilities": crate::supported_capabilities()}),
            ),
            "operations" => Ok(operation_names()),
            _ => return None,
        };
        Some(outcome)
    }
}

fn operation_names() -> Value {
    json!([
        "analysis",
        "document",
        "advance",
        "input",
        "cancel",
        "complete",
        "completion_templates",
        "open_edit_session",
        "apply_edit",
        "edit_complete",
        "edit_accept",
        "edit_insert_template",
        "edit_on_type",
        "edit_navigate_stop",
        "query_state",
        "release"
    ])
}
