use serde_json::{Value, json};
use std::collections::BTreeMap;

pub fn normalize(response: &mut Value) -> Result<(), String> {
    let mut revisions = BTreeMap::new();
    let mut nodes = BTreeMap::new();
    for event in response
        .get_mut("events")
        .and_then(Value::as_array_mut)
        .into_iter()
        .flatten()
    {
        if let Some(source) = event.get_mut("source").filter(|source| !source.is_null()) {
            let revision = source
                .get("revision_id")
                .and_then(Value::as_str)
                .ok_or("SEE-PROPERTY: missing source revision")?
                .to_owned();
            let node = source
                .get("node_id")
                .and_then(Value::as_str)
                .ok_or("SEE-PROPERTY: missing source node")?
                .to_owned();
            let next_revision = revisions.len();
            let revision_index = *revisions.entry(revision.clone()).or_insert(next_revision);
            let next_node = nodes.len();
            let node_index = *nodes.entry((revision, node)).or_insert(next_node);
            let fields = source
                .as_object_mut()
                .ok_or("SEE-PROPERTY: invalid source")?;
            fields.insert("revision_id".to_owned(), json!(revision_index));
            fields.insert("node_id".to_owned(), json!(node_index));
        }
    }
    Ok(())
}
