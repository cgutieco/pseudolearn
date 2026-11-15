pub fn specification() -> Result<see_model::Specification, String> {
    see_format::parsing::parse(
        "sample.md",
        include_str!("../../../../fixtures/valid/specifications/sample.md"),
    )
}
