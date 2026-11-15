mod support;

#[test]
fn exports_contracts_hashes_and_area_index() -> Result<(), String> {
    let specification = support::specification()?;
    let export = see_export::generate(&vec![specification.clone()])?;
    assert_eq!(
        export.get("format").and_then(|value| value.as_str()),
        Some("see-export/1")
    );
    assert!(
        export
            .get("areas")
            .and_then(|areas| areas.get("LANG.TEST"))
            .is_some()
    );
    assert!(
        export
            .get("specifications")
            .and_then(|value| value.as_array())
            .is_some_and(|values| values.len() == 1)
    );
    assert_ne!(see_export::generate(&vec![])?, export);
    Ok(())
}
