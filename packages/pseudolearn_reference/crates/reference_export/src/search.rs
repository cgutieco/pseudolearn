use crate::bundle::SectionMeta;
use reference_model::{Block, PublishedSection, Run};
use serde::Serialize;

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd, Serialize)]
pub struct SearchEntry {
    pub text: String,
    pub kind: &'static str,
    pub section: String,
    #[serde(skip_serializing_if = "String::is_empty")]
    pub anchor: String,
}

pub fn entries(sections: &[PublishedSection], metas: &[SectionMeta]) -> Vec<SearchEntry> {
    let mut entries = Vec::new();
    for section in sections {
        entries.push(entry(plain(&section.title), "title", &section.id, ""));
        for block in &section.blocks {
            if let Block::Heading { id, runs, .. } = block {
                entries.push(entry(plain(runs), "heading", &section.id, id));
            }
        }
    }
    for meta in metas {
        for term in &meta.terms {
            entries.push(entry(term.clone(), "term", &meta.id, ""));
        }
        for title in &meta.card_titles {
            entries.push(entry(title.clone(), "card", &meta.id, ""));
        }
        for code in &meta.diagnostics {
            entries.push(entry(code.clone(), "diagnostic", &meta.id, ""));
        }
    }
    entries.sort();
    entries.dedup();
    entries
}

fn entry(text: String, kind: &'static str, section: &str, anchor: &str) -> SearchEntry {
    SearchEntry {
        text,
        kind,
        section: section.to_owned(),
        anchor: anchor.to_owned(),
    }
}

pub fn plain(runs: &[Run]) -> String {
    runs.iter().map(Run::plain_text).collect()
}
