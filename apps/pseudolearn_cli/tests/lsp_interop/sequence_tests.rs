use crate::sequence::{StepKind, load};

#[test]
fn sequence_covers_the_full_session_life_cycle_in_order() -> Result<(), String> {
    let steps = load("file:///interop/")?;
    let methods: Vec<&str> = steps.iter().map(|step| step.method.as_str()).collect();
    for required in [
        "initialize",
        "textDocument/didOpen",
        "textDocument/didChange",
        "textDocument/rename",
        "workspace/didChangeConfiguration",
        "pseudolearn/workspaceSnapshot",
        "shutdown",
        "exit",
    ] {
        assert!(methods.contains(&required), "missing {required}");
    }
    assert_eq!(methods.first(), Some(&"initialize"));
    assert_eq!(methods.last(), Some(&"exit"));
    Ok(())
}

#[test]
fn sequence_substitutes_the_root_and_numbers_steps_consecutively() -> Result<(), String> {
    let steps = load("file:///interop/")?;
    for (index, step) in steps.iter().enumerate() {
        assert_eq!(step.number, u64::try_from(index).unwrap_or(u64::MAX) + 1);
        assert!(!step.payload.to_string().contains("${ROOT}"));
    }
    assert!(steps.iter().any(|step| {
        step.payload
            .to_string()
            .contains("file:///interop/app/main.pseudo")
    }));
    Ok(())
}

#[test]
fn sequence_includes_non_bmp_text_and_a_stale_revision() -> Result<(), String> {
    let steps = load("file:///interop/")?;
    let changes: Vec<_> = steps
        .iter()
        .filter(|step| step.method == "textDocument/didChange")
        .collect();
    assert_eq!(changes.len(), 2);
    assert!(
        changes
            .iter()
            .all(|step| step.kind == StepKind::Notification)
    );
    assert!(
        steps
            .iter()
            .any(|step| step.payload.to_string().contains('\u{1F600}'))
    );
    Ok(())
}
