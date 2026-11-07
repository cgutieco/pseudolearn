use reference_model::TokenCategory;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default)]
pub struct CategoryTable {
    categories: BTreeMap<String, TokenCategory>,
}

impl CategoryTable {
    pub fn from_json(text: &str) -> Result<Self, String> {
        let categories: BTreeMap<String, TokenCategory> = serde_json::from_str(text)
            .map_err(|error| format!("invalid category table: {error}"))?;
        Ok(Self { categories })
    }

    pub fn category(&self, identity: &str) -> Option<TokenCategory> {
        self.categories.get(identity).copied()
    }

    pub fn identities(&self) -> impl Iterator<Item = &String> {
        self.categories.keys()
    }
}
