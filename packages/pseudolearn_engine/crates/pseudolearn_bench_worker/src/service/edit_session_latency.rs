use crate::service::completion_quality::large_document_text;
use crate::service::statistics::summarize;
use pseudolearn_api::service::{EditSession, Profile, TextChange};
use serde_json::{Value, json};
use std::time::Instant;

const ITERATIONS: usize = 30;

fn milliseconds(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1000.0
}

fn failure(error: impl std::fmt::Debug) -> String {
    format!("{error:?}")
}

pub fn edit_session_latency() -> Result<Value, String> {
    let (text, _, lines) = large_document_text()?;
    let cursor = text
        .find("  Esc\n")
        .map_or(0, |found| found.saturating_add(5));
    let (mut applied, mut completed, mut typed) = (Vec::new(), Vec::new(), Vec::new());
    for _ in 0..ITERATIONS {
        let mut session = EditSession::new(text.clone(), Profile::Spanish, true);
        let newline = TextChange {
            start_utf8: cursor,
            end_utf8: cursor,
            text: String::from("\n"),
        };
        let begun = Instant::now();
        let revision = session
            .apply_edits(session.revision, &[newline])
            .map_err(failure)?;
        applied.push(milliseconds(begun));
        let begun = Instant::now();
        session.complete(revision, cursor).map_err(failure)?;
        completed.push(milliseconds(begun));
        let begun = Instant::now();
        session
            .on_type(revision, cursor.saturating_add(1), '\n')
            .map_err(failure)?;
        typed.push(milliseconds(begun));
    }
    let report = |samples: &[f64]| summarize(samples).map(|summary| summary.to_json());
    Ok(json!({
        "lines": lines,
        "apply_edit_ms": report(&applied),
        "complete_ms": report(&completed),
        "on_type_ms": report(&typed),
    }))
}
