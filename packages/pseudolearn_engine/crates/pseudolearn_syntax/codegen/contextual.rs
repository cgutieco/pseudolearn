use serde_json::Value;

pub fn generate(value: &Value) -> Result<String, String> {
    let entries = value.as_object().ok_or("Missing contextual vocabulary")?;
    let mut identities = Vec::new();
    let mut spellings = Vec::new();
    for (identity, entry) in entries {
        for profile in ["es", "en"] {
            let word = entry
                .get("lexemas")
                .and_then(|entry| entry.get(profile))
                .and_then(Value::as_str)
                .ok_or("Missing contextual lexeme")?;
            identities.push((profile, word.to_lowercase(), identity));
            spellings.push((identity, profile, word));
        }
    }
    identities.sort_unstable();
    spellings.sort_unstable();
    let mut output = String::from("static CONTEXTUAL_IDENTITIES: &[(&str, &str, &str)] = &[\n");
    for (profile, word, identity) in identities {
        output.push_str(&format!("    ({profile:?}, {word:?}, {identity:?}),\n"));
    }
    output.push_str("];\n");
    output.push_str("static CONTEXTUAL_SPELLINGS: &[(&str, &str, &str)] = &[\n");
    for (identity, profile, word) in spellings {
        output.push_str(&format!("    ({identity:?}, {profile:?}, {word:?}),\n"));
    }
    output.push_str("];\n");
    output.push_str("pub fn contextual_identity(word: &str, profile: &str) -> Option<&'static str> {\n    let index = CONTEXTUAL_IDENTITIES.binary_search_by(|entry| (entry.0, entry.1).cmp(&(profile, word))).ok()?;\n    CONTEXTUAL_IDENTITIES.get(index).map(|entry| entry.2)\n}\n");
    output.push_str("pub fn contextual_spelling(identity: &str, profile: &str) -> Option<&'static str> {\n    let index = CONTEXTUAL_SPELLINGS.binary_search_by(|entry| (entry.0, entry.1).cmp(&(identity, profile))).ok()?;\n    CONTEXTUAL_SPELLINGS.get(index).map(|entry| entry.2)\n}\n");
    Ok(output)
}
