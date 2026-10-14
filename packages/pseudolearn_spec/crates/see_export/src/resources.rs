use see_model::{Corpus, field};
use serde_json::{Value, json};

pub fn generate(corpus: &Corpus) -> Result<Value, String> {
    let mut resources = serde_json::Map::new();
    for specification in corpus {
        for definition in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "definicion")
        {
            let Some(value) = definition.fields.get("valor") else {
                continue;
            };
            let name = field(definition, "termino");
            if resources.insert(name.to_owned(), value.clone()).is_some() {
                return Err(format!("SEE-RESOURCE: duplicate resource {name}"));
            }
        }
    }
    Ok(json!(resources))
}

pub fn vocabulary(resources: &Value) -> Result<Value, String> {
    let mut vocabulary = serde_json::Map::new();
    for name in ["vocabulary", "functions"] {
        let Some(entries) = resources.get(name).and_then(Value::as_object) else {
            continue;
        };
        for (identity, entry) in entries {
            let profiles = entry
                .get("lexemas")
                .ok_or("SEE-RESOURCE: missing lexemes")?;
            let key = if name == "functions" {
                format!("function:{identity}")
            } else {
                identity.clone()
            };
            if vocabulary.insert(key.clone(), profiles.clone()).is_some() {
                return Err(format!("SEE-RESOURCE: duplicate identity {identity}"));
            }
            aliases(&key, entry, &mut vocabulary)?;
        }
    }
    Ok(json!(vocabulary))
}

fn aliases(
    key: &str,
    entry: &Value,
    vocabulary: &mut serde_json::Map<String, Value>,
) -> Result<(), String> {
    let Some(aliases) = entry.get("alias").and_then(Value::as_object) else {
        return Ok(());
    };
    for (profile, alternatives) in aliases {
        let alternatives = alternatives
            .as_array()
            .ok_or("SEE-RESOURCE: invalid aliases")?;
        for (offset, word) in alternatives.iter().enumerate() {
            let mut profiles = entry
                .get("lexemas")
                .and_then(Value::as_object)
                .ok_or("SEE-RESOURCE: missing lexemes")?
                .clone();
            profiles.insert(profile.clone(), word.clone());
            vocabulary.insert(format!("{key}.alias.{profile}.{offset}"), json!(profiles));
        }
    }
    Ok(())
}
