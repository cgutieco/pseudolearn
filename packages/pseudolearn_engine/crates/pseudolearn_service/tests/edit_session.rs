use pseudolearn_lexicon::Profile;
use pseudolearn_service::{
    Acceptance, EditError, EditSession, StopDirection, StopNavigation, TextChange,
};

fn session(text: &str) -> EditSession {
    EditSession::new(text.to_owned(), Profile::Spanish, true)
}

fn offer_index(
    session: &mut EditSession,
    revision: u64,
    cursor: usize,
    label: &str,
) -> Result<usize, String> {
    let result = session
        .complete(revision, cursor)
        .map_err(|error| format!("{error:?}"))?;
    result
        .entries
        .iter()
        .position(|entry| entry.label == label)
        .ok_or_else(|| format!("{label} not offered"))
}

fn selected(session: &EditSession, navigation: StopNavigation) -> String {
    match navigation {
        StopNavigation::Selected { start, end, .. } => session
            .document
            .text()
            .get(start..end)
            .unwrap_or("")
            .to_owned(),
        StopNavigation::Exited { .. } => String::from("<exited>"),
    }
}

#[test]
fn revisions_grow_with_every_applied_edit_and_stale_ones_are_rejected() -> Result<(), String> {
    let mut editing = session("Algoritmo P\nFinAlgoritmo\n");
    let change = TextChange {
        start_utf8: 12,
        end_utf8: 12,
        text: String::from("  \n"),
    };
    let next = editing
        .apply_edits(1, std::slice::from_ref(&change))
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(next, 2);
    assert_eq!(
        editing.apply_edits(1, &[change]),
        Err(EditError::StaleRevision { current: 2 })
    );
    assert_eq!(
        editing.complete(1, 0).map(|_| ()),
        Err(EditError::StaleRevision { current: 2 })
    );
    Ok(())
}

#[test]
fn completion_rejects_cursors_off_a_character_boundary() {
    let mut editing = session("Algoritmo P\n  \u{1F9E9}\nFinAlgoritmo\n");
    assert_eq!(
        editing.complete(1, 16).map(|_| ()),
        Err(EditError::InvalidCursor)
    );
    assert_eq!(
        editing.complete(1, 9999).map(|_| ()),
        Err(EditError::InvalidCursor)
    );
}

#[test]
fn accepting_a_template_selects_stops_in_order_and_exits_at_the_final_stop() -> Result<(), String> {
    let text = "Algoritmo P\n  Par\nFinAlgoritmo\n";
    let mut editing = session(text);
    let cursor = text.find("Par").unwrap_or(0) + 3;
    let index = offer_index(&mut editing, 1, cursor, "Para")?;
    let accepted = editing
        .accept(1, Acceptance::Candidate(index))
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(accepted.revision, 2);
    let first = accepted.insertion.selection;
    assert_eq!(
        editing.document.text().get(first.0..first.1),
        Some("indice")
    );
    let second = editing
        .navigate_stop(2, StopDirection::Next)
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(selected(&editing, second), "limite");
    let back = editing
        .navigate_stop(2, StopDirection::Previous)
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(selected(&editing, back), "indice");
    editing
        .navigate_stop(2, StopDirection::Next)
        .map_err(|error| format!("{error:?}"))?;
    let exit = editing
        .navigate_stop(2, StopDirection::Next)
        .map_err(|error| format!("{error:?}"))?;
    assert!(matches!(exit, StopNavigation::Exited { .. }));
    assert_eq!(
        editing.navigate_stop(2, StopDirection::Next),
        Err(EditError::NoTemplateSession)
    );
    Ok(())
}

#[test]
fn typing_inside_a_stop_moves_later_stops() -> Result<(), String> {
    let text = "Algoritmo P\n  Par\nFinAlgoritmo\n";
    let mut editing = session(text);
    let cursor = text.find("Par").unwrap_or(0) + 3;
    let index = offer_index(&mut editing, 1, cursor, "Para")?;
    let accepted = editing
        .accept(1, Acceptance::Candidate(index))
        .map_err(|error| format!("{error:?}"))?;
    let (start, end) = accepted.insertion.selection;
    let typed = TextChange {
        start_utf8: start,
        end_utf8: end,
        text: String::from("contador"),
    };
    editing
        .apply_edits(accepted.revision, &[typed])
        .map_err(|error| format!("{error:?}"))?;
    let next = editing
        .navigate_stop(3, StopDirection::Next)
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(selected(&editing, next), "limite");
    Ok(())
}

#[test]
fn editing_outside_every_stop_ends_the_template_session() -> Result<(), String> {
    let text = "Algoritmo P\n  Par\nFinAlgoritmo\n";
    let mut editing = session(text);
    let index = offer_index(&mut editing, 1, text.find("Par").unwrap_or(0) + 3, "Para")?;
    let accepted = editing
        .accept(1, Acceptance::Candidate(index))
        .map_err(|error| format!("{error:?}"))?;
    let outside = TextChange {
        start_utf8: 0,
        end_utf8: 0,
        text: String::from("x"),
    };
    editing
        .apply_edits(accepted.revision, &[outside])
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        editing.navigate_stop(3, StopDirection::Next),
        Err(EditError::NoTemplateSession)
    );
    Ok(())
}

