use reference_model::Profile;
use serde::Deserialize;

#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
struct SpellingAlias {
    #[serde(rename = "es")]
    spanish: String,
    #[serde(rename = "en")]
    english: String,
}

impl SpellingAlias {
    fn spelled_in(&self, profile: Profile) -> &str {
        match profile {
            Profile::Spanish => &self.spanish,
            Profile::English => &self.english,
        }
    }
}

#[derive(Clone, Debug, Default)]
pub struct AliasTable {
    aliases: Vec<SpellingAlias>,
}

impl AliasTable {
    pub fn from_json(text: &str) -> Result<Self, String> {
        let aliases: Vec<SpellingAlias> =
            serde_json::from_str(text).map_err(|error| format!("invalid alias table: {error}"))?;
        Ok(Self { aliases })
    }

    pub fn translate(&self, text: &str, source: Profile, target: Profile) -> Option<&str> {
        self.aliases
            .iter()
            .find(|alias| alias.spelled_in(source) == text)
            .map(|alias| alias.spelled_in(target))
    }

    pub fn contains(&self, text: &str, profile: Profile) -> bool {
        self.aliases
            .iter()
            .any(|alias| alias.spelled_in(profile) == text)
    }
}
