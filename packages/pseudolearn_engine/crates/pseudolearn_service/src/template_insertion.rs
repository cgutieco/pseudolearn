use crate::block_layout::is_opener;
use crate::completion::CompletionTextEdit;
use crate::document_session::DocumentSession;
use crate::insertion::{Insertion, line_indent, templated};
use crate::template_catalog::build_template;
use crate::template_model::{Segment, Template};
use crate::template_render::DEFAULT_INDENT_UNIT;
use crate::template_reuse::reuse_existing_closer;
use crate::typing_lines::{line_code_tokens, line_end, line_start};
use pseudolearn_syntax::TokenKind;

pub fn build_template_insertion(
    document: &DocumentSession,
    construction: &str,
    replace: (usize, usize),
) -> Option<Insertion> {
    let mut template = build_template(construction, document.profile)?;
    let text = document.text();
    let (start, end) = replace;
    reuse_existing_closer(
        &mut template,
        text,
        &CompletionTextEdit {
            start_utf8: start,
            end_utf8: end,
        },
        document.profile,
    );
    let first = line_start(text, start);
    let before = text.get(first..start)?;
    let mut indent = line_indent(text, start).to_owned();
    if line_opens_block(document, first) {
        indent.push_str(DEFAULT_INDENT_UNIT);
    }
    let mut segments = Vec::new();
    if !before.trim().is_empty() {
        segments.push(Segment::NewLine);
    }
    segments.extend(template.segments);
    let target = CompletionTextEdit {
        start_utf8: start,
        end_utf8: end,
    };
    Some(templated(&Template { segments }, &target, &indent))
}

fn line_opens_block(document: &DocumentSession, first: usize) -> bool {
    let end = line_end(document.text(), first);
    line_code_tokens(&document.tree, first, end)
        .first()
        .is_some_and(|token| matches!(token.kind, TokenKind::Keyword(kind) if is_opener(kind)))
}
