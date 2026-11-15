use super::context::smallest_node;
use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(super) fn generic_bracket(
    context: &QueryContext<'_>,
    slot: usize,
    operator: &str,
) -> Option<(HelpIdentity, Span)> {
    if !matches!(operator, "lessThan" | "greaterThan") {
        return None;
    }
    let (list, span) = smallest_node(context, slot, |kind| {
        matches!(kind, NodeKind::TypeParameters | NodeKind::TypeArguments)
    })?;
    let (owner, _) = smallest_node(context, slot, declares_type_parameters)?;
    let (id, role) = match (owner, list) {
        (NodeKind::ClassUnit, _) => ("classUnit", "pgl04_generic_class"),
        (NodeKind::InterfaceUnit, _) => ("interfaceUnit", "pgl04_generic_interface"),
        (_, NodeKind::TypeParameters) => ("typeParameter", "pgl04_type_parameter"),
        _ => return None,
    };
    Some((identity(HelpIdentityKind::Role, id, role), span))
}

pub(super) fn type_parameter_name(
    context: &QueryContext<'_>,
    slot: usize,
) -> Option<(HelpIdentity, Span)> {
    if context.tree.tokens.kind(slot) != Some(TokenKind::Identifier) {
        return None;
    }
    let (_, span) = smallest_node(context, slot, |kind| kind == NodeKind::TypeParameter)?;
    let token = context.tree.tokens.span(slot)?;
    if token.start != span.start {
        return None;
    }
    Some((
        identity(
            HelpIdentityKind::Role,
            "typeParameter",
            "pgl04_type_parameter",
        ),
        span,
    ))
}

fn declares_type_parameters(kind: NodeKind) -> bool {
    matches!(
        kind,
        NodeKind::ClassUnit
            | NodeKind::InterfaceUnit
            | NodeKind::RecordUnit
            | NodeKind::VariantUnit
            | NodeKind::Subroutine
            | NodeKind::Subprogram
    )
}
