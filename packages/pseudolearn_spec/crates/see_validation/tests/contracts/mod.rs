pub fn corpus(id: &str, blocks: serde_json::Value) -> Result<see_model::Corpus, String> {
    let mut specification = see_format::parsing::parse(
        "sample.md",
        include_str!("../../../../fixtures/valid/specifications/sample.md"),
    )?;
    specification.metadata.id = id.to_owned();
    specification.blocks = serde_json::from_value(blocks).map_err(|error| error.to_string())?;
    Ok(vec![specification])
}
