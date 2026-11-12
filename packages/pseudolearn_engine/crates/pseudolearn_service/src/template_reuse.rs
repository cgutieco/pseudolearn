use crate::block_matching::build_block_map;
use crate::completion::CompletionTextEdit;
use crate::insertion::{TextChange, apply_change};
use crate::template_model::{Segment, Template};
use crate::template_render::{plain_layout, render};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, parse_source};

pub fn reuse_existing_closer(
    template: &mut Template,
    source: &str,
    replace: &CompletionTextEdit,
    profile: Profile,
) {
    let rendered = render(template, plain_layout());
    let header = rendered.text.lines().next().unwrap_or("");
    if suffix_closes_header(source, replace, header, profile)
        && let Some(final_slot) = template
            .segments
            .iter()
            .position(|segment| *segment == Segment::Final)
    {
        template.segments.truncate(final_slot.saturating_add(1));
    }
}

fn suffix_closes_header(
    source: &str,
    replace: &CompletionTextEdit,
    header: &str,
    profile: Profile,
) -> bool {
    let change = TextChange {
        start_utf8: replace.start_utf8,
        end_utf8: replace.end_utf8,
        text: header.to_owned(),
    };
    let edited = SourceText::new(apply_change(source, &change));
    let (tree, _) = parse_source(&edited, profile);
    let Some(opener) = token_starting_at(&tree, replace.start_utf8) else {
        return false;
    };
    let map = build_block_map(&tree, edited.as_str());
    let Some(closer) = map
        .closing_token(opener)
        .and_then(|token| tree.tokens.span(token))
    else {
        return false;
    };
    let Some(original_start) = usize::try_from(closer.start)
        .ok()
        .and_then(|start| start.checked_sub(header.len()))
        .and_then(|start| start.checked_add(replace.end_utf8.saturating_sub(replace.start_utf8)))
    else {
        return false;
    };
    let (original, _) = parse_source(&SourceText::new(source.to_owned()), profile);
    suffix_is_available(&original, source, original_start, replace)
}

fn suffix_is_available(
    tree: &SyntaxTree,
    source: &str,
    closer_start: usize,
    replace: &CompletionTextEdit,
) -> bool {
    let Some(closer) = token_starting_at(tree, closer_start) else {
        return false;
    };
    build_block_map(tree, source)
        .opening_token(closer)
        .and_then(|token| tree.tokens.span(token))
        .is_none_or(|opener| {
            usize::try_from(opener.start).is_ok_and(|start| start >= replace.start_utf8)
                && usize::try_from(opener.ending).is_ok_and(|end| end <= replace.end_utf8)
        })
}

fn token_starting_at(tree: &SyntaxTree, start: usize) -> Option<usize> {
    (0..tree.tokens.token_count()).find(|token| {
        tree.tokens
            .span(*token)
            .is_some_and(|span| usize::try_from(span.start).ok() == Some(start))
    })
}
