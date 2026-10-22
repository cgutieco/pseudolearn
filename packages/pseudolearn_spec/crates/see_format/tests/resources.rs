mod support;
use see_model::Block;
use serde_json::json;

#[test]
fn preserves_resource_blocks_and_ignores_markdown_prose() -> Result<(), String> {
    let mut specification = support::specification()?;
    let value = json!({
        "format": "help-catalog/1",
        "cards": [{
            "id": "construct.sample",
            "content": {
                "es": {"purpose": "Propósito editorial"},
                "en": {"purpose": "Editorial purpose"}
            }
        }],
        "exclusions": []
    });
    specification.blocks.push(Block {
        kind: "definicion".to_owned(),
        fields: serde_json::from_value(json!({
            "id": "D1",
            "termino": "helpCatalog",
            "texto": "Catálogo",
            "valor": value
        }))
        .map_err(|error| error.to_string())?,
    });
    let markdown = see_format::write(&specification)?;
    let parsed = see_format::parsing::parse("sample.md", &markdown)?;
    assert_eq!(parsed, specification);
    let with_prose = format!("{markdown}\nProsa no modelada.\n");
    let parsed_with_prose = see_format::parsing::parse("sample.md", &with_prose)?;
    assert_eq!(parsed_with_prose, specification);
    Ok(())
}
