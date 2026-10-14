use serde_json::Value;
use std::collections::BTreeMap;

pub fn check(value: &Value) -> Result<(), String> {
    let entries = value.as_object().ok_or("Invalid lexicon")?;
    if entries.is_empty() {
        return Err("Empty lexicon".to_owned());
    }
    for profile in ["es", "en"] {
        let mut identities = BTreeMap::new();
        for (identity, entry) in entries {
            lexemes(entry, profile, identity, &mut identities)?;
            signature(entry)?;
        }
    }
    Ok(())
}

fn lexemes<'entry>(
    entry: &'entry Value,
    profile: &str,
    identity: &'entry str,
    identities: &mut BTreeMap<String, &'entry str>,
) -> Result<(), String> {
    let canonical = entry
        .get("lexemas")
        .and_then(|values| values.get(profile))
        .and_then(Value::as_str)
        .ok_or("Missing canonical lexeme")?;
    let aliases = entry.get("alias").and_then(|values| values.get(profile));
    let words = std::iter::once(canonical).chain(see_model::strings(aliases));
    for word in words {
        if word.trim().is_empty() || word.contains(['\n', '\r']) {
            return Err("Empty or multiline lexeme".to_owned());
        }
        let normalized = normalize(word, profile);
        if identities
            .insert(normalized, identity)
            .is_some_and(|previous| previous != identity)
        {
            return Err("Colliding lexemes".to_owned());
        }
    }
    Ok(())
}

fn normalize(word: &str, profile: &str) -> String {
    let folded = word.to_lowercase();
    if profile == "en" {
        return folded;
    }
    folded
        .replace('á', "a")
        .replace('é', "e")
        .replace('í', "i")
        .replace('ó', "o")
        .replace(['ú', 'ü'], "u")
}

fn signature(entry: &Value) -> Result<(), String> {
    let Some(parameters) = entry.get("parametros") else {
        return Ok(());
    };
    let parameters = parameters.as_array().ok_or("Invalid parameter list")?;
    let allowed = [
        "numeric",
        "real",
        "integer",
        "string",
        "character",
        "anyPrimitive",
        "anyClass",
    ];
    if parameters.iter().any(|parameter| {
        parameter
            .as_str()
            .is_none_or(|kind| !allowed.contains(&kind))
    }) {
        return Err("Unknown parameter kind".to_owned());
    }
    let result = entry
        .get("retorno")
        .and_then(Value::as_str)
        .ok_or("Missing return kind")?;
    if ![
        "real",
        "integer",
        "string",
        "character",
        "sameAsFirstArgument",
    ]
    .contains(&result)
    {
        return Err("Unknown return kind".to_owned());
    }
    Ok(())
}
