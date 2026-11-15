use pseudolearn_lexicon::Profile;
use pseudolearn_syntax::{contextual_identity, contextual_spelling};
use serde_json::Value;

#[test]
fn resolves_every_contextual_form_and_spelling() -> Result<(), String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let entries = corpus
        .pointer("/resources/contextualVocabulary")
        .and_then(Value::as_object)
        .ok_or("Missing contextual vocabulary")?;
    for (identity, entry) in entries {
        for (profile_name, profile) in [("es", Profile::Spanish), ("en", Profile::English)] {
            let spelling = entry
                .pointer(&format!("/lexemas/{profile_name}"))
                .and_then(Value::as_str)
                .ok_or("Missing contextual spelling")?;
            assert_eq!(
                contextual_identity(&spelling.to_lowercase(), profile.as_str()),
                Some(identity.as_str())
            );
            assert_eq!(
                contextual_spelling(identity, profile.as_str()),
                Some(spelling)
            );
        }
    }
    Ok(())
}

#[test]
fn rejects_unknown_contextual_forms_and_profiles() {
    assert_eq!(contextual_identity("unknowncontextualform", "en"), None);
    assert_eq!(contextual_identity("defer", "unknown"), None);
    assert_eq!(contextual_spelling("unknownIdentity", "en"), None);
}
