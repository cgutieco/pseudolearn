use serde_json::Value;

pub(crate) fn project(value: Value) -> Value {
    match value {
        Value::Number(number) => Value::String(number.to_string()),
        Value::Array(values) => Value::Array(values.into_iter().map(project).collect()),
        Value::Object(values) => Value::Object(
            values
                .into_iter()
                .map(|(name, value)| (name, project(value)))
                .collect(),
        ),
        other => other,
    }
}