#[test]
fn accepting_without_an_offer_or_with_an_unknown_candidate_fails() {
    let mut editing = session("Algoritmo P\n  \nFinAlgoritmo\n");
    assert_eq!(
        editing.accept(1, Acceptance::Candidate(0)).map(|_| ()),
        Err(EditError::UnknownCandidate)
    );
    assert!(editing.complete(1, 14).is_ok());
    assert_eq!(
        editing.accept(1, Acceptance::Candidate(9999)).map(|_| ()),
        Err(EditError::UnknownCandidate)
    );
}

#[test]
fn an_edit_invalidates_the_previous_offer() -> Result<(), String> {
    let text = "Algoritmo P\n  Esc\nFinAlgoritmo\n";
    let mut editing = session(text);
    let index = offer_index(
        &mut editing,
        1,
        text.find("Esc").unwrap_or(0) + 3,
        "Escribir",
    )?;
    let noop = TextChange {
        start_utf8: 0,
        end_utf8: 0,
        text: String::from(" "),
    };
    editing
        .apply_edits(1, &[noop])
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        editing.accept(2, Acceptance::Candidate(index)).map(|_| ()),
        Err(EditError::UnknownCandidate)
    );
    Ok(())
}

#[test]
fn on_type_edits_advance_the_revision_and_noops_do_not() -> Result<(), String> {
    let mut editing = session("Algoritmo P\n\n");
    let (revision, outcome) = editing
        .on_type(1, 12, '\n')
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(revision, 2);
    assert!(!outcome.edits.is_empty());
    let (same, quiet) = editing
        .on_type(2, 0, 'x')
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(same, 2);
    assert!(quiet.edits.is_empty());
    assert_eq!(
        editing.on_type(2, 9999, '\n').map(|_| ()),
        Err(EditError::InvalidCursor)
    );
    Ok(())
}

#[test]
fn calls_with_parameters_start_a_session_and_without_them_do_not() -> Result<(), String> {
    let text = "SubProceso Avisar()\nFinSubProceso\nAlgoritmo P\n  Avi\nFinAlgoritmo\n";
    let mut editing = session(text);
    let index = offer_index(
        &mut editing,
        1,
        text.find("Avi\n").unwrap_or(0) + 3,
        "Avisar",
    )?;
    editing
        .accept(1, Acceptance::Candidate(index))
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        editing.navigate_stop(2, StopDirection::Exit),
        Err(EditError::NoTemplateSession)
    );
    Ok(())
}

#[test]
fn inserting_a_template_reindents_and_breaks_the_line_when_needed() -> Result<(), String> {
    let text = "Algoritmo P\n  Si 1 = 1 Entonces\n    x <- 1;\nFinAlgoritmo\n";
    let mut editing = session(text);
    let start = text.find("x <- 1;").unwrap_or(0);
    let accepted = editing
        .accept(
            1,
            Acceptance::Template {
                construction: "while",
                start: start + 7,
                end: start + 7,
            },
        )
        .map_err(|error| format!("{error:?}"))?;
    assert!(editing.template_active());
    assert!(
        editing
            .document
            .text()
            .contains("    x <- 1;\n    Mientras condicion Hacer\n      \n    FinMientras\n")
    );
    let (selected_start, selected_end) = accepted.insertion.selection;
    assert_eq!(
        editing.document.text().get(selected_start..selected_end),
        Some("condicion")
    );
    Ok(())
}

#[test]
fn inserting_a_template_inside_a_block_header_indents_one_unit() -> Result<(), String> {
    let text = "Algoritmo P\n  Mientras 1 = 1 Hacer\n  \nFinAlgoritmo\n";
    let mut editing = session(text);
    let caret = text.find("Hacer\n").unwrap_or(0) + 5;
    editing
        .accept(
            1,
            Acceptance::Template {
                construction: "if",
                start: caret,
                end: caret,
            },
        )
        .map_err(|error| format!("{error:?}"))?;
    assert!(
        editing
            .document
            .text()
            .contains("Hacer\n    Si condicion Entonces")
    );
    Ok(())
}

#[test]
fn inserting_an_unknown_template_or_at_a_bad_offset_fails() {
    let mut editing = session("Algoritmo P\nFinAlgoritmo\n");
    let unknown = editing.accept(
        1,
        Acceptance::Template {
            construction: "nothing",
            start: 0,
            end: 0,
        },
    );
    assert_eq!(unknown.map(|_| ()), Err(EditError::InvalidCursor));
    let bad = editing.accept(
        1,
        Acceptance::Template {
            construction: "if",
            start: 9999,
            end: 9999,
        },
    );
    assert_eq!(bad.map(|_| ()), Err(EditError::InvalidCursor));
}
