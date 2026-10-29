use crate::expression_checker::invalid;
use crate::expression_model::{HirExpression, Literal};
use crate::identities::{EnumId, ExpressionId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_source::IdentifierNormalizer;
use pseudolearn_syntax::NodeKind;

pub(crate) fn lookup(
    session: &mut AnalysisSession<'_>,
    target: usize,
    member: usize,
) -> Option<Result<(EnumId, u32), ()>> {
    let name_node = identifier_of(session, target)?;
    let name = session.name(name_node);
    let enumeration = session
        .declared
        .enums
        .get(&name)
        .copied()
        .or_else(|| crate::json_types::builtin_enum(session, &name))
        .or_else(|| crate::http_types::builtin_enum(session, &name))?;
    let wanted = session.name(member);
    let ordinal = usize::try_from(enumeration.0)
        .ok()
        .and_then(|slot| session.module.enums.get(slot))
        .and_then(|model| {
            model
                .members
                .iter()
                .position(|spelling| IdentifierNormalizer::normalize(spelling) == wanted)
        })
        .and_then(|position| u32::try_from(position).ok());
    match ordinal {
        Some(ordinal) => Some(Ok((enumeration, ordinal))),
        None => {
            let spelling = session.lexeme(member).to_owned();
            session.named_report(DiagnosticCode::UndefinedEnumMember, member, &spelling);
            Some(Err(()))
        }
    }
}

fn identifier_of(session: &AnalysisSession<'_>, target: usize) -> Option<usize> {
    match session.kind(target) {
        NodeKind::Identifier => Some(target),
        NodeKind::Primary => {
            let children = session.children(target);
            let [only] = children.as_slice() else {
                return None;
            };
            (session.kind(*only) == NodeKind::Identifier).then_some(*only)
        }
        _ => None,
    }
}

pub(crate) fn expression(session: &mut AnalysisSession<'_>, node: usize) -> Option<ExpressionId> {
    if session.child(node, NodeKind::Arguments).is_some() {
        return None;
    }
    let children = session.children(node);
    let target = children.first().copied()?;
    let member = children.get(1).copied()?;
    let name_node = identifier_of(session, target)?;
    if session.local(&session.name(name_node)).is_some() {
        return None;
    }
    match lookup(session, target, member)? {
        Ok((enumeration, ordinal)) => {
            let kind = session.module.types.intern(Type::Enum(enumeration));
            Some(session.emit(
                HirExpression::Literal(Literal::Integer(i64::from(ordinal))),
                kind,
                session.span(node),
            ))
        }
        Err(()) => Some(invalid(session, node)),
    }
}
