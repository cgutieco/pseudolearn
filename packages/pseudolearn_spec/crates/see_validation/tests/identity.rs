mod support;

#[test]
fn validates_ascii_identity_and_rejects_reused_elements() -> Result<(), String> {
    for valid in [
        "SEE.FORMAT",
        "LANG.TYPES.INTEGER",
        "TOOL.SERVICE.LOSSLESS-TREE",
    ] {
        assert!(see_validation::identity::valid_id(valid));
    }
    for invalid in [
        "",
        "LANG",
        "lang.TYPES.INTEGER",
        "LANG..INTEGER",
        "LANG.TYPES.ENTÉRO",
        "LANG.X@1",
    ] {
        assert!(!see_validation::identity::valid_id(invalid));
    }
    let mut specification = support::specification()?;
    specification
        .blocks
        .push(specification.blocks.first().ok_or("Missing block")?.clone());
    assert!(
        see_validation::identity::check(&vec![specification])
            .iter()
            .any(|error| error.starts_with("SEE-DUPLICATE"))
    );
    Ok(())
}
