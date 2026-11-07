mod support;

use reference_verify::check_parity;

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
