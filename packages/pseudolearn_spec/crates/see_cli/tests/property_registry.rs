mod support;

#[test]
fn requires_a_registry_when_the_corpus_declares_properties() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let path = fixture.root.join("specifications/see/sample.md");
    let mut source = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
    source.push_str("\n```propiedad\n{\"id\":\"P1\",\"regla\":\"R1\",\"generador\":{},\"propiedad\":\"same\",\"oraculo\":\"independent\"}\n```\n");
    std::fs::write(path, source).map_err(|error| error.to_string())?;
    let missing = fixture.execute(&["validate"])?;
    assert!(!missing.status.success());
    assert!(String::from_utf8_lossy(&missing.stderr).contains("property-conformance.json"));
    let registry = fixture.root.join("property-conformance.json");
    std::fs::write(
        &registry,
        "{\"format\":\"see-properties/1\",\"subjects\":[\"reference\"],\"entries\":[{\"reference\":\"SEE.TEST.SAMPLE@1.0.0#P1\",\"executor\":\"determinism\",\"seed\":42,\"samples\":1}]}",
    )
    .map_err(|error| error.to_string())?;
    let valid = fixture.execute(&["validate"])?;
    assert!(
        valid.status.success(),
        "{}",
        String::from_utf8_lossy(&valid.stderr)
    );
    std::fs::write(registry, "{}").map_err(|error| error.to_string())?;
    let invalid = fixture.execute(&["validate"])?;
    assert!(!invalid.status.success());
    assert!(String::from_utf8_lossy(&invalid.stderr).contains("SEE-PROPERTY"));
    Ok(())
}
