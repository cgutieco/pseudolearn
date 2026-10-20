use see_conformance::event_identity::normalize;
use serde_json::{Value, json};

fn events(revision: &str, nodes: &[&str]) -> Value {
    json!({"events":nodes.iter().map(|node| json!({"source":{
        "revision_id":revision,"node_id":node,"span":{"start_byte":"0","end_byte":"1"}}
    })).collect::<Vec<_>>()})
}

#[test]
fn renames_bijectively_without_losing_aliases_spans_or_revisions() -> Result<(), String> {
    let mut first = events("rev1", &["n1", "n2", "n1"]);
    let mut equivalent = events("rev2", &["n3", "n4", "n3"]);
    normalize(&mut first)?;
    normalize(&mut equivalent)?;
    assert_eq!(first, equivalent);
    let mut alias = events("rev2", &["n3", "n3", "n3"]);
    normalize(&mut alias)?;
    assert_ne!(first, alias);
    for (path, replacement) in [
        ("/events/1/source/span/start_byte", json!("2")),
        ("/events/1/source/revision_id", json!("foreign")),
    ] {
        let mut changed = events("rev1", &["n1", "n2", "n1"]);
        *changed.pointer_mut(path).ok_or("missing field")? = replacement;
        normalize(&mut changed)?;
        assert_ne!(first, changed);
    }
    assert!(normalize(&mut json!({"events":[{"source":{}}]})).is_err());
    Ok(())
}
