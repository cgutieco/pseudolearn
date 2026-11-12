use crate::completion_templates::{get_template, is_unit_construction};
use crate::spelling::keyword_spelling;
use crate::template_catalog::build_template;
use crate::template_render::{plain_layout, render};
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind, parse_source};

pub fn template_program(construction: &str, profile: Profile) -> Option<String> {
    let template = get_template(construction, profile)?;
    let open = keyword_spelling(KeywordKind::Algorithm, profile);
    let close = keyword_spelling(KeywordKind::EndAlgorithm, profile);
    let program = match construction {
        "algorithm" => template,
        _ if is_unit_construction(construction) => {
            format!("{template}\n{open} Main\n{close}\n")
        }
        _ => format!("{open} Main\n{template}\n{close}\n"),
    };
    Some(program)
}

pub fn template_parses_cleanly(construction: &str, profile: Profile) -> bool {
    let Some(program) = template_program(construction, profile) else {
        return false;
    };
    let (_, diagnostics) = parse_source(&SourceText::new(program), profile);
    diagnostics.is_empty()
}

pub fn template_stops_valid(construction: &str, profile: Profile) -> bool {
    let (Some(template), Some(program)) = (
        build_template(construction, profile),
        template_program(construction, profile),
    ) else {
        return false;
    };
    let rendered = render(&template, plain_layout());
    let Some(base) = program.find(&rendered.text) else {
        return false;
    };
    let source = SourceText::new(program.clone());
    let (tree, _) = parse_source(&source, profile);
    let stops_on_identifiers = rendered
        .stops
        .iter()
        .all(|stop| identifier_at(&tree, base, stop.start, stop.end));
    stops_on_identifiers && blank_line_at(&program, base.saturating_add(rendered.final_offset))
}

fn identifier_at(tree: &SyntaxTree, base: usize, start: usize, end: usize) -> bool {
    let (first, last) = (base.saturating_add(start), base.saturating_add(end));
    (0..tree.tokens.token_count()).any(|index| {
        let (Some(kind), Some(span)) = (tree.tokens.kind(index), tree.tokens.span(index)) else {
            return false;
        };
        kind == TokenKind::Identifier
            && usize::try_from(span.start).is_ok_and(|value| value == first)
            && usize::try_from(span.ending).is_ok_and(|value| value == last)
    })
}

fn blank_line_at(program: &str, offset: usize) -> bool {
    let head = program.get(..offset).unwrap_or("");
    let tail = program.get(offset..).unwrap_or("");
    let before = head.rsplit('\n').next().unwrap_or("");
    let after = tail.split('\n').next().unwrap_or("");
    before.trim().is_empty() && after.trim().is_empty()
}
