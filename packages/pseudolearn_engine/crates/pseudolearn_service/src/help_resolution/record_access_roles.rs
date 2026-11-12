use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_semantic::Type;
use pseudolearn_source::Span;
use pseudolearn_syntax::TokenKind;

const POSTFIX: &str = "postfix";

#[derive(Clone)]
struct TypedExpression {
    start: u32,
    ending: u32,
    kind: Type,
}

pub(super) fn record_access(
    context: &QueryContext<'_>,
    slot: usize,
    kind: TokenKind,
) -> Option<(HelpIdentity, Span)> {
    match kind {
        TokenKind::Dot => class_record_field(context, slot),
        TokenKind::LeftBracket => record_array_element(context, slot),
        TokenKind::RightBracket => record_array_element(context, opening_bracket(context, slot)?),
        _ => None,
    }
}

fn class_record_field(context: &QueryContext<'_>, slot: usize) -> Option<(HelpIdentity, Span)> {
    let dot = context.tree.tokens.span(slot)?;
    let receiver = expression_ending_at(context, dot.start)?;
    let member_ending = context
        .tree
        .tokens
        .span(next_significant(context, slot)?)?
        .ending;
    let member = expression_between(context, receiver.start, member_ending)?;
    selects_class_record(context, &receiver, &member).then(|| {
        (
            identity(HelpIdentityKind::Role, POSTFIX, "pgl01_record_class_field"),
            span_of(dot, &member),
        )
    })
}

fn selects_class_record(
    context: &QueryContext<'_>,
    receiver: &TypedExpression,
    member: &TypedExpression,
) -> bool {
    match (&receiver.kind, &member.kind) {
        (Type::Object(_), Type::Record(_)) => true,
        (Type::Record(_), _) => is_class_record_selection(context, receiver),
        _ => false,
    }
}

fn is_class_record_selection(context: &QueryContext<'_>, selection: &TypedExpression) -> bool {
    let Some(inner_dot) = last_dot_within(context, selection) else {
        return false;
    };
    expression_ending_at(context, inner_dot.start)
        .filter(|receiver| receiver.start == selection.start)
        .is_some_and(|receiver| selects_class_record(context, &receiver, selection))
}

fn record_array_element(context: &QueryContext<'_>, slot: usize) -> Option<(HelpIdentity, Span)> {
    let bracket = context.tree.tokens.span(slot)?;
    let receiver = expression_ending_at(context, bracket.start)?;
    let Type::Array { element, .. } = receiver.kind.clone() else {
        return None;
    };
    matches!(context.analysis.module.types.get(element), Type::Record(_)).then(|| {
        (
            identity(
                HelpIdentityKind::Role,
                POSTFIX,
                "pgl01_record_array_element",
            ),
            span_of(bracket, &receiver),
        )
    })
}

fn opening_bracket(context: &QueryContext<'_>, slot: usize) -> Option<usize> {
    let mut depth: usize = 0;
    for index in (0..slot).rev() {
        match context.tree.tokens.kind(index)? {
            TokenKind::RightBracket => depth = depth.checked_add(1)?,
            TokenKind::LeftBracket if depth == 0 => return Some(index),
            TokenKind::LeftBracket => depth = depth.checked_sub(1)?,
            _ => {}
        }
    }
    None
}

fn expression_ending_at(context: &QueryContext<'_>, offset: u32) -> Option<TypedExpression> {
    typed_expressions(context)
        .filter(|expression| expression.ending == offset)
        .min_by_key(|expression| expression.start)
}

fn expression_between(
    context: &QueryContext<'_>,
    start: u32,
    ending: u32,
) -> Option<TypedExpression> {
    typed_expressions(context)
        .find(|expression| expression.start == start && expression.ending == ending)
}

fn typed_expressions<'query>(
    context: &'query QueryContext<'_>,
) -> impl Iterator<Item = TypedExpression> + 'query {
    context
        .analysis
        .expression_types
        .iter()
        .map(|(span, type_id)| TypedExpression {
            start: span.start,
            ending: trimmed_ending(context, *span),
            kind: context.analysis.module.types.get(*type_id),
        })
}

fn trimmed_ending(context: &QueryContext<'_>, span: Span) -> u32 {
    let text = context.source.as_str();
    let (Ok(start), Ok(ending)) = (usize::try_from(span.start), usize::try_from(span.ending))
    else {
        return span.ending;
    };
    text.get(start..ending)
        .map(str::trim_end)
        .and_then(|trimmed| u32::try_from(trimmed.len()).ok())
        .and_then(|length| span.start.checked_add(length))
        .unwrap_or(span.ending)
}

fn last_dot_within(context: &QueryContext<'_>, selection: &TypedExpression) -> Option<Span> {
    (0..context.tree.tokens.token_count())
        .filter(|index| context.tree.tokens.kind(*index) == Some(TokenKind::Dot))
        .filter_map(|index| context.tree.tokens.span(index))
        .filter(|span| span.start > selection.start && span.ending < selection.ending)
        .max_by_key(|span| span.start)
}

fn next_significant(context: &QueryContext<'_>, slot: usize) -> Option<usize> {
    (slot.checked_add(1)?..context.tree.tokens.token_count()).find(|index| {
        context
            .tree
            .tokens
            .kind(*index)
            .is_some_and(|kind| !kind.is_trivia())
    })
}

fn span_of(token: Span, expression: &TypedExpression) -> Span {
    Span {
        start: expression.start.min(token.start),
        ending: expression.ending.max(token.ending),
        ..token
    }
}
