use see_model::contract::Vocabulary;

fn vocabulary() -> Result<Vocabulary, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../specifications/cases/vocabulary.json");
    serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
        .map_err(|error| error.to_string())
}

#[test]
fn seeded_emi_pairs_are_reproducible_and_keep_the_independent_oracle() -> Result<(), String> {
    let vocabulary = vocabulary()?;
    let first = see_conformance::target_programs::generated(&vocabulary, 42, 0)?;
    assert_eq!(
        first,
        see_conformance::target_programs::generated(&vocabulary, 42, 0)?
    );
    assert_ne!(first.0, first.1);
    assert!(first.2.starts_with("sample!:"));
    assert!(first.2.ends_with('\n'));
    Ok(())
}

#[test]
fn missing_vocabulary_is_rejected() {
    assert!(see_conformance::target_programs::generated(&Vocabulary::new(), 42, 0).is_err());
    assert!(see_conformance::target_programs::format_boundaries(&Vocabulary::new()).is_err());
}

#[test]
fn format_boundaries_cover_signed_zeros_and_subnormals_in_both_profiles() -> Result<(), String> {
    let requests = see_conformance::target_programs::format_boundaries(&vocabulary()?)?;
    assert_eq!(requests.len(), 48);
    for bits in [
        0_u64,
        1,
        1_u64 << 63,
        0x8000_0000_0000_0001,
        0x7fef_ffff_ffff_ffff,
    ] {
        assert!(requests.iter().any(|(_, word)| *word == bits));
    }
    Ok(())
}
