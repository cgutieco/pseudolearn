use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn open(session: &mut ApiSession, program: &str) -> Result<u64, String> {
    let response = session.call(
        "open_edit_session",
        &json!({
            "program": program,
            "profile": "es",
            "strictness": "strict"
        }),
    );
    response
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| "missing edit session resource".to_owned())
}

fn query(session: &mut ApiSession, resource: u64, line: u32, column: u32, unit: &str) -> Value {
    session.call(
        "help_query",
        &json!({
            "resource": resource,
            "revision": "1",
            "position": {"line": line, "column": column, "unit": unit},
            "language": "en",
            "detail": "full"
        }),
    )
}

#[test]
fn compound_query_reports_identity_and_complete_ranges() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nPara i <- 1 Hasta 2 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n";
    let resource = open(&mut session, program)?;
    let response = query(&mut session, resource, 2, 27, "unicode_scalar");
    assert_eq!(
        response.pointer("/value/resolution/identity"),
        Some(&json!({"kind":"construction","id":"for","role":"step_clause"}))
    );
    assert_eq!(
        response.pointer("/value/resolution/lexical_range"),
        Some(&json!({"start":{"line":2,"column":21},"end":{"line":2,"column":29}}))
    );
    assert_eq!(
        response.pointer("/value/resolution/enclosing_range"),
        Some(&json!({"start":{"line":2,"column":1},"end":{"line":3,"column":8}}))
    );
    Ok(())
}

#[test]
fn scalar_and_utf16_queries_match_after_crlf_and_non_bmp_text() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\r\nEscribir \"😀\"; Longitud(\"x\");\r\nFinAlgoritmo\r\n";
    let resource = open(&mut session, program)?;
    let scalar = query(&mut session, resource, 2, 15, "unicode_scalar");
    let utf16 = query(&mut session, resource, 2, 16, "utf16");
    assert_eq!(
        scalar.pointer("/value/resolution"),
        utf16.pointer("/value/resolution")
    );
    assert_eq!(
        scalar.pointer("/value/resolution/lexical_range"),
        Some(&json!({"start":{"line":2,"column":15},"end":{"line":2,"column":23}}))
    );
    assert_eq!(
        scalar.pointer("/value/resolution/identity"),
        Some(&json!({"kind":"builtin","id":"length","role":"call"}))
    );
    Ok(())
}

#[test]
fn builtin_shadowing_resolves_the_semantic_symbol() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nDefinir Longitud Como Entero;\nLongitud <- 2;\nEscribir Longitud;\nFinAlgoritmo\n";
    let resource = open(&mut session, program)?;
    let response = query(&mut session, resource, 4, 10, "unicode_scalar");
    assert_eq!(
        response.pointer("/value/resolution/symbol"),
        Some(&json!({"category":"variable","identifier":"Longitud"}))
    );
    assert_eq!(
        response.pointer("/value/resolution/identity"),
        Some(&Value::Null)
    );
    Ok(())
}

#[test]
fn operators_have_resolution_even_without_editorial_help() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = open(&mut session, "Algoritmo P\nEscribir 1 + 2;\nFinAlgoritmo\n")?;
    let response = query(&mut session, resource, 2, 12, "unicode_scalar");
    assert_eq!(
        response.pointer("/value/resolution/identity"),
        Some(&json!({"kind":"operator","id":"plus","role":"binary"}))
    );
    assert_eq!(response.pointer("/value/help"), Some(&Value::Null));
    Ok(())
}

#[test]
fn literals_comments_trivia_and_end_of_document_have_no_resolution() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\r\nEscribir \"😀\"; // nota\r\nFinAlgoritmo\r\n";
    let resource = open(&mut session, program)?;
    for (line, column) in [(2, 11), (2, 14), (2, 15), (4, 1)] {
        let response = query(&mut session, resource, line, column, "unicode_scalar");
        assert_eq!(response.pointer("/value/resolution"), Some(&Value::Null));
        assert_eq!(response.pointer("/value/help"), Some(&Value::Null));
    }
    Ok(())
}

#[test]
fn exact_token_end_is_selectable_but_positions_beyond_line_are_rejected() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = open(&mut session, "Algoritmo P\nFinAlgoritmo\n")?;
    let token_end = query(&mut session, resource, 2, 13, "unicode_scalar");
    assert_eq!(
        token_end.pointer("/value/resolution/identity"),
        Some(&json!({"kind":"construction","id":"algorithm","role":"closing"}))
    );
    let outside = query(&mut session, resource, 2, 99, "unicode_scalar");
    assert_eq!(outside.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn utf16_surrogate_interiors_are_rejected() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nEscribir \"😀\";\nFinAlgoritmo\n";
    let resource = open(&mut session, program)?;
    let invalid = query(&mut session, resource, 2, 12, "utf16");
    assert_eq!(invalid.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}
