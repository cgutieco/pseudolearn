use crate::Resolution;
use crate::spelling::fragment_tokens;
use reference_model::{Inline, Run};

pub fn runs(resolution: &Resolution<'_>, inlines: &[Inline]) -> Vec<Run> {
    inlines
        .iter()
        .map(|inline| run(resolution, inline))
        .collect()
}

fn run(resolution: &Resolution<'_>, inline: &Inline) -> Run {
    match inline {
        Inline::Text(text) => Run::Text { text: text.clone() },
        Inline::Strong(text) => Run::Strong { text: text.clone() },
        Inline::Emphasis(text) => Run::Emphasis { text: text.clone() },
        Inline::Slot(text) => Run::Slot { text: text.clone() },
        Inline::Code(code) => Run::Code {
            tokens: fragment_tokens(resolution, code, resolution.language),
        },
        Inline::Link { section, text } => Run::Link {
            section: section.clone(),
            text: text.clone(),
        },
        Inline::Term { term, text } => Run::Term {
            term: term.clone(),
            text: text.clone(),
        },
    }
}

pub fn plain(text: impl Into<String>) -> Vec<Run> {
    vec![Run::Text { text: text.into() }]
}
