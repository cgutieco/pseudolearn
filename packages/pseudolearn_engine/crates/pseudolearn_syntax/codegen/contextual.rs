use serde_json::Value;

pub fn generate(value: &Value) -> Result<String, String> {
    let entries = value.as_object().ok_or("Missing contextual vocabulary")?;
    let mut output = String::from(
        "pub fn contextual_identity(word: &str, profile: &str) -> Option<&'static str> { match (profile, word) {\n",
    );
    for (identity, entry) in entries {
        for profile in ["es", "en"] {
            let word = entry
                .get("lexemas")
                .and_then(|entry| entry.get(profile))
                .and_then(Value::as_str)
                .ok_or("Missing contextual lexeme")?;
            output.push_str(&format!(
                "({profile:?}, {:?}) => Some({identity:?}),\n",
                word.to_lowercase()
            ));
        }
    }
    output.push_str("_ => None } }\n");
    output.push_str("pub fn contextual_spelling(identity: &str, profile: &str) -> Option<&'static str> { match (identity, profile) {\n");
    for (identity, entry) in entries {
        for profile in ["es", "en"] {
            let word = entry
                .get("lexemas")
                .and_then(|entry| entry.get(profile))
                .and_then(Value::as_str)
                .ok_or("Missing contextual lexeme")?;
            output.push_str(&format!("({identity:?}, {profile:?}) => Some({word:?}),\n"));
        }
    }
    output.push_str("_ => None } }\n");
    Ok(output)
}
