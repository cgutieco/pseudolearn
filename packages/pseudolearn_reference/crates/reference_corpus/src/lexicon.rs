use reference_model::Profile;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum LexemeFamily {
    Reserved,
    Contextual,
    Function,
    Operation,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LexiconEntry {
    pub identity: String,
    pub family: LexemeFamily,
    pub spanish: String,
    pub english: String,
    pub spanish_aliases: Vec<String>,
    pub english_aliases: Vec<String>,
}

impl LexiconEntry {
    pub fn lexeme(&self, profile: Profile) -> &str {
        match profile {
            Profile::Spanish => &self.spanish,
            Profile::English => &self.english,
        }
    }

    pub fn aliases(&self, profile: Profile) -> &[String] {
        match profile {
            Profile::Spanish => &self.spanish_aliases,
            Profile::English => &self.english_aliases,
        }
    }
}

#[derive(Clone, Debug, Default)]
pub struct Lexicon {
    entries: BTreeMap<String, LexiconEntry>,
    identities: BTreeMap<(Profile, String), String>,
}

impl Lexicon {
    pub fn insert(&mut self, entry: LexiconEntry) {
        for profile in Profile::all() {
            let forms = std::iter::once(entry.lexeme(profile))
                .chain(entry.aliases(profile).iter().map(String::as_str));
            for form in forms {
                self.identities
                    .entry((profile, fold(form)))
                    .or_insert_with(|| entry.identity.clone());
            }
        }
        self.entries.entry(entry.identity.clone()).or_insert(entry);
    }

    pub fn entry(&self, identity: &str) -> Option<&LexiconEntry> {
        self.entries.get(identity)
    }

    pub fn identity_of(&self, profile: Profile, lexeme: &str) -> Option<&LexiconEntry> {
        let identity = self.identities.get(&(profile, fold(lexeme)))?;
        self.entries.get(identity)
    }

    pub fn lexeme(&self, identity: &str, profile: Profile) -> Option<&str> {
        self.entries
            .get(identity)
            .map(|entry| entry.lexeme(profile))
    }

    pub fn entries(&self) -> impl Iterator<Item = &LexiconEntry> {
        self.entries.values()
    }
}

pub fn fold(word: &str) -> String {
    word.chars()
        .flat_map(char::to_lowercase)
        .map(|character| match character {
            'á' | 'à' | 'ä' | 'â' => 'a',
            'é' | 'è' | 'ë' | 'ê' => 'e',
            'í' | 'ì' | 'ï' | 'î' => 'i',
            'ó' | 'ò' | 'ö' | 'ô' => 'o',
            'ú' | 'ù' | 'ü' | 'û' => 'u',
            other => other,
        })
        .collect()
}
