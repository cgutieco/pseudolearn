use see_model::Corpus;
use serde_json::Value;
use std::collections::BTreeSet;

const PROFILES: [(&str, &str); 2] = [("es", "en"), ("en", "es")];

pub fn check(corpus: &Corpus, conventions: &Value) -> Vec<String> {
    let entries = lexicon_entries(corpus);
    let mut errors = Vec::new();
    for identity in see_model::strings(conventions.get("aperturas")) {
        let Some(opener) = entries.iter().find(|(name, _)| *name == identity) else {
            errors.push(format!("SEE-PROFILE-OPENERS: unknown opener {identity}"));
            continue;
        };
        for (profile, other) in PROFILES {
            let foreign = profile_forms(&entries, other);
            errors.extend(
                forms(opener.1, profile)
                    .into_iter()
                    .filter(|form| foreign.contains(form))
                    .map(|form| format!("SEE-PROFILE-OPENERS: {identity} {profile} {form}")),
            );
        }
    }
    errors
}

fn lexicon_entries(corpus: &Corpus) -> Vec<(&str, &Value)> {
    ["vocabulary", "functions"]
        .into_iter()
        .filter_map(|term| crate::cli::resource(corpus, term))
        .filter_map(Value::as_object)
        .flatten()
        .map(|(name, entry)| (name.as_str(), entry))
        .collect()
}

fn profile_forms(entries: &[(&str, &Value)], profile: &str) -> BTreeSet<String> {
    entries
        .iter()
        .flat_map(|(_, entry)| forms(entry, profile))
        .collect()
}

fn forms(entry: &Value, profile: &str) -> BTreeSet<String> {
    let lexeme = entry
        .get("lexemas")
        .and_then(|lexemes| lexemes.get(profile))
        .and_then(Value::as_str);
    let aliases = see_model::strings(entry.get("alias").and_then(|aliases| aliases.get(profile)));
    lexeme.into_iter().chain(aliases).map(folded).collect()
}

pub fn folded(text: &str) -> String {
    text.chars()
        .flat_map(char::to_lowercase)
        .map(|character| match character {
            'á' | 'à' | 'ä' | 'â' => 'a',
            'é' | 'è' | 'ë' | 'ê' => 'e',
            'í' | 'ì' | 'ï' | 'î' => 'i',
            'ó' | 'ò' | 'ö' | 'ô' => 'o',
            'ú' | 'ù' | 'ü' | 'û' => 'u',
            'ñ' => 'n',
            other => other,
        })
        .collect()
}
