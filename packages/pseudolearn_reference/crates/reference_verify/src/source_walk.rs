use reference_model::{Inline, SourceBlock};

pub fn inline_groups(blocks: &[SourceBlock]) -> Vec<&[Inline]> {
    let mut groups = Vec::new();
    for block in blocks {
        collect(block, &mut groups);
    }
    groups
}

fn collect<'block>(block: &'block SourceBlock, groups: &mut Vec<&'block [Inline]>) {
    match block {
        SourceBlock::Heading { text, .. } | SourceBlock::Paragraph(text) => groups.push(text),
        SourceBlock::List { entries, .. } => groups.extend(entries.iter().map(Vec::as_slice)),
        SourceBlock::Table { header, rows } => {
            groups.extend(header.iter().map(Vec::as_slice));
            groups.extend(rows.iter().flatten().map(Vec::as_slice));
        }
        SourceBlock::Figure(figure) => {
            groups.push(&figure.caption);
            groups.extend(figure.steps.iter().map(|step| step.text.as_slice()));
            groups.extend(figure.panels.iter().map(|panel| panel.text.as_slice()));
        }
        SourceBlock::Callout { blocks, .. } => {
            for inner in blocks {
                collect(inner, groups);
            }
        }
        _ => {}
    }
}

pub fn all_blocks(blocks: &[SourceBlock]) -> Vec<&SourceBlock> {
    let mut flattened = Vec::new();
    for block in blocks {
        flattened.push(block);
        if let SourceBlock::Callout { blocks: inner, .. } = block {
            flattened.extend(all_blocks(inner));
        }
    }
    flattened
}
