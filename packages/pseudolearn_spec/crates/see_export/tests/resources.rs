mod support;
use serde_json::json;

#[test]
fn extracts_normative_resources_and_rejects_duplicate_names() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.blocks.push(see_model::Block {
        kind: "definicion".to_owned(),
        fields: serde_json::from_value(json!({"id":"D1", "termino":"vocabulary", "texto":"Lexemas", "valor":{"write":{"lexemas":{"es":"Escribir","en":"write"}}}}))
            .map_err(|error| error.to_string())?,
    });
    let resources = see_export::resources::generate(&vec![specification.clone()])?;
    assert_eq!(
        see_export::resources::vocabulary(&resources)?,
        json!({"write":{"es":"Escribir","en":"write"}})
    );
    assert!(see_export::resources::generate(&vec![specification.clone(), specification]).is_err());
    assert_eq!(see_export::resources::vocabulary(&json!({}))?, json!({}));
    assert!(see_export::resources::vocabulary(&json!({"functions":{"invalid":{}}})).is_err());
    Ok(())
}
