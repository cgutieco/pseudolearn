use crate::SecretHandle;
use serde_json::Value;

const ENVIRONMENT_KEY_ID: &str = "environment";

pub(crate) fn reference(operation: &str, arguments: &[u8]) -> Option<SecretHandle> {
    if operation != "environment_get" {
        return None;
    }
    let name = requested_name(arguments)?;
    if !crate::environment_name_is_sensitive(&name) {
        return None;
    }
    SecretHandle::authenticate(ENVIRONMENT_KEY_ID.to_owned(), name.as_bytes(), &[]).ok()
}

fn requested_name(arguments: &[u8]) -> Option<String> {
    let (_receiver, values, _result): (Value, Vec<Value>, Value) =
        serde_json::from_slice(arguments).ok()?;
    values.first()?.get("value")?.as_str().map(str::to_owned)
}
