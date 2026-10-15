mod support;
use serde_json::json;

#[test]
fn validates_bilingual_diagnostics_and_rejects_missing_or_mismatched_markers() -> Result<(), String>
{
    let mut specification = support::specification()?;
    let definition = see_model::Block {
        kind: "definicion".to_owned(),
        fields: serde_json::from_value(json!({"id":"D1", "termino":"diagnostics", "texto":"Catálogo", "valor":{"sample":{"mensajes":{"es":"Error {name}","en":"Error {name}"},"argumentos":["name"],"tipos_argumentos":{"name":"lexema"},"politica":"A","severidad":{"estricto":"error","flexible":"error"}}}}))
            .map_err(|error| error.to_string())?,
    };
    specification.blocks.push(definition);
    assert!(see_validation::resources::check(&specification).is_empty());
    for (field, value) in [
        ("mensajes", json!({"es":"Error {name}"})),
        (
            "mensajes",
            json!({"es":"Error {name}","en":"Error {other}"}),
        ),
        (
            "severidad",
            json!({"estricto":"warning","flexible":"error"}),
        ),
    ] {
        let mut malformed = specification.clone();
        let definition = malformed.blocks.last_mut().ok_or("Missing definition")?;
        let entry = definition
            .fields
            .get_mut("valor")
            .and_then(|value| value.get_mut("sample"))
            .and_then(serde_json::Value::as_object_mut)
            .ok_or("Missing entry")?;
        entry.insert(field.to_owned(), value);
        assert!(
            see_validation::resources::check(&malformed)
                .iter()
                .any(|error| error.starts_with("SEE-RESOURCE"))
        );
    }
    Ok(())
}

#[path = "resources/analysis_limits.rs"]
mod analysis_limits;

#[path = "resources/structural.rs"]
mod structural;
