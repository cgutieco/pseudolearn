use crate::execution_state::frame;
use pseudolearn_timeline::{FrameView, VariableValue};
use serde_json::{Value, json};

pub(crate) fn typed_frame(view: &FrameView) -> Value {
    let mut described = frame(view);
    let Some(variables) = described
        .get_mut("variables")
        .and_then(Value::as_object_mut)
    else {
        return described;
    };
    for variable in &view.variables {
        let Some(kind) = kind_name(&variable.value) else {
            continue;
        };
        if let Some(entry) = variables
            .get_mut(&variable.name)
            .and_then(Value::as_object_mut)
            .filter(|entry| entry.contains_key("valor"))
        {
            entry.insert("tipo".to_owned(), json!(kind));
        }
    }
    described
}

fn kind_name(value: &VariableValue) -> Option<&'static str> {
    match value {
        VariableValue::Integer(_) => Some("entero"),
        VariableValue::Real(_) => Some("real"),
        VariableValue::Boolean(_) => Some("booleano"),
        VariableValue::Character(_) => Some("caracter"),
        VariableValue::Text(_) => Some("texto"),
        _ => None,
    }
}
