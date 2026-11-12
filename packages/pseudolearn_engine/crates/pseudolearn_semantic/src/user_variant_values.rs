use crate::expression_checker::{ExpressionPurpose, invalid};
use crate::expression_model::HirExpression;
use crate::generic_state::GenericTemplate;
use crate::identities::{ExpressionId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::{NodeKind, TokenKind};

#[derive(Clone, Copy)]
pub(crate) struct Shape {
    pub qualifier: usize,
    pub member: usize,
    pub arguments: Option<usize>,
}

pub(crate) fn shape(session: &AnalysisSession<'_>, node: usize) -> Option<Shape> {
    match session.kind(node) {
        NodeKind::Primary => match session.children(node).as_slice() {
            [only] => shape(session, *only),
            _ => None,
        },
        NodeKind::Postfix if session.operator_kind(node) == Some(TokenKind::Dot) => {
            qualified(session, node)
        }
        _ => None,
    }
}

fn qualified(session: &AnalysisSession<'_>, node: usize) -> Option<Shape> {
    let children = session.children(node);
    let (target, member) = (children.first().copied()?, children.get(1).copied()?);
    if session.kind(member) != NodeKind::Identifier {
        return None;
    }
    let arguments = children
        .get(2)
        .copied()
        .filter(|child| session.kind(*child) == NodeKind::Arguments);
    Some(Shape {
        qualifier: plain_identifier(session, target)?,
        member,
        arguments,
    })
}

pub(crate) fn plain_identifier(session: &AnalysisSession<'_>, node: usize) -> Option<usize> {
    match session.kind(node) {
        NodeKind::Identifier => Some(node),
        NodeKind::Primary => match session.children(node).as_slice() {
            [only] => plain_identifier(session, *only),
            _ => None,
        },
        _ => None,
    }
}

pub(crate) fn construct(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: Option<TypeId>,
) -> Option<ExpressionId> {
    let shape = shape(session, node)?;
    let name = session.name(shape.qualifier);
    if session.local(&name).is_some() {
        return None;
    }
    if let Some(variant) = session.declared.variants.get(&name).copied() {
        return Some(build(session, (node, shape), variant, None));
    }
    let template = session.generics.variants.get(&name).cloned()?;
    crate::generic_symbols::note_named_use(session, shape.qualifier, &name);
    if let Some(variant) = crate::generic_variants::from_context(session, &template, expected) {
        return Some(build(session, (node, shape), variant, None));
    }
    Some(infer(session, (node, shape), &template))
}

pub(crate) fn alternative_index(
    session: &mut AnalysisSession<'_>,
    variant: RecordId,
    member: usize,
) -> Option<(usize, Option<RecordId>)> {
    let wanted = session.name(member);
    let found = session
        .module
        .user_variants
        .get(&variant)
        .and_then(|model| {
            model
                .alternatives
                .iter()
                .position(|alternative| alternative.name == wanted)
                .and_then(|index| Some((index, model.alternatives.get(index)?.payload)))
        });
    if found.is_none() {
        let spelling = session.lexeme(member).to_owned();
        session.named_report(DiagnosticCode::UndefinedMember, member, &spelling);
    }
    found
}

pub(crate) fn field_types(session: &AnalysisSession<'_>, payload: Option<RecordId>) -> Vec<TypeId> {
    payload
        .and_then(|record| usize::try_from(record.0).ok())
        .and_then(|slot| session.module.records.get(slot))
        .map(|model| model.fields.iter().map(|field| field.type_id).collect())
        .unwrap_or_default()
}

fn build(
    session: &mut AnalysisSession<'_>,
    (node, shape): (usize, Shape),
    variant: RecordId,
    checked: Option<Vec<ExpressionId>>,
) -> ExpressionId {
    let Some((alternative, payload)) = alternative_index(session, variant, shape.member) else {
        return invalid(session, node);
    };
    let nodes = shape
        .arguments
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    let expected = field_types(session, payload);
    if nodes.len() != expected.len() {
        crate::argument_checker::arity(session, (expected.len(), nodes.len()), node);
        return invalid(session, node);
    }
    let arguments = checked.unwrap_or_else(|| {
        nodes
            .into_iter()
            .zip(expected)
            .map(|(child, kind)| crate::expression_checker::check_expected(session, child, kind))
            .collect()
    });
    let payload = payload
        .map(|record| crate::record_access::construct_with(session, node, (record, arguments)));
    let kind = session.module.types.intern(Type::Record(variant));
    session.emit(
        HirExpression::VariantNew {
            record: variant,
            alternative: u32::try_from(alternative).unwrap_or(0),
            payload,
        },
        kind,
        session.span(node),
    )
}

fn infer(
    session: &mut AnalysisSession<'_>,
    (node, shape): (usize, Shape),
    template: &GenericTemplate,
) -> ExpressionId {
    let nodes = shape
        .arguments
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    let arguments: Vec<ExpressionId> = nodes
        .into_iter()
        .map(|child| {
            crate::expression_checker::check_for(session, child, ExpressionPurpose::Argument)
        })
        .collect();
    let types: Vec<TypeId> = arguments
        .iter()
        .filter_map(|argument| {
            usize::try_from(argument.0)
                .ok()
                .and_then(|index| session.module.expressions.types.get(index))
                .copied()
        })
        .collect();
    let wanted = session.name(shape.member);
    let bound = crate::generic_home::at_home(session, template, |session| {
        bind(session, template, &wanted, &types)
    });
    let Some(kinds) = bound else {
        session.report(DiagnosticCode::AmbiguousVariantType, node);
        return invalid(session, node);
    };
    match crate::generic_variants::instantiate(session, template, kinds, node) {
        Some(variant) => build(session, (node, shape), variant, Some(arguments)),
        None => invalid(session, node),
    }
}

fn bind(
    session: &AnalysisSession<'_>,
    template: &GenericTemplate,
    wanted: &str,
    types: &[TypeId],
) -> Option<Vec<TypeId>> {
    let alternative = session.children(template.node).into_iter().find(|child| {
        session.kind(*child) == NodeKind::VariantAlternative
            && session
                .child(*child, NodeKind::Identifier)
                .is_some_and(|name| session.name(name) == wanted)
    })?;
    let fields: Vec<usize> = session
        .children(alternative)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::AlternativeField)
        .filter_map(|field| session.child(field, NodeKind::Type))
        .collect();
    template
        .parameters
        .iter()
        .map(|parameter| {
            fields.iter().zip(types).find_map(|(field, kind)| {
                let direct = session.child(*field, NodeKind::TypeArguments).is_none()
                    && session.name(*field) == *parameter;
                (direct && session.module.types.get(*kind) != Type::Error).then_some(*kind)
            })
        })
        .collect()
}
