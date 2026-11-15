use crate::manifest::{Manifest, digest};
use crate::parts::{PartDefinition, section_prefix};
use crate::search::entries;
use reference_model::{PublishedSection, Run, SectionKind};
use serde::Serialize;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct SectionMeta {
    pub id: String,
    pub terms: Vec<String>,
    pub card_titles: Vec<String>,
    pub diagnostics: Vec<String>,
}

pub struct BundleInput<'input> {
    pub language: &'input str,
    pub profile: &'input str,
    pub corpus: &'input str,
    pub engine: &'input str,
    pub parts: &'input [PartDefinition],
    pub sections: &'input [PublishedSection],
    pub metas: &'input [SectionMeta],
    pub links: &'input BTreeMap<String, BTreeMap<String, String>>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct Bundle {
    pub files: BTreeMap<String, String>,
}

#[derive(Serialize)]
struct TocSection<'toc> {
    id: &'toc str,
    number: &'toc str,
    kind: SectionKind,
    title: &'toc [Run],
    phrase: &'toc [Run],
}

#[derive(Serialize)]
struct TocPart<'toc> {
    id: &'toc str,
    number: &'toc str,
    title: &'toc str,
    summary: &'toc str,
    sections: Vec<TocSection<'toc>>,
}

pub fn build_bundle(input: &BundleInput<'_>) -> Result<Bundle, String> {
    let mut files = BTreeMap::new();
    for section in input.sections {
        files.insert(format!("sections/{}.json", section.id), json(section)?);
    }
    files.insert("toc.json".to_owned(), json(&toc(input))?);
    files.insert(
        "search.json".to_owned(),
        json(&entries(input.sections, input.metas))?,
    );
    files.insert("links.json".to_owned(), json(input.links)?);
    let manifest = Manifest {
        format: crate::FORMAT,
        language: input.language,
        profile: input.profile,
        corpus: input.corpus,
        engine: input.engine,
        files: files
            .iter()
            .map(|(path, text)| (path.clone(), digest(text)))
            .collect(),
    };
    files.insert("manifest.json".to_owned(), json(&manifest)?);
    Ok(Bundle { files })
}

fn toc<'toc>(input: &'toc BundleInput<'toc>) -> Vec<TocPart<'toc>> {
    input
        .parts
        .iter()
        .map(|part| TocPart {
            id: &part.id,
            number: &part.number,
            title: &part.title,
            summary: &part.summary,
            sections: input
                .sections
                .iter()
                .filter(|section| section_prefix(&section.number) == part.prefix)
                .map(|section| TocSection {
                    id: &section.id,
                    number: &section.number,
                    kind: section.kind,
                    title: &section.title,
                    phrase: &section.phrase,
                })
                .collect(),
        })
        .collect()
}

fn json(value: &impl Serialize) -> Result<String, String> {
    serde_json::to_string(value)
        .map(|text| format!("{text}\n"))
        .map_err(|error| error.to_string())
}
