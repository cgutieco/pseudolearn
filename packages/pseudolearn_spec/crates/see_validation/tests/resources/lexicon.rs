use see_validation::resources::lexicon::check;
use serde_json::json;

#[test]
fn checks_alias_collisions_and_complete_bilingual_signatures() -> Result<(), String> {
    let value = json!({"write":{"lexemas":{"es":"Escribir","en":"write"},"alias":{"es":["Mostrar"],"en":["print"]}}});
    check(&value)?;
    assert!(check(&json!({})).is_err());
    let mut colliding = value.clone();
    colliding.as_object_mut().ok_or("Missing lexicon")?.insert(
        "other".to_owned(),
        json!({"lexemas":{"es":"MOSTRAR","en":"other"}}),
    );
    assert!(check(&colliding).is_err());
    assert!(check(&json!({"f":{"lexemas":{"es":"f","en":"f"},"parametros":["unknown"],"retorno":"integer"}})).is_err());
    assert!(check(&json!({"f":{"lexemas":{"es":"f"}}})).is_err());
    Ok(())
}
