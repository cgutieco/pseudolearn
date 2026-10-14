mod support;
use serde_json::json;

#[test]
fn rejects_missing_duplicate_and_undefined_section_destinations() -> Result<(), String> {
    let corpus = vec![support::specification()?];
    let manifest =
        json!({"secciones":{"1":"Introduction"},"correspondencias":{"1":["LANG.TEST.SAMPLE"]}});
    let index = "## Correspondencia del corpus\n| 1 | Introduction | `LANG.TEST.SAMPLE` |\n";
    see_validation::migration::check(&manifest, index, &corpus)?;
    assert!(see_validation::migration::check(&manifest, "", &corpus).is_err());
    assert!(
        see_validation::migration::check(
            &manifest,
            &format!("{index}| 1 | Introduction | `LANG.TEST.SAMPLE` |\n"),
            &corpus
        )
        .is_err()
    );
    assert!(see_validation::migration::check(&manifest, index, &vec![]).is_err());
    assert!(
        see_validation::migration::check(
            &json!({"secciones":{"1":"Introduction"},"correspondencias":{}}),
            index,
            &corpus
        )
        .is_err()
    );
    Ok(())
}
