use crate::ApiError;
use crate::execution_resource::usage;
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;

#[derive(Default)]
pub(crate) struct EventDigest {
    digest: Sha256,
    count: u64,
    revisions: BTreeMap<String, usize>,
    nodes: BTreeMap<(String, String), usize>,
}

impl EventDigest {
    pub(crate) fn append(&mut self, event: &Value) -> Result<(), ApiError> {
        let mut canonical = event.clone();
        if let Some(source) = canonical
            .get_mut("source")
            .filter(|source| !source.is_null())
        {
            self.normalize_source(source)?;
        }
        let bytes = serde_json::to_vec(&canonical).map_err(|error| usage(&error.to_string()))?;
        self.digest.update(bytes);
        self.digest.update(b"\n");
        self.count = self
            .count
            .checked_add(1)
            .ok_or_else(|| usage("event count overflow"))?;
        Ok(())
    }

    fn normalize_source(&mut self, source: &mut Value) -> Result<(), ApiError> {
        let revision = identity(source, "revision_id")?;
        let node = identity(source, "node_id")?;
        let revision_index = self.revisions.len();
        let revision_index = *self
            .revisions
            .entry(revision.clone())
            .or_insert(revision_index);
        let node_index = self.nodes.len();
        let node_index = *self.nodes.entry((revision, node)).or_insert(node_index);
        let fields = source
            .as_object_mut()
            .ok_or_else(|| usage("invalid event source"))?;
        fields.insert("revision_id".to_owned(), json!(revision_index));
        fields.insert("node_id".to_owned(), json!(node_index));
        Ok(())
    }

    pub(crate) fn finish(self) -> Value {
        json!({"count":self.count,"sha256":format!("{:x}", self.digest.finalize())})
    }
}

fn identity(source: &Value, field: &str) -> Result<String, ApiError> {
    source
        .get(field)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| usage("missing event source identity"))
}
