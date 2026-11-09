mod support;

use reference_model::{AnatomySource, Inline, SourceBlock};
use reference_verify::check_parity;

fn anatomy_part(code: &str) -> AnatomySource {
    AnatomySource {
        code: code.to_owned(),
        label: vec![Inline::Text("parte".to_owned())],
    }
}

#[test]
fn accepts_identical_structures() {
    let spanish = vec![support::fixture("valid/concepto.md")];
    assert!(check_parity(&spanish, &spanish).is_empty());
}

#[test]
fn reports_a_structure_that_differs() {
    let spanish = vec![support::fixture("valid/concepto.md")];
    let english = vec![support::fixture("parity-en/concepto.md")];
    let violations = check_parity(&spanish, &english);
    assert_eq!(violations.len(), 1);
}

#[test]
fn reports_anatomies_with_a_different_number_of_parts() {
    let mut spanish = support::fixture("valid/concepto.md");
    let mut english = spanish.clone();
    spanish.blocks.push(SourceBlock::Anatomy(vec![
        anatomy_part("Si"),
        anatomy_part("x"),
    ]));
    english.blocks.push(SourceBlock::Anatomy(vec![
        anatomy_part("If"),
        anatomy_part("x"),
        anatomy_part("Then"),
    ]));
    assert_eq!(check_parity(&[spanish.clone()], &[english]).len(), 1);
    let mut matching = spanish.clone();
    matching.blocks.pop();
    matching.blocks.push(SourceBlock::Anatomy(vec![
        anatomy_part("If"),
        anatomy_part("x"),
    ]));
    assert!(check_parity(&[spanish], &[matching]).is_empty());
}

#[test]
fn reports_sections_missing_on_either_side() {
    let spanish = vec![support::fixture("valid/concepto.md")];
    let english = vec![support::fixture("anchor/concepto.md")];
    assert_eq!(check_parity(&spanish, &english).len(), 2);
    assert!(check_parity(&[], &[]).is_empty());
}

#[test]
fn both_fixtures_share_their_anchors() {
    let corpus = support::corpus();
    let english = support::fixture("parity-en/concepto.md");
    assert!(
        english
            .header
            .anchors
            .iter()
            .all(|anchor| corpus.rule_exists(anchor))
    );
}
