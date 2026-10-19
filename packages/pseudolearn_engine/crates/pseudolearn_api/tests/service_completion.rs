use pseudolearn_api::ApiSession;
use pseudolearn_lexicon::Profile;
use pseudolearn_service::{template_constructions, template_parses_cleanly};
use serde_json::{Value, json};

fn complete(session: &mut ApiSession, program: &str, cursor: usize) -> Value {
    session.call(
        "complete",
        &json!({
            "program": program,
            "profile": "es",
            "strictness": "strict",
            "revision": "17",
            "cursor_utf8": cursor.to_string()
        }),
    )
}

#[test]
fn completion_uses_the_requested_revision_and_utf8_edit_range() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nDefinir total Como \nFinAlgoritmo\n";
    let cursor = program.find('\n').ok_or("missing first line")? + 1 + "Definir total Como ".len();
    let result = complete(&mut session, program, cursor);
    assert_eq!(result.pointer("/value/revision"), Some(&json!("17")));
    assert_eq!(
        result.pointer("/value/text_edit"),
        Some(&json!({
            "start_utf8": cursor.to_string(),
            "end_utf8": cursor.to_string()
        }))
    );
    let candidates = result
        .pointer("/value/candidates")
        .and_then(Value::as_array)
        .ok_or("missing candidates")?;
    for label in ["Entero", "Real", "Logico", "Caracter", "Cadena"] {
        assert!(
            candidates
                .iter()
                .any(|candidate| { candidate.get("label") == Some(&json!(label)) })
        );
    }
    Ok(())
}

#[test]
fn completion_rejects_utf8_offsets_inside_a_scalar() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nEscribir \"🧩\";\nFinAlgoritmo\n";
    let scalar = program.find('🧩').ok_or("missing scalar")?;
    let result = complete(&mut session, program, scalar + 1);
    assert_eq!(result.pointer("/failure/family"), Some(&json!("usage")));
    Ok(())
}

#[test]
fn completion_rejects_outdated_profiles_and_revision_values() {
    let mut session = ApiSession::default();
    let valid = json!({
        "program": "Algoritmo P\nFinAlgoritmo\n",
        "profile": "unknown",
        "strictness": "strict",
        "revision": "1",
        "cursor_utf8": "0"
    });
    assert_eq!(
        session.call("complete", &valid).pointer("/failure/family"),
        Some(&json!("usage"))
    );
    let invalid_revision = json!({
        "program": "Algoritmo P\nFinAlgoritmo\n",
        "profile": "es",
        "strictness": "strict",
        "revision": "revision-one",
        "cursor_utf8": "0"
    });
    assert_eq!(
        session
            .call("complete", &invalid_revision)
            .pointer("/failure/family"),
        Some(&json!("usage"))
    );
}

#[test]
fn templates_follow_the_generated_profile_vocabulary() -> Result<(), String> {
    let mut session = ApiSession::default();
    let spanish = session.call("completion_templates", &json!({"profile":"es"}));
    let english = session.call("completion_templates", &json!({"profile":"en"}));
    let spanish_items = spanish
        .pointer("/value/templates")
        .and_then(Value::as_array)
        .ok_or("missing Spanish templates")?;
    let english_items = english
        .pointer("/value/templates")
        .and_then(Value::as_array)
        .ok_or("missing English templates")?;
    assert!(
        spanish_items
            .iter()
            .any(|template| template.get("label") == Some(&json!("Algoritmo")))
    );
    assert!(
        english_items
            .iter()
            .any(|template| template.get("label") == Some(&json!("Algorithm")))
    );
    for (items, profile) in [
        (spanish_items, Profile::Spanish),
        (english_items, Profile::English),
    ] {
        assert_eq!(items.len(), template_constructions().len());
        for template_entry in items {
            let construction = template_entry
                .get("construction")
                .and_then(Value::as_str)
                .ok_or("missing construction")?;
            assert!(template_parses_cleanly(construction, profile));
        }
    }
    Ok(())
}
