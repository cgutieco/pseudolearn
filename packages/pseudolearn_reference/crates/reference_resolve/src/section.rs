use crate::blocks::resolve_blocks;
use crate::resolution::{Collector, ResolvedSection};
use crate::runs::runs;
use crate::{Resolution, SpanishReuse};
use reference_model::{Block, CalloutKind, PublishedSection, SourceDocument};

pub fn resolve_section(
    resolution: &Resolution<'_>,
    document: &SourceDocument,
    reuse: &SpanishReuse,
) -> ResolvedSection {
    let mut collector = Collector {
        location: document.path.clone(),
        section_number: document.header.number.clone(),
        reuse,
        violations: Vec::new(),
        examples: Vec::new(),
        figures: 0,
        headings: 0,
        forms: 0,
        programs: std::collections::BTreeMap::new(),
    };
    let blocks = resolve_blocks(resolution, &mut collector, &document.blocks, true);
    let phrase = phrase(&blocks);
    ResolvedSection {
        section: PublishedSection {
            id: document.header.id.clone(),
            number: document.header.number.clone(),
            kind: document.header.kind,
            title: runs(resolution, &document.title),
            phrase,
            blocks,
        },
        examples: collector.examples,
        violations: collector.violations,
    }
}

fn phrase(blocks: &[Block]) -> Vec<reference_model::Run> {
    blocks
        .iter()
        .find_map(|block| match block {
            Block::Callout {
                kind: CalloutKind::Phrase,
                blocks,
                ..
            } => blocks.iter().find_map(|inner| match inner {
                Block::Paragraph { runs } => Some(runs.clone()),
                _ => None,
            }),
            _ => None,
        })
        .unwrap_or_default()
}
