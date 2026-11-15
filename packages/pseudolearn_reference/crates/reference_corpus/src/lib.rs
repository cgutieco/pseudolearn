#![forbid(unsafe_code)]

mod catalogs;
mod lexicon;
mod lexicon_loading;
mod specifications;

pub use catalogs::{CardEntry, DiagnosticEntry, FunctionEntry};
pub use lexicon::{LexemeFamily, Lexicon, LexiconEntry, fold};
pub use specifications::{SpecificationEntry, anchor_parts};

use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default)]
pub struct Corpus {
    pub lexicon: Lexicon,
    pub specifications: BTreeMap<String, SpecificationEntry>,
    pub diagnostics: BTreeMap<String, DiagnosticEntry>,
    pub cards: BTreeMap<String, CardEntry>,
    pub functions: Vec<FunctionEntry>,
    pub productions: BTreeMap<String, String>,
    pub digest: String,
}

impl Corpus {
    pub fn from_export(text: &str) -> Result<Self, String> {
        let root: Value =
            serde_json::from_str(text).map_err(|error| format!("invalid export: {error}"))?;
        let resources = root
            .get("resources")
            .ok_or_else(|| "the export has no resources".to_owned())?;
        Ok(Self {
            lexicon: lexicon_loading::load(resources),
            specifications: specifications::load(&root),
            diagnostics: catalogs::diagnostics(resources),
            cards: catalogs::cards(resources),
            functions: catalogs::functions(resources),
            productions: catalogs::productions(resources),
            digest: specifications::digest(text),
        })
    }

    pub fn rule_exists(&self, anchor: &str) -> bool {
        let (specification, rule) = anchor_parts(anchor);
        self.specifications
            .get(specification)
            .is_some_and(|entry| rule.is_none_or(|rule| entry.rules.contains_key(rule)))
    }

    pub fn anchor_digest(&self, anchor: &str) -> Option<String> {
        let (specification, rule) = anchor_parts(anchor);
        let entry = self.specifications.get(specification)?;
        match rule {
            Some(rule) => entry.rules.get(rule).cloned(),
            None => Some(entry.hash.clone()),
        }
    }
}
