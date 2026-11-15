use crate::recording_digest::EventDigest;
use serde_json::{Value, json};

fn summary(events: &[Value]) -> Result<Value, crate::ApiError> {
    let mut digest = EventDigest::default();
    for event in events {
        digest.append(event)?;
    }
    Ok(digest.finish())
}

fn event(revision: &str, node: &str, line: usize) -> Value {
    json!({"source":{"revision_id":revision,"node_id":node,"span":{"line":line}},"kind":"statement"})
}

#[test]
fn summaries_preserve_aliases_spans_and_revision_boundaries() -> Result<(), crate::ApiError> {
    let base = summary(&[event("first", "alpha", 1), event("first", "alpha", 1)])?;
    let renamed = summary(&[event("next", "beta", 1), event("next", "beta", 1)])?;
    assert_eq!(base, renamed);
    for altered in [
        event("first", "beta", 1),
        event("next", "alpha", 1),
        event("first", "alpha", 2),
    ] {
        assert_ne!(base, summary(&[event("first", "alpha", 1), altered])?);
    }
    assert_ne!(base, summary(&[])?);
    Ok(())
}

#[test]
fn summaries_reject_missing_source_identity() {
    assert!(summary(&[json!({"source":{"node_id":"alpha"}})]).is_err());
}
