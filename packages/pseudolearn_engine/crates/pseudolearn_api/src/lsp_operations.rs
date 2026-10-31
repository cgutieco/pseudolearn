use crate::execution_resource::usage;
use crate::resources::{ApiSession, Resource, identifier};
use crate::{ApiError, service::LspServer};
use serde_json::{Value, json};

pub(crate) fn dispatch(
    session: &mut ApiSession,
    operation: &str,
    arguments: &Value,
) -> Result<Value, ApiError> {
    match operation {
        "create_lsp" => create(session, arguments),
        "lsp_message" => message(session, arguments),
        _ => translate(arguments),
    }
}

fn create(session: &mut ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    let fields = arguments
        .as_object()
        .ok_or_else(|| usage("arguments must be an object"))?;
    if !fields.is_empty() {
        return Err(usage("create_lsp accepts no options"));
    }
    let resource = session.insert(Resource::Lsp(Box::default()))?;
    Ok(json!({"resource":resource}))
}

fn message(session: &mut ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    let message = arguments
        .get("message")
        .filter(|value| value.is_object())
        .ok_or_else(|| usage("message must be an LSP object"))?;
    if message.get("jsonrpc").and_then(Value::as_str) != Some("2.0") {
        return Err(usage("message must use JSON-RPC 2.0"));
    }
    let Some(Resource::Lsp(server)) = session.resources.get_mut(&identifier(arguments)?) else {
        return Err(usage("invalid LSP resource"));
    };
    Ok(messages(server, message))
}

fn messages(server: &mut LspServer, message: &Value) -> Value {
    json!({"messages":server.handle_message(message)})
}

fn translate(arguments: &Value) -> Result<Value, ApiError> {
    let program = arguments
        .get("program")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing program"))?;
    let target = arguments
        .get("target_profile")
        .and_then(Value::as_str)
        .and_then(crate::service::Profile::from_name)
        .ok_or_else(|| usage("invalid target profile"))?;
    let strict = arguments.get("strictness").and_then(Value::as_str) != Some("flexible");
    let translated = crate::service::translate_source(program, target, strict)
        .map_err(|error| usage(&format!("translation rejected: {error:?}")))?;
    Ok(json!({"text":translated}))
}
