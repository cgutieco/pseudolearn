use crate::Resolution;
use crate::blocks::resolve_blocks;
use crate::resolution::Collector;
use crate::runs::runs;
use reference_model::{Block, CalloutKind, Inline, RuleId, SectionLink, SourceBlock};

pub fn callout(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    kind: CalloutKind,
    blocks: &[SourceBlock],
) -> Option<Block> {
    match kind {
        CalloutKind::Summary => Some(Block::Summary {
            points: inline_groups(blocks)
                .iter()
                .map(|group| runs(resolution, group))
                .collect(),
        }),
        CalloutKind::SeeAlso => Some(Block::SeeAlso {
            links: links(resolution, collector, blocks),
        }),
        _ => Some(Block::Callout {
            kind,
            collapsible: kind.collapsible(),
            blocks: resolve_blocks(resolution, collector, blocks, false),
        }),
    }
}

fn inline_groups(blocks: &[SourceBlock]) -> Vec<Vec<Inline>> {
    blocks
        .iter()
        .flat_map(|block| match block {
            SourceBlock::List { entries, .. } => entries.clone(),
            SourceBlock::Paragraph(text) => vec![text.clone()],
            _ => Vec::new(),
        })
        .collect()
}

fn links(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> Vec<SectionLink> {
    let mut links = Vec::new();
    for inline in inline_groups(blocks).into_iter().flatten() {
        let Inline::Link { section, .. } = inline else {
            continue;
        };
        match resolution.index.get(&section) {
            Some(target) => links.push(SectionLink {
                section,
                number: target.number.clone(),
                title: target.title.clone(),
            }),
            None => collector.report(
                RuleId::LinkValid,
                format!("link to unknown section `{section}`"),
            ),
        }
    }
    links
}
