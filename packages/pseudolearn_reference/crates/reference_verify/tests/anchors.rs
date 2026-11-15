mod support;

use reference_model::RuleId;
use reference_verify::{build_lock, check_anchors, check_lock};

#[test]
fn accepts_existing_anchors_cards_and_codes() {
    assert!(check_anchors(&[support::fixture("valid/concepto.md")], &support::corpus()).is_empty());
}

#[test]
fn rejects_unknown_anchors_cards_and_codes() {
    let violations = check_anchors(
        &[support::fixture("anchor/concepto.md")],
        &support::corpus(),
    );
    assert_eq!(violations.len(), 3);
    assert!(
        violations
            .iter()
            .all(|violation| violation.rule == RuleId::AnchorValid)
    );
}

#[test]
fn rejects_a_narrative_section_without_anchors() {
    let mut document = support::fixture("valid/concepto.md");
    document.header.anchors.clear();
    assert_eq!(check_anchors(&[document], &support::corpus()).len(), 1);
}

#[test]
fn a_fresh_lock_is_clean() {
    let documents = [support::fixture("valid/concepto.md")];
    let corpus = support::corpus();
    let lock = build_lock(&documents, &corpus);
    assert!(check_lock(&documents, &corpus, &lock).is_empty());
}

#[test]
fn an_altered_digest_is_stale() {
    let documents = [support::fixture("valid/concepto.md")];
    let corpus = support::corpus();
    let mut lock = build_lock(&documents, &corpus);
    for anchors in lock.values_mut() {
        for digest in anchors.values_mut() {
            digest.push('x');
        }
    }
    let violations = check_lock(&documents, &corpus, &lock);
    assert_eq!(
        violations.first().map(|violation| violation.rule),
        Some(RuleId::AnchorStale)
    );
}

#[test]
fn a_lock_with_removed_anchors_is_stale() {
    let documents = [support::fixture("valid/concepto.md")];
    let corpus = support::corpus();
    let mut lock = build_lock(&documents, &corpus);
    if let Some(anchors) = lock.values_mut().next() {
        anchors.insert("LANG.CONTROL.IF".to_owned(), "abc".to_owned());
    }
    assert_eq!(check_lock(&documents, &corpus, &lock).len(), 1);
}
