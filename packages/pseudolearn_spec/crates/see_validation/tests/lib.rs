mod support;
use see_model::contract::Lock;
use std::path::Path;

#[test]
fn valid_corpus_passes_and_empty_corpus_fails() -> Result<(), String> {
    assert!(
        see_validation::validate(&vec![support::specification()?], &Lock::default())?.is_empty()
    );
    assert!(
        see_validation::validate(&vec![], &Lock::default())?
            .iter()
            .any(|error| error.starts_with("SEE-FORMAT"))
    );
    Ok(())
}

#[test]
fn each_invalid_fixture_is_rejected_for_its_declared_reason() -> Result<(), String> {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../fixtures");
    let fixtures = rejected_fixtures();
    for (name, rule) in fixtures {
        let folder = root.join(name);
        let corpus = see_format::read(&folder.join("specifications"))?;
        let lock = if folder.join("specifications/specifications.lock").exists() {
            serde_json::from_str(
                &std::fs::read_to_string(folder.join("specifications/specifications.lock"))
                    .map_err(|error| error.to_string())?,
            )
            .map_err(|error| error.to_string())?
        } else {
            Lock::default()
        };
        let errors = see_validation::validate(&corpus, &lock)?;
        assert!(
            errors.iter().any(|error| error.starts_with(rule)),
            "{name}: {errors:?}"
        );
    }
    Ok(())
}

fn rejected_fixtures() -> Vec<(&'static str, &'static str)> {
    vec![
        ("duplicate", "SEE-DUPLICATE"),
        ("orphan", "SEE-ORPHAN"),
        ("captured", "SEE-CAPTURE"),
        ("version-freeze", "SEE-VERSION"),
        ("cycle", "SEE-CYCLE"),
        ("missing-profile", "SEE-PROFILE"),
        ("reference", "SEE-REFERENCE"),
        ("range", "SEE-RANGE"),
        ("unknown-field", "SEE-SCHEMA"),
        ("invalid-force", "SEE-FORCE"),
        ("trace-class", "SEE-TRACE-CLASS"),
        ("ir-expectation", "SEE-IR-EXPECTATION"),
        ("cli-exit", "SEE-CLI-EXIT"),
        ("limit-kind", "SEE-LIMIT-KIND"),
        ("measurement-protocol", "SEE-MEASUREMENT-PROTOCOL"),
        ("ir-coverage", "SEE-IR-COVERAGE"),
        ("ir-unknown", "SEE-IR-UNKNOWN"),
        ("profile-openers", "SEE-PROFILE-OPENERS"),
        ("message-parity", "SEE-MESSAGE-PARITY"),
        ("message-arguments", "SEE-MESSAGE-ARGUMENTS"),
    ]
}
