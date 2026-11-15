mod support;

use reference_model::{Block, FormSegment, PublishedSection, SectionKind, Token, TokenCategory};
use reference_verify::{CoverageExclusions, CoverageInput, measure_coverage};

fn section_with(word: &str) -> PublishedSection {
    PublishedSection {
        id: "prueba.valida".to_owned(),
        number: "1.1".to_owned(),
        kind: SectionKind::Concept,
        title: Vec::new(),
        phrase: Vec::new(),
        blocks: vec![Block::Form {
            lines: vec![vec![FormSegment::Token {
                token: Token {
                    text: word.to_owned(),
                    category: Some(TokenCategory::KeywordStructured),
                },
            }]],
        }],
    }
}

#[test]
fn reports_what_is_missing() {
    let corpus = support::corpus();
    let documents = [support::fixture("valid/concepto.md")];
    let sections = [section_with("Si")];
    let exclusions = CoverageExclusions::default();
    let (report, violations) = measure_coverage(&CoverageInput {
        documents: &documents,
        sections: &sections,
        corpus: &corpus,
        exclusions: &exclusions,
    });
    let vocabulary = report.areas.iter().find(|area| area.name == "vocabulary");
    assert_eq!(vocabulary.map(|area| area.covered), Some(1));
    let missing: Vec<&String> = violations
        .iter()
        .map(|violation| &violation.detail)
        .collect();
    assert_eq!(violations.len(), 4, "{missing:?}");
}

#[test]
fn honours_exclusions() {
    let corpus = support::corpus();
    let documents = [support::fixture("valid/concepto.md")];
    let sections = [section_with("Si")];
    let mut exclusions = CoverageExclusions::default();
    exclusions
        .specifications
        .insert("LIB.CORE.TEXT".to_owned(), "motivo".to_owned());
    let (_, violations) = measure_coverage(&CoverageInput {
        documents: &documents,
        sections: &sections,
        corpus: &corpus,
        exclusions: &exclusions,
    });
    assert_eq!(violations.len(), 3);
}
