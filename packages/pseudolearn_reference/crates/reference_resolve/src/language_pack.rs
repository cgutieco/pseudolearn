use serde::Deserialize;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Deserialize)]
pub struct LanguagePack {
    #[serde(default)]
    pub figures: BTreeMap<String, BTreeMap<String, String>>,
    #[serde(default)]
    pub productions: BTreeMap<String, String>,
    #[serde(default)]
    pub interface: BTreeMap<String, String>,
}

impl LanguagePack {
    pub fn from_json(text: &str) -> Result<Self, String> {
        serde_json::from_str(text).map_err(|error| format!("invalid language strings: {error}"))
    }

    pub fn phrase(&self, key: &str) -> String {
        self.interface
            .get(key)
            .cloned()
            .unwrap_or_else(|| key.to_owned())
    }
}
