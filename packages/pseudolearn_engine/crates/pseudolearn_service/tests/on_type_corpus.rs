use pseudolearn_lexicon::Profile;
use pseudolearn_service::{DocumentSession, apply_changes, on_type};
use std::path::PathBuf;

fn programs() -> Result<Vec<(String, Profile, String)>, String> {
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../apps/pseudolearn_app/assets/knowledge/examples");
    let mut found = Vec::new();
    for entry in std::fs::read_dir(&directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        let name = path
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("")
            .to_owned();
        if !name.ends_with(".pseudo") {
            continue;
        }
        let profile = if name.ends_with("_en.pseudo") {
            Profile::English
        } else {
            Profile::Spanish
        };
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        found.push((name, profile, text));
    }
    found.sort();
    Ok(found)
}

fn newline_positions(text: &str) -> Vec<usize> {
    text.char_indices()
        .filter(|(_, glyph)| *glyph == '\n')
        .map(|(index, _)| index)
        .collect()
}

#[test]
fn enter_never_adds_syntax_errors_and_settles_after_one_application() -> Result<(), String> {
    let mut failures = Vec::new();
    for (name, profile, original) in programs()? {
        for newline in newline_positions(&original).into_iter().step_by(3) {
            let mut text = original.clone();
            text.insert(newline, '\n');
            let cursor = newline.saturating_add(1);
            let before = DocumentSession::new(text.clone(), profile, true);
            let outcome = on_type(&before, cursor, '\n');
            let result = apply_changes(&text, &outcome.edits);
            let after = DocumentSession::new(result.clone(), profile, true);
            if after.syntax_diagnostics.len() > before.syntax_diagnostics.len() {
                failures.push(format!("{name}@{newline}: diagnostics increased"));
            }
            let line_start = result[..outcome.cursor]
                .rfind('\n')
                .map_or(0, |newline| newline + 1);
            let again = on_type(&after, line_start, '\n');
            if !again.edits.is_empty() {
                failures.push(format!("{name}@{newline}: not settled"));
            }
        }
    }
    assert!(failures.is_empty(), "{failures:#?}");
    Ok(())
}

#[test]
fn pairs_never_add_syntax_errors_at_any_line_end() -> Result<(), String> {
    let mut failures = Vec::new();
    for (name, profile, original) in programs()? {
        for newline in newline_positions(&original).into_iter().step_by(5) {
            for typed in ['(', '"', '[', '\''] {
                let mut text = original.clone();
                text.insert(newline, typed);
                let cursor = newline.saturating_add(typed.len_utf8());
                let before = DocumentSession::new(text.clone(), profile, true);
                let outcome = on_type(&before, cursor, typed);
                let result = apply_changes(&text, &outcome.edits);
                let after = DocumentSession::new(result, profile, true);
                if after.syntax_diagnostics.len() > before.syntax_diagnostics.len() {
                    failures.push(format!("{name}@{newline}{typed}: diagnostics increased"));
                }
            }
        }
    }
    assert!(failures.is_empty(), "{failures:#?}");
    Ok(())
}
