use crate::comparator::{Difference, compare};
use crate::reference_fixture::{reference_transcript, relocated_transcript};
use crate::transcript::Transcript;
use serde_json::{Value, json};

fn mutate(transcript: &Transcript, step: u64, pointer: &str, replacement: &Value) -> Transcript {
    let mut changed = transcript.clone();
    for entry in &mut changed.steps {
        if Transcript::step_number(entry) != Some(step) {
            continue;
        }
        if let Some(target) = entry.pointer_mut(pointer) {
            target.clone_from(replacement);
        }
    }
    changed
}

#[test]
fn transports_ids_and_uri_prefix_are_the_only_allowed_differences() -> Result<(), String> {
    let left = reference_transcript()?;
    let right = relocated_transcript("file:///var/work/clientB-9/")?;
    assert_eq!(compare(&left, &right), Vec::new());
    Ok(())
}

#[test]
fn altered_utf16_range_is_reported_with_its_location() -> Result<(), String> {
    let left = reference_transcript()?;
    let right = mutate(&left, 8, "/message/result/range/end/character", &json!(26));
    assert_eq!(
        compare(&left, &right),
        vec![Difference::StepMismatch {
            step: 8,
            pointer: "/message/result/range/end/character".to_owned()
        }]
    );
    Ok(())
}

#[test]
fn lost_step_and_extra_step_are_reported() -> Result<(), String> {
    let left = reference_transcript()?;
    let mut right = left.clone();
    right
        .steps
        .retain(|entry| Transcript::step_number(entry) != Some(12));
    assert_eq!(compare(&left, &right), vec![Difference::MissingStep(12)]);
    assert_eq!(compare(&right, &left), vec![Difference::ExtraStep(12)]);
    Ok(())
}

#[test]
fn lost_file_diagnostics_are_reported_even_when_other_text_matches() -> Result<(), String> {
    let left = reference_transcript()?;
    let mut right = left.clone();
    right.diagnostics.clear();
    assert_eq!(
        compare(&left, &right),
        vec![Difference::MissingDiagnostics(
            "file:///ROOT/app/malo.pseudo".to_owned()
        )]
    );
    Ok(())
}

#[test]
fn changed_symbol_replacement_text_is_reported() -> Result<(), String> {
    let left = reference_transcript()?;
    let right = mutate(
        &left,
        18,
        "/message/result/documentChanges/0/edits/0/newText",
        &json!("Duplicar2"),
    );
    assert_eq!(compare(&left, &right).len(), 1);
    Ok(())
}

#[test]
fn accepted_stale_revision_is_reported_even_if_visible_text_matches() -> Result<(), String> {
    let left = reference_transcript()?;
    let right = mutate(
        &left,
        18,
        "/message/result/documentChanges/0/textDocument/version",
        &json!(1),
    );
    let differences = compare(&left, &right);
    assert!(matches!(
        differences.as_slice(),
        [Difference::StepMismatch { step: 18, .. }]
    ));
    Ok(())
}

#[test]
fn error_code_and_message_changes_are_not_normalized_away() -> Result<(), String> {
    let left = mutate(
        &reference_transcript()?,
        1,
        "/message",
        &json!({"id": 1, "error": {"code": -32602, "message": "invalid"}}),
    );
    let right = mutate(&left, 1, "/message/error/code", &json!(-32600));
    assert_eq!(compare(&left, &right).len(), 1);
    Ok(())
}
