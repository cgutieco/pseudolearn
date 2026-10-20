use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn open(session: &mut ApiSession, program: &str) -> Result<u64, String> {
    let response = session.call(
        "open_edit_session",
        &json!({"program": program, "profile": "es", "strictness": "strict"}),
    );
    response
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("{response}"))
}

fn call(session: &mut ApiSession, operation: &str, arguments: Value) -> Value {
    session.call(operation, &arguments)
}

#[test]
fn opening_a_session_reports_the_first_revision_and_validates_arguments() -> Result<(), String> {
    let mut session = ApiSession::default();
    let response = session.call(
        "open_edit_session",
        &json!({"program": "Algoritmo P\nFinAlgoritmo\n", "profile": "es", "strictness": "strict"}),
    );
    assert_eq!(response.pointer("/value/revision"), Some(&json!("1")));
    open(&mut session, "")?;
    for arguments in [
        json!({"program": "", "profile": "xx", "strictness": "strict"}),
        json!({"program": "", "profile": "es", "strictness": "loose"}),
        json!({"profile": "es", "strictness": "strict"}),
        json!({"program": "", "strictness": "strict"}),
        json!({"program": "", "profile": "es"}),
        json!({"resource": u64::MAX, "invalid": true}),
    ] {
        let failed = session.call("open_edit_session", &arguments);
        assert_eq!(
            failed.pointer("/failure/family"),
            Some(&json!("usage")),
            "{failed}"
        );
    }
    Ok(())
}

#[test]
fn accepting_a_template_returns_stops_and_navigation_walks_them() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\n  Par\nFinAlgoritmo\n";
    let resource = open(&mut session, program)?;
    let cursor = program.find("Par").unwrap_or(0) + 3;
    let listed = call(
        &mut session,
        "edit_complete",
        json!({"resource": resource, "revision": "1", "cursor_utf8": cursor.to_string()}),
    );
    let rows = listed
        .pointer("/value/candidates")
        .and_then(Value::as_array)
        .ok_or("no candidates")?;
    let chosen = rows
        .iter()
        .find(|row| row.get("label") == Some(&json!("Para")))
        .and_then(|row| row.get("id").cloned())
        .ok_or("Para not offered")?;
    let accepted = call(
        &mut session,
        "edit_accept",
        json!({"resource": resource, "revision": "1", "candidate_id": chosen}),
    );
    assert_eq!(accepted.pointer("/value/revision"), Some(&json!("2")));
    assert_eq!(
        accepted.pointer("/value/stops/1/role"),
        Some(&json!("expression"))
    );
    assert!(
        accepted
            .pointer("/value/lsp_snippet")
            .is_some_and(Value::is_string)
    );
    let next = call(
        &mut session,
        "edit_navigate_stop",
        json!({"resource": resource, "revision": "2", "direction": "next"}),
    );
    assert_eq!(next.pointer("/value/selection/index"), Some(&json!(2)));
    let exit = call(
        &mut session,
        "edit_navigate_stop",
        json!({"resource": resource, "revision": "2", "direction": "exit"}),
    );
    assert!(exit.pointer("/value/exited/caret_utf8").is_some());
    Ok(())
}

#[test]
fn stale_revisions_are_reported_without_effects() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = open(&mut session, "Algoritmo P\nFinAlgoritmo\n")?;
    let applied = call(
        &mut session,
        "apply_edit",
        json!({"resource": resource, "revision": "1", "edits": [
            {"start_utf8": "0", "end_utf8": "0", "text": " "}
        ]}),
    );
    assert_eq!(applied.pointer("/value/revision"), Some(&json!("2")));
    for operation in ["apply_edit", "edit_complete", "edit_on_type", "edit_accept"] {
        let stale = call(
            &mut session,
            operation,
            json!({"resource": resource, "revision": "1", "edits": [], "cursor_utf8": "0",
                   "character": "\n", "candidate_id": "0"}),
        );
        assert_eq!(
            stale.pointer("/value/stale_revision"),
            Some(&json!("2")),
            "{operation}"
        );
    }
    Ok(())
}

#[test]
fn on_type_returns_edits_in_utf8_coordinates() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = open(&mut session, "Algoritmo P\n\n")?;
    let typed = call(
        &mut session,
        "edit_on_type",
        json!({"resource": resource, "revision": "1", "cursor_utf8": "12", "character": "\n"}),
    );
    assert_eq!(typed.pointer("/value/revision"), Some(&json!("2")));
    assert_eq!(typed.pointer("/value/cursor_utf8"), Some(&json!("14")));
    assert!(
        typed
            .pointer("/value/edits")
            .and_then(Value::as_array)
            .is_some_and(|edits| !edits.is_empty())
    );
    Ok(())
}

#[test]
fn malformed_requests_and_released_sessions_are_usage_failures() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = open(&mut session, "Algoritmo P\nFinAlgoritmo\n")?;
    for (operation, arguments) in [
        ("apply_edit", json!({"resource": resource, "revision": "1"})),
        (
            "apply_edit",
            json!({"resource": resource, "revision": "x", "edits": []}),
        ),
        (
            "edit_complete",
            json!({"resource": resource, "revision": "1", "cursor_utf8": "-1"}),
        ),
        (
            "edit_complete",
            json!({"resource": resource, "revision": "1", "cursor_utf8": "999"}),
        ),
        (
            "edit_on_type",
            json!({"resource": resource, "revision": "1", "cursor_utf8": "0"}),
        ),
        (
            "edit_navigate_stop",
            json!({"resource": resource, "revision": "1", "direction": "up"}),
        ),
        (
            "edit_navigate_stop",
            json!({"resource": resource, "revision": "1", "direction": "next"}),
        ),
        (
            "edit_accept",
            json!({"resource": resource, "revision": "1", "candidate_id": "0"}),
        ),
    ] {
        let failed = session.call(operation, &arguments);
        assert_eq!(
            failed.pointer("/failure/family"),
            Some(&json!("usage")),
            "{operation} {failed}"
        );
    }
    call(&mut session, "release", json!({"resource": resource}));
    let gone = session.call(
        "edit_complete",
        &json!({"resource": resource, "revision": "1", "cursor_utf8": "0"}),
    );
    assert_eq!(gone.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn template_insertion_reports_the_active_session_and_selection() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\n  \nFinAlgoritmo\n";
    let resource = open(&mut session, program)?;
    let caret = program.find("  \n").unwrap_or(0) + 2;
    let inserted = call(
        &mut session,
        "edit_insert_template",
        json!({"resource": resource, "revision": "1", "construction": "while",
               "start_utf8": caret.to_string(), "end_utf8": caret.to_string()}),
    );
    assert_eq!(
        inserted.pointer("/value/template_active"),
        Some(&json!(true))
    );
    assert_eq!(inserted.pointer("/value/revision"), Some(&json!("2")));
    assert!(inserted.pointer("/value/selection/start_utf8").is_some());
    let unknown = call(
        &mut session,
        "edit_insert_template",
        json!({"resource": resource, "revision": "2", "construction": "nothing",
               "start_utf8": "0", "end_utf8": "0"}),
    );
    assert_eq!(unknown.pointer("/failure/family"), Some(&json!("usage")));
    let ended = call(
        &mut session,
        "apply_edit",
        json!({"resource": resource, "revision": "2", "edits": [
            {"start_utf8": "0", "end_utf8": "0", "text": " "}
        ]}),
    );
    assert_eq!(ended.pointer("/value/template_active"), Some(&json!(false)));
    Ok(())
}
