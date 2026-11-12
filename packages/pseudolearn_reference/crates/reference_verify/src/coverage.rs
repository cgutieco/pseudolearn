use crate::coverage_items::{
    covered_cards, covered_diagnostics, covered_specifications, covered_words,
};
use reference_corpus::{Corpus, LexemeFamily};
use reference_model::{PublishedSection, RuleId, SourceDocument, Violation};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

pub const COVERED_PREFIXES: [&str; 5] = ["LANG.", "LIB.", "ENG.", "MEM.", "RT."];

#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CoverageExclusions {
    #[serde(default, rename = "especificaciones")]
    pub specifications: BTreeMap<String, String>,
    #[serde(default, rename = "vocabulario")]
    pub vocabulary: BTreeMap<String, String>,
    #[serde(default, rename = "fichas")]
    pub cards: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize)]
pub struct CoverageArea {
    pub name: String,
    pub total: usize,
    pub covered: usize,
    pub excluded: usize,
    pub missing: Vec<String>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize)]
pub struct CoverageReport {
    pub areas: Vec<CoverageArea>,
}

pub struct CoverageInput<'input> {
    pub documents: &'input [SourceDocument],
    pub sections: &'input [PublishedSection],
    pub corpus: &'input Corpus,
    pub exclusions: &'input CoverageExclusions,
}

pub fn measure_coverage(input: &CoverageInput<'_>) -> (CoverageReport, Vec<Violation>) {
    let areas = areas(input);
    let violations = areas
        .iter()
        .flat_map(|area| {
            area.missing.iter().map(|missing| {
                Violation::new(
                    RuleId::Coverage,
                    area.name.clone(),
                    format!("`{missing}` is not covered by any section"),
                )
            })
        })
        .collect();
    (CoverageReport { areas }, violations)
}

fn areas(input: &CoverageInput<'_>) -> Vec<CoverageArea> {
    let corpus = input.corpus;
    let words = covered_words(input.sections, corpus);
    let exclusions = input.exclusions;
    vec![
        area(
            "vocabulary",
            &family(corpus, LexemeFamily::Reserved),
            &words,
            &exclusions.vocabulary,
        ),
        area(
            "contextual",
            &family(corpus, LexemeFamily::Contextual),
            &words,
            &exclusions.vocabulary,
        ),
        area(
            "cards",
            &corpus.cards.keys().cloned().collect(),
            &covered_cards(input.documents, corpus),
            &exclusions.cards,
        ),
        area(
            "diagnostics",
            &corpus.diagnostics.keys().cloned().collect(),
            &covered_diagnostics(input.documents, input.sections),
            &BTreeMap::new(),
        ),
        area(
            "specifications",
            &specifications(corpus),
            &covered_specifications(input.documents),
            &exclusions.specifications,
        ),
    ]
}

fn family(corpus: &Corpus, wanted: LexemeFamily) -> BTreeSet<String> {
    corpus
        .lexicon
        .entries()
        .filter(|entry| entry.family == wanted)
        .map(|entry| entry.identity.clone())
        .collect()
}

fn specifications(corpus: &Corpus) -> BTreeSet<String> {
    corpus
        .specifications
        .keys()
        .filter(|identity| {
            COVERED_PREFIXES
                .iter()
                .any(|prefix| identity.starts_with(prefix))
        })
        .cloned()
        .collect()
}

fn area(
    name: &str,
    expected: &BTreeSet<String>,
    covered: &BTreeSet<String>,
    excluded: &BTreeMap<String, String>,
) -> CoverageArea {
    let missing: Vec<String> = expected
        .iter()
        .filter(|identity| !covered.contains(*identity) && !excluded.contains_key(*identity))
        .cloned()
        .collect();
    let excluded_count = expected
        .iter()
        .filter(|identity| excluded.contains_key(*identity))
        .count();
    CoverageArea {
        name: name.to_owned(),
        total: expected.len(),
        covered: expected
            .len()
            .saturating_sub(missing.len())
            .saturating_sub(excluded_count),
        excluded: excluded_count,
        missing,
    }
}
