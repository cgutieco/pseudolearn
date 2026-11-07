use reference_model::{CalloutKind, FigureSource, Inline, RouteFence, SourceBlock};

#[derive(Clone, Debug)]
pub struct TextGroup<'text> {
    pub zone: Option<CalloutKind>,
    pub inlines: &'text [Inline],
}

impl TextGroup<'_> {
    pub fn in_problem(&self) -> bool {
        matches!(
            self.zone,
            Some(CalloutKind::Problem | CalloutKind::Statement)
        )
    }
}

pub fn text_groups(blocks: &[SourceBlock]) -> Vec<TextGroup<'_>> {
    let mut groups = Vec::new();
    collect(blocks, None, &mut groups);
    groups
}

fn collect<'text>(
    blocks: &'text [SourceBlock],
    zone: Option<CalloutKind>,
    groups: &mut Vec<TextGroup<'text>>,
) {
    for block in blocks {
        if let SourceBlock::Callout { kind, blocks, .. } = block {
            collect(blocks, zone.or(Some(*kind)), groups);
            continue;
        }
        groups.extend(
            block_inlines(block)
                .into_iter()
                .map(|inlines| TextGroup { zone, inlines }),
        );
    }
}

fn block_inlines(block: &SourceBlock) -> Vec<&[Inline]> {
    match block {
        SourceBlock::Heading { text, .. } | SourceBlock::Paragraph(text) => vec![text.as_slice()],
        SourceBlock::List { entries, .. } => entries.iter().map(Vec::as_slice).collect(),
        SourceBlock::Table { header, rows } => header
            .iter()
            .chain(rows.iter().flatten())
            .map(Vec::as_slice)
            .collect(),
        SourceBlock::Figure(figure) => figure_groups(figure),
        SourceBlock::Route(fence) => fence_groups(fence),
        _ => Vec::new(),
    }
}

fn figure_groups(figure: &FigureSource) -> Vec<&[Inline]> {
    let mut groups = vec![figure.caption.as_slice()];
    groups.extend(figure.steps.iter().map(|step| step.text.as_slice()));
    groups.extend(figure.panels.iter().map(|panel| panel.text.as_slice()));
    groups
}

fn fence_groups(fence: &RouteFence) -> Vec<&[Inline]> {
    match fence {
        RouteFence::Steps(steps) => steps.iter().map(Vec::as_slice).collect(),
        RouteFence::Elements(elements) => elements
            .iter()
            .map(|element| element.text.as_slice())
            .collect(),
        RouteFence::Choices(choices) => choices
            .iter()
            .flat_map(|choice| [choice.text.as_slice(), choice.justification.as_slice()])
            .collect(),
        _ => Vec::new(),
    }
}

pub fn prose(inlines: &[Inline]) -> String {
    inlines
        .iter()
        .map(|inline| match inline {
            Inline::Code(_) | Inline::Slot(_) => " ",
            Inline::Text(text)
            | Inline::Strong(text)
            | Inline::Emphasis(text)
            | Inline::Link { text, .. }
            | Inline::Term { text, .. }
            | Inline::Definition { text, .. }
            | Inline::SpecLink { text, .. }
            | Inline::LessonLink { text, .. } => text.as_str(),
        })
        .collect::<Vec<&str>>()
        .join("")
        .to_lowercase()
}

pub fn contains_form(text: &str, form: &str) -> bool {
    let form = form.to_lowercase();
    if form.is_empty() {
        return false;
    }
    text.match_indices(&form).any(|(position, _)| {
        let before = text.get(..position).and_then(|head| head.chars().last());
        let after = text
            .get(position.saturating_add(form.len())..)
            .and_then(|tail| tail.chars().next());
        before.is_none_or(|character| !character.is_alphanumeric())
            && after.is_none_or(|character| !character.is_alphanumeric())
    })
}

pub fn marked_terms(inlines: &[Inline]) -> Vec<(&str, bool)> {
    inlines
        .iter()
        .filter_map(|inline| match inline {
            Inline::Term { term, .. } => Some((term.as_str(), false)),
            Inline::Definition { term, .. } => Some((term.as_str(), true)),
            _ => None,
        })
        .collect()
}

pub fn recalled_terms(blocks: &[SourceBlock]) -> Vec<String> {
    crate::source_walk::all_blocks(blocks)
        .into_iter()
        .filter_map(|block| match block {
            SourceBlock::Callout {
                kind: CalloutKind::Recall,
                attributes,
                ..
            } => attributes.get("termino").cloned(),
            _ => None,
        })
        .collect()
}

pub fn summary_lists(blocks: &[SourceBlock]) -> Vec<&[Inline]> {
    blocks
        .iter()
        .filter(|block| crate::route_terms::is_summary(block))
        .flat_map(|block| match block {
            SourceBlock::Callout { blocks, .. } => blocks
                .iter()
                .flat_map(|inner| match inner {
                    SourceBlock::List { entries, .. } => {
                        entries.iter().map(Vec::as_slice).collect()
                    }
                    _ => Vec::new(),
                })
                .collect(),
            _ => Vec::new(),
        })
        .collect()
}
