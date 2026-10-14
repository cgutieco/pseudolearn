use see_model::Block;
use see_model::contract::Vocabulary;

pub fn resolve(text: &str, profile: &str, vocabulary: &Vocabulary) -> Result<String, String> {
    let mut remaining = text;
    let mut output = String::new();
    while let Some(beginning) = remaining.find("{{lexema:") {
        let (prefix, marker) = remaining.split_at(beginning);
        output.push_str(prefix);
        let tail = marker
            .strip_prefix("{{lexema:")
            .ok_or("Invalid lexeme marker")?;
        let (key, tail) = tail.split_once("}}").ok_or("Unclosed lexeme marker")?;
        let lexeme = vocabulary
            .get(key)
            .and_then(|profiles| profiles.get(profile))
            .ok_or(format!("Unknown lexeme {key} in {profile}"))?;
        output.push_str(lexeme);
        remaining = tail;
    }
    output.push_str(remaining);
    Ok(output)
}

pub fn validate(case: &Block, vocabulary: &Vocabulary) -> Vec<String> {
    see_model::strings(case.fields.get("perfiles"))
        .into_iter()
        .filter_map(|profile| {
            let expected = case
                .fields
                .get("esperas")
                .and_then(|expected| expected.get(profile))
                .or_else(|| case.fields.get("espera"));
            let output = expected
                .and_then(|expected| expected.get("salida"))
                .and_then(|output| output.as_str())?;
            resolve(output, profile, vocabulary).err()
        })
        .collect()
}
