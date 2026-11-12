use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};

pub struct CardExpectation {
    pub card_id: String,
    pub titles: BTreeMap<String, String>,
}

pub struct Oracle {
    words: BTreeMap<(String, String), String>,
    compounds: BTreeMap<String, BTreeSet<Vec<String>>>,
    cards_by_identity: BTreeMap<String, Vec<CardExpectation>>,
    functions: BTreeSet<String>,
}

fn object<'value>(
    value: &'value Value,
    key: &str,
) -> Result<&'value serde_json::Map<String, Value>, String> {
    value
        .get(key)
        .and_then(Value::as_object)
        .ok_or_else(|| format!("Missing object {key}"))
}

impl Oracle {
    pub fn load() -> Result<Self, String> {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../../pseudolearn_spec/specifications/export.json");
        let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
        let export: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
        let resources = export.get("resources").ok_or("Missing resources")?;
        let mut oracle = Self {
            words: BTreeMap::new(),
            compounds: BTreeMap::new(),
            cards_by_identity: BTreeMap::new(),
            functions: BTreeSet::new(),
        };
        for section in ["vocabulary", "functions"] {
            for (identity, entry) in object(resources, section)? {
                oracle.register_lexemes(identity, entry);
            }
        }
        oracle.functions = object(resources, "functions")?.keys().cloned().collect();
        oracle.register_cards(resources.get("helpCatalog").ok_or("Missing catalog")?)?;
        Ok(oracle)
    }

    fn register_lexemes(&mut self, identity: &str, entry: &Value) {
        for profile in ["es", "en"] {
            let canonical = entry
                .pointer(&format!("/lexemas/{profile}"))
                .and_then(Value::as_str);
            let aliases = entry
                .pointer(&format!("/alias/{profile}"))
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
                .filter_map(Value::as_str);
            for lexeme in canonical.into_iter().chain(aliases) {
                self.register_lexeme(profile, lexeme, identity);
            }
        }
    }

    fn register_lexeme(&mut self, profile: &str, lexeme: &str, identity: &str) {
        let parts: Vec<String> = lexeme.split_whitespace().map(str::to_owned).collect();
        if parts.len() > 1 {
            self.compounds
                .entry(profile.to_owned())
                .or_default()
                .insert(parts);
        } else if lexeme
            .chars()
            .all(|glyph| glyph.is_alphanumeric() || glyph == '_')
        {
            self.words
                .insert((profile.to_owned(), lexeme.to_owned()), identity.to_owned());
        }
    }

    fn register_cards(&mut self, catalog: &Value) -> Result<(), String> {
        let cards = catalog
            .get("cards")
            .and_then(Value::as_array)
            .ok_or("Missing cards")?;
        for card in cards {
            let card_id = card.get("id").and_then(Value::as_str).ok_or("Missing id")?;
            let mut titles = BTreeMap::new();
            for language in ["es", "en"] {
                let title = card
                    .pointer(&format!("/content/{language}/title"))
                    .and_then(Value::as_str)
                    .ok_or("Missing title")?;
                titles.insert(language.to_owned(), title.to_owned());
            }
            for token in card
                .get("tokens")
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
            {
                let identity = token
                    .get("identity")
                    .and_then(Value::as_str)
                    .ok_or("Missing token")?;
                self.cards_by_identity
                    .entry(identity.to_owned())
                    .or_default()
                    .push(CardExpectation {
                        card_id: card_id.to_owned(),
                        titles: titles.clone(),
                    });
            }
        }
        Ok(())
    }

    pub fn identity_of(&self, profile: &str, word: &str) -> Option<&str> {
        self.words
            .get(&(profile.to_owned(), word.to_owned()))
            .map(String::as_str)
    }

    pub fn compound_lengths(&self, profile: &str) -> Vec<&Vec<String>> {
        self.compounds
            .get(profile)
            .map(|entries| entries.iter().collect())
            .unwrap_or_default()
    }

    pub fn is_function(&self, identity: &str) -> bool {
        self.functions.contains(identity)
    }

    pub fn cards_for(&self, identity: &str) -> &[CardExpectation] {
        self.cards_by_identity
            .get(identity)
            .map_or(&[], Vec::as_slice)
    }
}
