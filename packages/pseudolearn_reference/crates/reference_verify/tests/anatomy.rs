mod support;

use reference_verify::check_anatomy;

#[test]
fn accepts_a_complete_concept() {
    assert!(check_anatomy(&support::fixture("valid/concepto.md")).is_empty());
}

#[test]
fn reports_every_missing_block_of_a_construction() {
    let violations = check_anatomy(&support::fixture("anatomy/construccion.md"));
    let details: Vec<String> = violations
        .iter()
        .map(|violation| violation.detail.clone())
        .collect();
    assert!(details.contains(&"missing the written form".to_owned()));
    assert!(details.contains(&"missing enough executed programs".to_owned()));
    assert_eq!(violations.len(), 9);
}

#[test]
fn ignores_appendices() {
    assert!(check_anatomy(&support::fixture("inline-code/concepto.md")).is_empty());
}

#[test]
fn the_fixture_anchors_an_existing_rule() {
    let document = support::fixture("anatomy/construccion.md");
    let corpus = support::corpus();
    assert!(
        document
            .header
            .anchors
            .iter()
            .all(|anchor| corpus.rule_exists(anchor))
    );
}
