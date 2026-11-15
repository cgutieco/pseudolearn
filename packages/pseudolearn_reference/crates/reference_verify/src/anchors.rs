use reference_corpus::Corpus;
use reference_model::{RuleId, SectionKind, SourceDocument, Violation};
use std::collections::BTreeMap;

pub type AnchorLock = BTreeMap<String, BTreeMap<String, String>>;

pub fn check_anchors(documents: &[SourceDocument], corpus: &Corpus) -> Vec<Violation> {
    documents
        .iter()
        .flat_map(|document| anchor_problems(document, corpus))
        .map(|(location, detail)| Violation::new(RuleId::AnchorValid, location, detail))
        .collect()
}

fn anchor_problems(document: &SourceDocument, corpus: &Corpus) -> Vec<(String, String)> {
    let header = &document.header;
    let mut problems = Vec::new();
    if header.anchors.is_empty() && header.kind != SectionKind::Appendix {
        problems.push("a section needs at least one anchor".to_owned());
    }
    let unknown_anchors = header
        .anchors
        .iter()
        .filter(|anchor| !corpus.rule_exists(anchor));
    problems.extend(unknown_anchors.map(|anchor| format!("unknown anchor `{anchor}`")));
    let unknown_cards = header
        .cards
        .iter()
        .filter(|card| !corpus.cards.contains_key(*card));
    problems.extend(unknown_cards.map(|card| format!("unknown help card `{card}`")));
    let unknown_codes = header
        .diagnostics
        .iter()
        .filter(|code| !corpus.diagnostics.contains_key(*code));
    problems.extend(unknown_codes.map(|code| format!("unknown diagnostic `{code}`")));
    problems
        .into_iter()
        .map(|detail| (document.path.clone(), detail))
        .collect()
}

pub fn build_lock(documents: &[SourceDocument], corpus: &Corpus) -> AnchorLock {
    documents
        .iter()
        .map(|document| {
            let anchors = document
                .header
                .anchors
                .iter()
                .filter_map(|anchor| Some((anchor.clone(), corpus.anchor_digest(anchor)?)))
                .collect();
            (document.header.id.clone(), anchors)
        })
        .collect()
}

pub fn check_lock(
    documents: &[SourceDocument],
    corpus: &Corpus,
    lock: &AnchorLock,
) -> Vec<Violation> {
    let current = build_lock(documents, corpus);
    let mut violations = Vec::new();
    for (section, anchors) in &current {
        let locked = lock.get(section);
        for (anchor, digest) in anchors {
            if locked.and_then(|entries| entries.get(anchor)) != Some(digest) {
                violations.push(Violation::new(
                    RuleId::AnchorStale,
                    section.clone(),
                    format!("`{anchor}` changed or is not locked: review the section and run `reference lock`"),
                ));
            }
        }
    }
    for (section, anchors) in lock {
        let present = current.get(section);
        if anchors
            .keys()
            .any(|anchor| present.is_none_or(|entries| !entries.contains_key(anchor)))
        {
            violations.push(Violation::new(
                RuleId::AnchorStale,
                section.clone(),
                "the lock lists anchors the section no longer has",
            ));
        }
    }
    violations
}
