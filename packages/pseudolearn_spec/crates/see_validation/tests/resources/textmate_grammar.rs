use serde_json::json;

#[test]
fn validates_generated_grammar_definitions_and_rejects_missing_lexical_data() -> Result<(), String> {
    let mut specification = super::support::specification()?;
    for (term, value) in definitions() {
        specification.blocks.push(see_model::Block {
            kind: "definicion".to_owned(),
            fields: serde_json::from_value(json!({
                "id":"D1",
                "termino":term,
                "texto":"Dato léxico",
                "valor":value
            }))
            .map_err(|error| error.to_string())?,
        });
    }
    assert!(see_validation::resources::check(&specification).is_empty());
    let accent_fold = specification.blocks.last_mut().ok_or("Missing accent data")?;
    accent_fold
        .fields
        .insert("valor".to_owned(), json!({"a":[]}));
    assert!(
        see_validation::resources::check(&specification)
            .iter()
            .any(|error| error.starts_with("SEE-RESOURCE"))
    );
    Ok(())
}

fn definitions() -> Vec<(&'static str, serde_json::Value)> {
    vec![
        (
            "textmateIdentifier",
            json!({"start":"[a-z]","continue":"[a-z0-9]"}),
        ),
        (
            "textmateNumber",
            json!({"integer":"[0-9]+","real":"[0-9]+\\.[0-9]+"}),
        ),
        ("textmateComment", json!({"start":"//"})),
        (
            "textmateTextLiteral",
            json!({"delimiters":["\""],"escapeCodes":["n"],"lineBreaksAllowed":false}),
        ),
        ("textmateAccentFold", json!({"a":["á"]})),
    ]
}
