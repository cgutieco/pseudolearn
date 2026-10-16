use see_conformance::memory_fixtures::generate;
use see_model::contract::Vocabulary;

fn vocabulary() -> Result<Vocabulary, String> {
    serde_json::from_str(include_str!(
        "../../../specifications/cases/vocabulary.json"
    ))
    .map_err(|error| error.to_string())
}

#[test]
fn generated_graphs_are_reproducible_and_include_translated_programs() -> Result<(), String> {
    let vocabulary = vocabulary()?;
    let first = generate(42, 10, &vocabulary)?;
    assert_eq!(first, generate(42, 10, &vocabulary)?);
    assert_ne!(first, generate(43, 10, &vocabulary)?);
    for fixture in first {
        assert!(
            fixture
                .get("expectedCells")
                .and_then(serde_json::Value::as_u64)
                .is_some_and(|cells| cells >= 4)
        );
        assert!(
            fixture
                .get("english")
                .and_then(serde_json::Value::as_str)
                .is_some_and(|program| program.contains("class Node"))
        );
    }
    Ok(())
}

#[test]
fn empty_sample_sets_do_not_require_vocabulary() -> Result<(), String> {
    assert!(generate(0, 0, &Default::default())?.is_empty());
    Ok(())
}
