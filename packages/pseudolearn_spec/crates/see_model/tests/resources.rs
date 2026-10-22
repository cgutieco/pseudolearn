use see_model::Block;
use serde_json::json;

#[test]
fn preserves_catalog_editorial_values_in_definition_blocks() -> Result<(), String> {
    let value = json!({
        "kind": "definicion",
        "fields": {
            "id": "D1",
            "termino": "helpCatalog",
            "texto": "Catálogo",
            "valor": {
                "format": "help-catalog/1",
                "cards": [{
                    "id": "construct.sample",
                    "content": {
                        "es": {"purpose": "Explicación editorial"},
                        "en": {"purpose": "Editorial explanation"}
                    }
                }],
                "exclusions": []
            }
        }
    });
    let block: Block = serde_json::from_value(value.clone()).map_err(|error| error.to_string())?;
    let restored = serde_json::to_value(block).map_err(|error| error.to_string())?;
    assert_eq!(restored, value);
    Ok(())
}
