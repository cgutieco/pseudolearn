use crate::workspace::Workspace;
use reference_corpus::anchor_parts;
use reference_model::{Profile, SectionKind, SourceDocument};
use std::collections::BTreeMap;

pub fn link_maps(workspace: &Workspace) -> BTreeMap<String, BTreeMap<String, String>> {
    let empty = Vec::new();
    let documents = workspace
        .languages
        .get(&Profile::Spanish)
        .map_or(&empty, |language| &language.documents);
    BTreeMap::from([
        ("cards".to_owned(), card_links(workspace, documents)),
        (
            "diagnostics".to_owned(),
            diagnostic_links(workspace, documents),
        ),
    ])
}

fn card_links(workspace: &Workspace, documents: &[SourceDocument]) -> BTreeMap<String, String> {
    let narrative: Vec<&SourceDocument> = documents
        .iter()
        .filter(|document| document.header.kind != SectionKind::Appendix)
        .collect();
    let mut cards = BTreeMap::new();
    for card in workspace.corpus.cards.values() {
        let explicit = narrative
            .iter()
            .find(|document| document.header.cards.contains(&card.id));
        let anchored = narrative.iter().find(|document| {
            document.header.anchors.iter().any(|anchor| {
                card.anchors
                    .iter()
                    .any(|wanted| anchor_parts(anchor).0 == wanted)
            })
        });
        if let Some(document) = explicit.or(anchored) {
            cards.insert(card.id.clone(), document.header.id.clone());
        }
    }
    cards
}

fn diagnostic_links(
    workspace: &Workspace,
    documents: &[SourceDocument],
) -> BTreeMap<String, String> {
    let catalog = documents
        .iter()
        .find(|document| document.header.id == "apendice.diagnosticos");
    workspace
        .corpus
        .diagnostics
        .keys()
        .filter_map(|code| {
            let listed = documents
                .iter()
                .find(|document| document.header.diagnostics.contains(code));
            listed
                .or(catalog)
                .map(|document| (code.clone(), document.header.id.clone()))
        })
        .collect()
}
