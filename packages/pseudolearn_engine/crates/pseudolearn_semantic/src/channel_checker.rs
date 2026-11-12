use crate::channel_model::{ChannelAction, ChannelExpression};
use crate::expression_checker::{ExpressionPurpose, check_expected_for};
use crate::identities::{ExpressionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn construct(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: TypeId,
) -> Option<ExpressionId> {
    if session.kind(node) != NodeKind::Postfix {
        return None;
    }
    let target = session.children(node).first().copied()?;
    if crate::collection_types::identity(session, &session.name(target)) != Some("channelType") {
        return None;
    }
    let element = crate::channel_types::element(session, &session.module.types.get(expected))?;
    let integer = session.module.types.intern(Type::Integer);
    let arguments = arguments(session, node, &[integer]);
    if arguments
        .first()
        .is_some_and(|argument| invalid_capacity(session, *argument))
    {
        session.report(DiagnosticCode::ChannelCapacityInvalid, node);
    }
    Some(emit(
        session,
        node,
        expected,
        ChannelExpression {
            action: ChannelAction::New,
            element,
            receiver: None,
            arguments,
        },
    ))
}

pub(crate) fn member(
    session: &mut AnalysisSession<'_>,
    node: usize,
    receiver: ExpressionId,
) -> Option<ExpressionId> {
    let element = crate::channel_types::element(session, &session.expression_type(receiver))?;
    let Some(action) = member_action(session, node) else {
        return Some(crate::expression_checker::invalid(session, node));
    };
    operation_context(session, node, action);
    let parameters = if action == ChannelAction::Send {
        vec![element]
    } else {
        Vec::new()
    };
    let arguments = arguments(session, node, &parameters);
    let result = result_type(session, node, action, element);
    Some(emit(
        session,
        node,
        result,
        ChannelExpression {
            action,
            element,
            receiver: Some(receiver),
            arguments,
        },
    ))
}

fn operation_context(session: &mut AnalysisSession<'_>, node: usize, action: ChannelAction) {
    let pure = session
        .module
        .functions
        .get(usize::try_from(session.current.0).unwrap_or(usize::MAX))
        .is_some_and(|function| crate::effect_check::is_pure_function(session, function));
    if pure {
        session.report(DiagnosticCode::PureFunctionTaskOperation, node);
    } else if matches!(action, ChannelAction::Send | ChannelAction::Receive)
        && !session.awaited_calls.contains(&node)
    {
        session.report(DiagnosticCode::ChannelOperationWithoutAwait, node);
    }
}

pub(crate) fn optional(session: &mut AnalysisSession<'_>, element: TypeId, node: usize) -> TypeId {
    crate::variant_types::register(
        session,
        crate::variant_model::VariantFamily::Optional,
        vec![None, Some(element)],
        node,
    )
}

fn result_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    action: ChannelAction,
    element: TypeId,
) -> TypeId {
    if action == ChannelAction::Receive {
        return optional(session, element, node);
    }
    session
        .module
        .types
        .intern(if action == ChannelAction::Send {
            Type::Boolean
        } else {
            Type::Unit
        })
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: &[TypeId],
) -> Vec<ExpressionId> {
    let nodes = session
        .child(node, NodeKind::Arguments)
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if nodes.len() != expected.len() {
        crate::argument_checker::arity(session, (expected.len(), nodes.len()), node);
    }
    nodes
        .into_iter()
        .zip(expected)
        .map(|(node, expected)| {
            let value = check_expected_for(session, node, *expected, ExpressionPurpose::Argument);
            let kind = session.module.types.get(*expected);
            if !crate::type_resolution::assignable(session, &kind, &session.expression_type(value))
            {
                session.named_report(DiagnosticCode::IncompatibleArgumentType, node, "channel");
            }
            crate::expression_checker::widen(session, value, &kind)
        })
        .collect()
}

fn invalid_capacity(session: &AnalysisSession<'_>, expression: ExpressionId) -> bool {
    constant_capacity(session, expression).is_some_and(|value| value < 1)
}

fn constant_capacity(session: &AnalysisSession<'_>, expression: ExpressionId) -> Option<i64> {
    use crate::expression_model::{BinaryOperator, HirExpression, Literal, UnaryOperator};
    let expression = session
        .module
        .expressions
        .kinds
        .get(usize::try_from(expression.0).ok()?)?;
    match expression {
        HirExpression::Literal(Literal::Integer(value)) => Some(*value),
        HirExpression::Unary {
            operator: UnaryOperator::Negative,
            operand,
            ..
        } => constant_capacity(session, *operand)?.checked_neg(),
        HirExpression::Unary {
            operator: UnaryOperator::Positive,
            operand,
            ..
        } => constant_capacity(session, *operand),
        HirExpression::Binary {
            operator,
            left,
            right,
            ..
        } => {
            let left = constant_capacity(session, *left)?;
            let right = constant_capacity(session, *right)?;
            match operator {
                BinaryOperator::Add => left.checked_add(right),
                BinaryOperator::Subtract => left.checked_sub(right),
                BinaryOperator::Multiply => left.checked_mul(right),
                BinaryOperator::IntegerDivide => left.checked_div(right),
                _ => None,
            }
        }
        _ => None,
    }
}

fn emit(
    session: &mut AnalysisSession<'_>,
    node: usize,
    result: TypeId,
    call: ChannelExpression,
) -> ExpressionId {
    session.emit(
        crate::HirExpression::Channel(call),
        result,
        session.span(node),
    )
}

fn member_action(session: &mut AnalysisSession<'_>, node: usize) -> Option<ChannelAction> {
    let name_node = session.children(node).get(1).copied().unwrap_or(node);
    let identity = crate::collection_types::identity(session, &session.name(name_node));
    Some(match identity {
        Some("channelSend") => ChannelAction::Send,
        Some("channelReceive") => ChannelAction::Receive,
        _ if session.name(name_node).eq_ignore_ascii_case(
            if session.options.profile == pseudolearn_lexicon::Profile::Spanish {
                "Cerrar"
            } else {
                "close"
            },
        ) =>
        {
            ChannelAction::Close
        }
        _ => {
            session.named_report(
                DiagnosticCode::UndefinedMember,
                name_node,
                &session.name(name_node),
            );
            return None;
        }
    })
}

pub(crate) fn suspension_context(session: &mut AnalysisSession<'_>, node: usize) {
    let pure = session
        .module
        .functions
        .get(usize::try_from(session.current.0).unwrap_or(usize::MAX))
        .is_some_and(|function| crate::effect_check::is_pure_function(session, function));
    if pure {
        session.report(DiagnosticCode::PureFunctionTaskOperation, node);
    } else {
        crate::await_checker::context(session, node);
    }
}
