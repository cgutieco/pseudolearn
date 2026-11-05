use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_semantic::ServiceSymbolTarget;
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(super) fn type_import(context: &QueryContext<'_>, slot: usize) -> Option<(HelpIdentity, Span)> {
    let (directive, span, _) = super::module_directive::module_directive(context, slot)?;
    if directive.role != "module_import" {
        return None;
    }
    let line_ending = line_ending(context, slot)?;
    context
        .imported_types
        .iter()
        .any(|(start, ending)| *start >= span.start && *ending <= line_ending)
        .then(|| {
            (
                identity(
                    HelpIdentityKind::Role,
                    "importDeclaration",
                    "pgl02_type_import",
                ),
                span,
            )
        })
}

pub(super) fn public_signature(
    context: &QueryContext<'_>,
    slot: usize,
) -> Option<(HelpIdentity, Span)> {
    let unit = next_significant(context, slot)?;
    let regions = match context.tree.tokens.kind(unit)? {
        TokenKind::Keyword(KeywordKind::Subroutine) => vec![header(context, slot)?],
        TokenKind::Keyword(KeywordKind::ClassKeyword) => class_regions(context, [slot, unit])?,
        _ => return None,
    };
    let names_module_type = context.analysis.occurrences.iter().any(|reference| {
        !reference.is_declaration
            && is_module_type(reference.target)
            && regions.iter().any(|region| {
                region.start <= reference.span.start && reference.span.ending <= region.ending
            })
    });
    let span = context.tree.tokens.span(slot)?;
    names_module_type.then(|| {
        (
            identity(
                HelpIdentityKind::Role,
                "moduleUnit",
                "pgl02_public_signature",
            ),
            span,
        )
    })
}

fn is_module_type(target: ServiceSymbolTarget) -> bool {
    matches!(
        target,
        ServiceSymbolTarget::Class(_)
            | ServiceSymbolTarget::Interface(_)
            | ServiceSymbolTarget::Enum(_)
            | ServiceSymbolTarget::Record(_)
    )
}

fn class_regions(context: &QueryContext<'_>, first_tokens: [usize; 2]) -> Option<Vec<Span>> {
    let class = (0..context.tree.node_count()).find(|index| {
        context.tree.node(*index).is_some_and(|node| {
            node.kind == NodeKind::ClassUnit
                && usize::try_from(node.first_token)
                    .is_ok_and(|first| first_tokens.contains(&first))
        })
    })?;
    Some(
        context
            .tree
            .child_indices(class)
            .iter()
            .filter_map(|child| member_region(context, *child))
            .collect(),
    )
}

fn member_region(context: &QueryContext<'_>, index: usize) -> Option<Span> {
    let node = context.tree.node(index)?;
    let first = usize::try_from(node.first_token).ok()?;
    if context.tree.tokens.kind(first) == Some(TokenKind::Keyword(KeywordKind::PrivateVisibility)) {
        return None;
    }
    match node.kind {
        NodeKind::FieldDeclaration => context.tree.span_for_node(index),
        NodeKind::MethodMember | NodeKind::ConstructorMember => header(context, first),
        _ => None,
    }
}

fn header(context: &QueryContext<'_>, slot: usize) -> Option<Span> {
    let start = context.tree.tokens.span(slot)?;
    Some(Span {
        ending: line_ending(context, slot)?,
        ..start
    })
}

fn line_ending(context: &QueryContext<'_>, slot: usize) -> Option<u32> {
    let newline = (slot..context.tree.tokens.token_count())
        .find(|index| context.tree.tokens.kind(*index) == Some(TokenKind::Newline))?;
    context.tree.tokens.span(newline).map(|span| span.start)
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
