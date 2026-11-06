use pseudolearn_semantic::{ServiceAnalysis, Type};
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::BTreeMap;

const LIBRARY_FIELDS: [&str; 1] = ["jsonErrorCodeField"];

pub(crate) fn register(
    tree: &SyntaxTree,
    analysis: &ServiceAnalysis,
    candidates: &BTreeMap<usize, &'static str>,
    output: &mut BTreeMap<usize, &'static str>,
) {
    for (token, identity) in candidates {
        if LIBRARY_FIELDS.contains(identity)
            && previous_dot(tree, *token).is_some_and(|dot| library_receiver(analysis, dot))
        {
            output.insert(*token, *identity);
        }
    }
}

fn previous_dot(tree: &SyntaxTree, token: usize) -> Option<u32> {
    let previous = (0..token).rev().find(|slot| {
        tree.tokens
            .kind(*slot)
            .is_some_and(|kind| !kind.is_trivia())
    })?;
    if tree.tokens.kind(previous)? != TokenKind::Dot {
        return None;
    }
    Some(tree.tokens.span(previous)?.start)
}

fn library_receiver(analysis: &ServiceAnalysis, dot: u32) -> bool {
    let expressions = &analysis.module.expressions;
    expressions
        .spans
        .iter()
        .zip(&expressions.types)
        .filter(|(span, _)| span.ending == dot)
        .any(
            |(_, type_id)| match analysis.module.types.representation(*type_id) {
                Type::Record(record) => usize::try_from(record.0)
                    .ok()
                    .and_then(|index| analysis.module.records.get(index))
                    .is_some_and(|record| record.name.starts_with('$')),
                _ => false,
            },
        )
}
