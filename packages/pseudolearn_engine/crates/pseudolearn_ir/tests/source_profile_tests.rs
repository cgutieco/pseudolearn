use pseudolearn_ir::{Module, SourceProfile, parse_module, print_canonical, verify_module};
use pseudolearn_source::SourceId;

fn profile(source: u32, vocabulary: &str) -> SourceProfile {
    SourceProfile {
        source_id: SourceId::new(source),
        vocabulary: vocabulary.to_owned(),
    }
}

#[test]
fn profile_lines_round_trip_in_source_order() -> Result<(), String> {
    let mut module = Module::new("P".to_owned(), "es".to_owned());
    module.profiles = vec![profile(7, "en"), profile(2, "es")];
    let text = print_canonical(&module);
    assert_eq!(text, "module P es\nprofile 2 es\nprofile 7 en\n");
    let parsed = parse_module(&text)?;
    assert_eq!(parsed.profiles, vec![profile(2, "es"), profile(7, "en")]);
    assert_eq!(print_canonical(&parsed), text);
    Ok(())
}

#[test]
fn module_without_profiles_prints_as_before() {
    let module = Module::new("P".to_owned(), "en".to_owned());
    assert_eq!(print_canonical(&module), "module P en\n");
}

#[test]
fn source_profile_overrides_the_module_vocabulary_only_for_its_source() {
    let mut module = Module::new("P".to_owned(), "es".to_owned());
    module.profiles = vec![profile(3, "en")];
    assert_eq!(module.vocabulary_for(SourceId::new(3)), "en");
    assert_eq!(module.vocabulary_for(SourceId::new(4)), "es");
    assert_eq!(module.vocabulary_for(SourceId::STANDALONE), "es");
}

#[test]
fn duplicate_profile_for_one_source_is_rejected_by_the_verifier() {
    let mut module = Module::new("P".to_owned(), "es".to_owned());
    module.profiles = vec![profile(3, "en"), profile(3, "es")];
    assert_eq!(verify_module(&module), Err("IR.MODEL#R1"));
}

#[test]
fn malformed_profile_lines_are_parse_errors() {
    assert!(parse_module("module P es\nprofile en\n").is_err());
    assert!(parse_module("module P es\nprofile 3\n").is_err());
    assert!(parse_module("module P es\nprofile -1 en\n").is_err());
}
