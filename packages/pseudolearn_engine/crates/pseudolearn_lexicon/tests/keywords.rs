use pseudolearn_lexicon::{Profile, detect_opener, find_builtin, find_keyword};

#[test]
fn resolves_every_generated_form_and_rejects_near_misses() -> Result<(), String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: serde_json::Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    for (resource, builtin) in [("vocabulary", false), ("functions", true)] {
        let entries = corpus
            .get("resources")
            .and_then(|resources| resources.get(resource))
            .and_then(serde_json::Value::as_object)
            .ok_or("Missing resource")?;
        for (identity, entry) in entries {
            for profile in [Profile::Spanish, Profile::English] {
                let canonical = entry
                    .get("lexemas")
                    .and_then(|lexemes| lexemes.get(profile.as_str()))
                    .and_then(serde_json::Value::as_str)
                    .ok_or("Missing lexeme")?;
                let mut forms = vec![canonical];
                forms.extend(
                    entry
                        .get("alias")
                        .and_then(|aliases| aliases.get(profile.as_str()))
                        .and_then(serde_json::Value::as_array)
                        .into_iter()
                        .flatten()
                        .filter_map(serde_json::Value::as_str),
                );
                for form in forms {
                    let resolved = if builtin {
                        find_builtin(&form.to_uppercase(), profile).map(|kind| kind.as_str())
                    } else {
                        find_keyword(&form.to_uppercase(), profile).map(|kind| kind.as_str())
                    };
                    assert_eq!(resolved, Some(identity.as_str()), "{form}");
                    let miss = format!("{form}_unrecognized");
                    assert!(find_keyword(&miss, profile).is_none());
                    assert!(find_builtin(&miss, profile).is_none());
                }
            }
        }
    }
    Ok(())
}

#[test]
fn preserves_english_accents_and_normalizes_spanish_nfd() {
    assert!(find_keyword("cla\u{301}se", Profile::Spanish).is_some());
    assert!(find_keyword("cláss", Profile::English).is_none());
    assert_eq!(detect_opener("cláss"), None);
    assert_eq!(detect_opener("cla\u{301}se"), Some(Profile::Spanish));
    assert!(find_keyword("", Profile::Spanish).is_none());
}
