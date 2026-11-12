use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn between(before: &Value, after: &Value) -> Vec<Value> {
    let before = leaves(before);
    let after = leaves(after);
    let paths: BTreeSet<_> = before.keys().chain(after.keys()).collect();
    paths
        .into_iter()
        .filter_map(|path| {
            if before.get(path) == after.get(path) {
                return None;
            }
            let mut change = json!({"path":path});
            if let Some(fields) = change.as_object_mut() {
                if let Some(value) = before.get(path) {
                    fields.insert("before".to_owned(), value.clone());
                }
                if let Some(value) = after.get(path) {
                    fields.insert("after".to_owned(), value.clone());
                }
            }
            Some(change)
        })
        .collect()
}

fn leaves(root: &Value) -> BTreeMap<String, Value> {
    let mut pending = vec![(String::new(), root)];
    let mut result = BTreeMap::new();
    while let Some((path, value)) = pending.pop() {
        match value {
            Value::Object(fields) if !fields.is_empty() => {
                pending.extend(fields.iter().map(|(key, value)| {
                    (
                        format!("{path}/{}", key.replace('~', "~0").replace('/', "~1")),
                        value,
                    )
                }));
            }
            Value::Array(elements) if !elements.is_empty() => {
                pending.extend(
                    elements
                        .iter()
                        .enumerate()
                        .map(|(index, value)| (format!("{path}/{index}"), value)),
                );
            }
            _ => {
                result.insert(path, value.clone());
            }
        }
    }
    result
}
