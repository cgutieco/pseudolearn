use crate::normalization::{NORMALIZED_ROOT, normalize};
use crate::reference_fixture::{reference_transcript, relocated_transcript};
use serde_json::json;

#[test]
fn normalization_rewrites_the_root_and_assigns_step_numbers_as_ids() -> Result<(), String> {
    let normalized = normalize(&relocated_transcript("file:///other/root/")?);
    let definition = normalized.steps.get(1).ok_or("missing definition step")?;
    assert_eq!(
        definition.pointer("/message/result/uri"),
        Some(&json!(format!("{NORMALIZED_ROOT}geo/vectores.pseudo")))
    );
    assert_eq!(definition.pointer("/message/id"), Some(&json!(8)));
    assert!(
        normalized
            .diagnostics
            .contains_key(&format!("{NORMALIZED_ROOT}app/malo.pseudo"))
    );
    Ok(())
}

#[test]
fn normalization_never_touches_ranges_or_edit_text() -> Result<(), String> {
    let original = reference_transcript()?;
    let normalized = normalize(&original);
    let before = original.steps.get(3).ok_or("missing rename step")?;
    let after = normalized.steps.get(3).ok_or("missing rename step")?;
    assert_eq!(
        before.pointer("/message/result/documentChanges/0/edits"),
        after.pointer("/message/result/documentChanges/0/edits")
    );
    Ok(())
}

#[test]
fn normalization_of_an_empty_transcript_is_empty() {
    let empty = crate::transcript::Transcript {
        root: "file:///x/".to_owned(),
        steps: Vec::new(),
        diagnostics: std::collections::BTreeMap::new(),
    };
    let normalized = normalize(&empty);
    assert!(normalized.steps.is_empty() && normalized.diagnostics.is_empty());
}
