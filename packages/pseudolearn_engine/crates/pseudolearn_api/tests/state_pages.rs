use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "Algoritmo P\nDimension a[5] Como Entero;\na[0] <- 9;\nFinAlgoritmo\n";

fn execution(session: &mut ApiSession, program: &str) -> Result<Value, String> {
    let analysis = session
        .call("create_analysis", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let started = session
        .call("start", &json!({"analysis":analysis}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing execution")?;
    session.call("advance", &json!({"resource":started,"batch_size":4096}));
    Ok(started)
}

fn page(execution: &Value, event: u64, size: u64, cursor: Option<&Value>) -> Value {
    json!({"resource":execution,"query":"array_cells","target":1,"event":event,
        "page_size":size,"cursor":cursor})
}

#[test]
fn array_cells_are_paged_with_an_opaque_cursor() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(&mut session, PROGRAM)?;
    let first = session.call("query_page", &page(&started, 3, 2, None));
    assert_eq!(first.pointer("/value/truncated"), Some(&json!(true)));
    assert_eq!(first.pointer("/value/total"), Some(&json!(5)));
    assert_eq!(
        first.pointer("/value/elements/0"),
        Some(&json!({"valor":"9"}))
    );
    let cursor = first
        .pointer("/value/next_cursor")
        .cloned()
        .ok_or("cursor")?;
    let second = session.call("query_page", &page(&started, 3, 2, Some(&cursor)));
    assert_eq!(
        second
            .pointer("/value/elements")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(2)
    );
    let last_cursor = second
        .pointer("/value/next_cursor")
        .cloned()
        .ok_or("cursor")?;
    let last = session.call("query_page", &page(&started, 3, 2, Some(&last_cursor)));
    assert_eq!(last.pointer("/value/truncated"), Some(&json!(false)));
    assert_eq!(last.pointer("/value/next_cursor"), Some(&Value::Null));
    assert_eq!(
        last.pointer("/value/elements")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(1)
    );
    Ok(())
}

#[test]
fn cursor_reused_with_other_event_or_size_is_rejected_without_side_effects() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(&mut session, PROGRAM)?;
    let first = session.call("query_page", &page(&started, 3, 2, None));
    let cursor = first
        .pointer("/value/next_cursor")
        .cloned()
        .ok_or("cursor")?;
    for request in [
        page(&started, 2, 2, Some(&cursor)),
        page(&started, 3, 3, Some(&cursor)),
    ] {
        let rejected = session.call("query_page", &request);
        assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    }
    let again = session.call("query_page", &page(&started, 3, 2, Some(&cursor)));
    assert!(again.pointer("/value/elements").is_some());
    Ok(())
}

#[test]
fn cursor_from_another_session_is_rejected() -> Result<(), String> {
    let mut first_session = ApiSession::default();
    let first = execution(&mut first_session, PROGRAM)?;
    let issued = first_session.call("query_page", &page(&first, 3, 2, None));
    let cursor = issued
        .pointer("/value/next_cursor")
        .cloned()
        .ok_or("cursor")?;
    let mut other_session = ApiSession::default();
    let other = execution(&mut other_session, PROGRAM)?;
    other_session.call("query_page", &page(&other, 3, 2, None));
    let rejected = other_session.call("query_page", &page(&other, 3, 2, Some(&cursor)));
    assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn invalid_sizes_queries_and_references_are_usage_errors() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(&mut session, PROGRAM)?;
    for request in [
        page(&started, 3, 0, None),
        page(&started, 3, 1_000_000, None),
        json!({"resource":started,"query":"nope","event":3,"page_size":2}),
        json!({"resource":started,"query":"array_cells","target":99,"event":3,"page_size":2}),
        page(&started, 9_999, 2, None),
    ] {
        let rejected = session.call("query_page", &request);
        assert_eq!(
            rejected.pointer("/failure/family"),
            Some(&json!("usage")),
            "{request}"
        );
    }
    Ok(())
}

#[test]
fn frame_variables_and_object_fields_are_paged() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(
        &mut session,
        "Algoritmo P\nDefinir a Como Entero;\nDefinir b Como Entero;\nFinAlgoritmo\n",
    )?;
    let variables = session.call(
        "query_page",
        &json!({"resource":started,"query":"frame_variables","target":0,"event":2,"page_size":1}),
    );
    assert_eq!(variables.pointer("/value/total"), Some(&json!(2)));
    assert_eq!(variables.pointer("/value/truncated"), Some(&json!(true)));
    Ok(())
}

#[test]
fn empty_array_has_no_cells() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(
        &mut session,
        "Algoritmo P\nDimension a[0] Como Entero;\nFinAlgoritmo\n",
    )?;
    let result = session.call("query_page", &page(&started, 1, 4, None));
    assert_eq!(result.pointer("/value/total"), Some(&json!(0)));
    assert_eq!(result.pointer("/value/truncated"), Some(&json!(false)));
    Ok(())
}

#[test]
fn array_pages_report_dimensions_for_multidimensional_arrays() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(
        &mut session,
        "Algoritmo P\nDimension m[2,3] Como Entero;\nFinAlgoritmo\n",
    )?;
    let result = session.call("query_page", &page(&started, 1, 4, None));
    assert_eq!(result.pointer("/value/dimensions"), Some(&json!([2, 3])));
    assert_eq!(result.pointer("/value/total"), Some(&json!(6)));
    assert_eq!(result.pointer("/value/truncated"), Some(&json!(true)));
    Ok(())
}

#[test]
fn frame_queries_tag_scalar_values_with_their_type() -> Result<(), String> {
    let mut session = ApiSession::default();
    let started = execution(
        &mut session,
        "Algoritmo P\nDefinir n Como Entero;\nDefinir t Como Cadena;\nn <- 4;\nt <- \"hola\";\nFinAlgoritmo\n",
    )?;
    let frame = session.call(
        "query_frame",
        &json!({"resource":started,"event":7,"frame":0}),
    );
    assert_eq!(
        frame.pointer("/value/variables/n"),
        Some(&json!({"valor":"4","tipo":"entero"}))
    );
    assert_eq!(
        frame.pointer("/value/variables/t/tipo"),
        Some(&json!("texto"))
    );
    Ok(())
}
