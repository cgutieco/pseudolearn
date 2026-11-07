use reference_corpus::{Corpus, anchor_parts};
use reference_model::{Block, Profile, PublishedSection, Run, SectionKind, SourceDocument};
use std::collections::BTreeSet;

fn narrative(documents: &[SourceDocument]) -> impl Iterator<Item = &SourceDocument> {
    documents
        .iter()
        .filter(|document| document.header.kind != SectionKind::Appendix)
}

pub fn covered_specifications(documents: &[SourceDocument]) -> BTreeSet<String> {
    narrative(documents)
        .flat_map(|document| document.header.anchors.iter())
        .map(|anchor| anchor_parts(anchor).0.to_owned())
        .collect()
}

pub fn covered_cards(documents: &[SourceDocument], corpus: &Corpus) -> BTreeSet<String> {
    let anchored = covered_specifications(documents);
    let mut covered: BTreeSet<String> = narrative(documents)
        .flat_map(|document| document.header.cards.iter().cloned())
        .collect();
    for card in corpus.cards.values() {
        if card.anchors.iter().any(|anchor| anchored.contains(anchor)) {
            covered.insert(card.id.clone());
        }
    }
    covered
}

pub fn covered_diagnostics(
    documents: &[SourceDocument],
    sections: &[PublishedSection],
) -> BTreeSet<String> {
    let mut covered: BTreeSet<String> = documents
        .iter()
        .flat_map(|document| document.header.diagnostics.iter().cloned())
        .collect();
    for section in sections {
        let mut codes = Vec::new();
        for block in &section.blocks {
            diagnostic_codes(block, &mut codes);
        }
        covered.extend(codes);
    }
    covered
}

fn diagnostic_codes(block: &Block, codes: &mut Vec<String>) {
    match block {
        Block::Program(program) => codes.extend(
            program
                .diagnostics
                .iter()
                .map(|diagnostic| diagnostic.code.clone()),
        ),
        Block::Diagnostic(diagnostic) => codes.push(diagnostic.code.clone()),
        Block::Table(table) => {
            for run in table.rows.iter().flatten().flatten() {
                if let Run::Code { tokens } = run {
                    codes.extend(tokens.iter().map(|token| token.text.clone()));
                }
            }
        }
        Block::Callout { blocks, .. } => {
            for inner in blocks {
                diagnostic_codes(inner, codes);
            }
        }
        _ => {}
    }
}

pub fn covered_words(sections: &[PublishedSection], corpus: &Corpus) -> BTreeSet<String> {
    let mut texts = Vec::new();
    for section in sections
        .iter()
        .filter(|section| section.kind != SectionKind::Appendix)
    {
        for block in &section.blocks {
            code_texts(block, &mut texts);
        }
    }
    texts
        .iter()
        .filter_map(|text| corpus.lexicon.identity_of(Profile::Spanish, text))
        .map(|entry| entry.identity.clone())
        .collect()
}

fn code_texts(block: &Block, texts: &mut Vec<String>) {
    let token_texts = |tokens: &[reference_model::Token]| -> Vec<String> {
        tokens
            .iter()
            .filter(|token| token.category.is_some())
            .map(|token| token.text.trim().to_owned())
            .collect()
    };
    match block {
        Block::Program(program) => {
            texts.extend(program.lines.iter().flat_map(|line| token_texts(line)))
        }
        Block::Form { lines } => {
            for segment in lines.iter().flatten() {
                if let reference_model::FormSegment::Token { token } = segment {
                    texts.extend(token_texts(std::slice::from_ref(token)));
                }
            }
        }
        Block::Callout { blocks, .. } => {
            for inner in blocks {
                code_texts(inner, texts);
            }
        }
        other => texts.extend(
            inline_code(other)
                .into_iter()
                .flat_map(|tokens| token_texts(&tokens)),
        ),
    }
}

fn inline_code(block: &Block) -> Vec<Vec<reference_model::Token>> {
    let groups: Vec<&Vec<Run>> = match block {
        Block::Paragraph { runs } | Block::Heading { runs, .. } => vec![runs],
        Block::List { entries, .. } => entries.iter().collect(),
        Block::Summary { points } => points.iter().collect(),
        Block::Table(table) => table.rows.iter().flatten().collect(),
        _ => Vec::new(),
    };
    groups
        .into_iter()
        .flatten()
        .filter_map(|run| match run {
            Run::Code { tokens } => Some(tokens.clone()),
            _ => None,
        })
        .collect()
}
