use see_generators::{GenerationSeed, generate};
use see_model::contract::Vocabulary;

#[test]
fn rejects_missing_vocabulary_and_unknown_profiles() {
    let seed = GenerationSeed {
        seed: 42,
        sample: 0,
    };
    assert!(generate(seed, "es", &Vocabulary::new()).is_err());
    assert!(generate(seed, "unknown", &Vocabulary::new()).is_err());
}

#[test]
fn generates_repeatable_structure_with_independent_operands() -> Result<(), String> {
    let vocabulary = vocabulary();
    let mut empty = false;
    for sample in 0..100 {
        let seed = GenerationSeed { seed: 42, sample };
        let spanish = generate(seed, "es", &vocabulary)?;
        let english = generate(seed, "en", &vocabulary)?;
        assert_eq!(spanish, generate(seed, "es", &vocabulary)?);
        assert_eq!(spanish.elements, english.elements);
        assert_eq!(spanish.initial, english.initial);
        assert_eq!(spanish.input, english.input);
        assert!(spanish.source.contains("spanish_classKeyword"));
        assert!(!spanish.source.contains("{{lexema:"));
        empty |= spanish.elements == 0;
    }
    assert!(empty);
    Ok(())
}

fn vocabulary() -> Vocabulary {
    let mut vocabulary = Vocabulary::new();
    for identity in [
        "classKeyword",
        "publicVisibility",
        "declare",
        "typeConnector",
        "integerType",
        "endClass",
        "subroutine",
        "byReference",
        "assignment",
        "plus",
        "endSubroutine",
        "algorithm",
        "stringType",
        "dimension",
        "forKeyword",
        "to",
        "step",
        "doKeyword",
        "endFor",
        "newInstance",
        "function:shallowCopy",
        "read",
        "write",
        "endAlgorithm",
    ] {
        vocabulary.insert(
            identity.to_owned(),
            std::collections::BTreeMap::from([
                ("es".to_owned(), format!("spanish_{identity}")),
                ("en".to_owned(), format!("english_{identity}")),
            ]),
        );
    }
    vocabulary
}

#[test]
fn resolves_templates_against_the_actual_exported_vocabulary() -> Result<(), String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../specifications/cases/vocabulary.json");
    let vocabulary: Vocabulary =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    for sample in 0..100 {
        for profile in ["es", "en"] {
            let program = generate(GenerationSeed { seed: 42, sample }, profile, &vocabulary)?;
            assert!(!program.source.contains("{{lexema:"));
            assert!(!program.source.is_empty());
        }
    }
    Ok(())
}

#[test]
fn rejects_stale_generated_sources_consumed_by_the_engine() -> Result<(), String> {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let vocabulary: Vocabulary = serde_json::from_str(
        &std::fs::read_to_string(root.join("specifications/cases/vocabulary.json"))
            .map_err(|error| error.to_string())?,
    )
    .map_err(|error| error.to_string())?;
    let cases: Vec<serde_json::Value> = serde_json::from_str(
        &std::fs::read_to_string(root.join("results/r5-generator-programs.json"))
            .map_err(|error| error.to_string())?,
    )
    .map_err(|error| error.to_string())?;
    let mut identities = std::collections::BTreeSet::new();
    for case in &cases {
        let seed = case
            .get("seed")
            .and_then(serde_json::Value::as_u64)
            .ok_or("Missing seed")?;
        let sample = case
            .get("sample")
            .and_then(serde_json::Value::as_u64)
            .and_then(|sample| u32::try_from(sample).ok())
            .ok_or("Missing sample")?;
        let profile = case
            .get("profile")
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing profile")?;
        let generated = generate(GenerationSeed { seed, sample }, profile, &vocabulary)?;
        assert_eq!(
            case.get("program").and_then(serde_json::Value::as_str),
            Some(generated.source.as_str()),
            "SEE-GENERATOR-STALE"
        );
        assert!(identities.insert((seed, sample, profile.to_owned())));
    }
    assert_eq!(identities.len(), 200);
    Ok(())
}
