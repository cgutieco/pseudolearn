use reference_model::{Inline, SourceBlock};

pub fn list_entries(blocks: &[SourceBlock]) -> Vec<&[Inline]> {
    blocks
        .iter()
        .flat_map(|block| match block {
            SourceBlock::List { entries, .. } => entries.iter().map(Vec::as_slice).collect(),
            SourceBlock::Paragraph(text) => vec![text.as_slice()],
            _ => Vec::new(),
        })
        .collect()
}

pub fn zone(entry: &[Inline]) -> Option<(String, Vec<Inline>)> {
    let (Inline::Text(first), rest) = entry.split_first()? else {
        return None;
    };
    let (label, after) = first.split_once(':')?;
    let label = label.trim();
    if label.is_empty() || label.contains(' ') {
        return None;
    }
    let mut text = Vec::new();
    let after = after.trim_start();
    if !after.is_empty() {
        text.push(Inline::Text(after.to_owned()));
    }
    text.extend(rest.iter().cloned());
    Some((label.to_owned(), text))
}

pub fn plain(entry: &[Inline]) -> String {
    entry
        .iter()
        .map(|inline| match inline {
            Inline::Text(text)
            | Inline::Strong(text)
            | Inline::Emphasis(text)
            | Inline::Code(text)
            | Inline::Slot(text) => text.clone(),
            Inline::Link { text, .. }
            | Inline::Term { text, .. }
            | Inline::Definition { text, .. }
            | Inline::SpecLink { text, .. }
            | Inline::LessonLink { text, .. } => text.clone(),
        })
        .collect()
}

pub fn phases(text: &str) -> Vec<u8> {
    text.split('-')
        .filter_map(|phase| phase.trim().parse::<u8>().ok())
        .collect()
}
