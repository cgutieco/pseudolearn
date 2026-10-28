use crate::expression_model::{HirExpression, HirPlace};
use crate::identities::ExpressionId;
use crate::statement_model::HirStatement;

pub(crate) fn expression(expression: &HirExpression) -> Vec<ExpressionId> {
    match expression {
        HirExpression::Channel(call) => receiver_arguments(call.receiver, &call.arguments),
        HirExpression::TaskSpawn { arguments, .. } => arguments.clone(),
        HirExpression::AwaitTask(task) => vec![*task],
        HirExpression::Effect {
            receiver,
            arguments,
            ..
        } => receiver
            .iter()
            .copied()
            .chain(arguments.iter().copied())
            .collect(),
        HirExpression::Collection(collection) => {
            receiver_arguments(collection.receiver, &collection.arguments)
        }
        HirExpression::IndirectCall { callee, arguments } => std::iter::once(*callee)
            .chain(arguments.iter().copied())
            .collect(),
        HirExpression::Field { receiver, .. } => vec![*receiver],
        HirExpression::Element { array, indices } => std::iter::once(*array)
            .chain(indices.iter().copied())
            .collect(),
        HirExpression::VirtualCall {
            receiver,
            arguments,
            ..
        } => std::iter::once(*receiver)
            .chain(arguments.iter().copied())
            .collect(),
        other => value_operands(other),
    }
}

fn value_operands(expression: &HirExpression) -> Vec<ExpressionId> {
    match expression {
        HirExpression::Call { arguments, .. }
        | HirExpression::Builtin { arguments, .. }
        | HirExpression::New { arguments, .. }
        | HirExpression::SuperCall { arguments, .. } => arguments.clone(),
        HirExpression::Unary { operand, .. }
        | HirExpression::Widen(operand)
        | HirExpression::VariantTag(operand) => vec![*operand],
        HirExpression::Binary { left, right, .. } => vec![*left, *right],
        HirExpression::RecordNew { fields, .. } => fields.clone(),
        HirExpression::RecordField { record, .. } => vec![*record],
        HirExpression::VariantNew { payload, .. } => payload.iter().copied().collect(),
        HirExpression::VariantPayload { value, .. } | HirExpression::Propagate { value, .. } => {
            vec![*value]
        }
        _ => Vec::new(),
    }
}

pub(crate) fn statement(statement: &HirStatement) -> Vec<ExpressionId> {
    match statement {
        HirStatement::Assign { destination, value } => {
            std::iter::once(*value).chain(place(destination)).collect()
        }
        HirStatement::Conditional { condition, .. }
        | HirStatement::While { condition, .. }
        | HirStatement::Repeat { condition, .. } => vec![*condition],
        HirStatement::For {
            initial,
            ending,
            step,
            ..
        } => [*initial, *ending]
            .into_iter()
            .chain(step.iter().copied())
            .collect(),
        HirStatement::ForEach { collection, .. } => vec![*collection],
        HirStatement::Switch {
            selector, cases, ..
        } => std::iter::once(*selector)
            .chain(
                cases
                    .iter()
                    .flat_map(|branch| branch.labels.iter().copied()),
            )
            .collect(),
        HirStatement::VariantMatch(branch) => std::iter::once(branch.value)
            .chain(std::iter::once(branch.selector))
            .chain(
                branch
                    .cases
                    .iter()
                    .flat_map(|branch| branch.labels.iter().copied()),
            )
            .collect(),
        other => simple_statement(other),
    }
}

fn simple_statement(statement: &HirStatement) -> Vec<ExpressionId> {
    match statement {
        HirStatement::Select(selection) => selection.channels.clone(),
        HirStatement::Spawn(expression) => vec![*expression],
        HirStatement::Write { values, .. } => values.clone(),
        HirStatement::Read(places) => places.iter().flat_map(place).collect(),
        HirStatement::Call(value) => vec![*value],
        HirStatement::Return(value) => value.iter().copied().collect(),
        HirStatement::Dimension(dimensions) => dimensions
            .iter()
            .flat_map(|dimension| dimension.dimensions.iter().copied())
            .collect(),
        _ => Vec::new(),
    }
}

fn place(place: &HirPlace) -> Vec<ExpressionId> {
    match place {
        HirPlace::Field { receiver, .. } => vec![*receiver],
        HirPlace::Element { array, indices } => std::iter::once(*array)
            .chain(indices.iter().copied())
            .collect(),
        HirPlace::Local(_) | HirPlace::WholeArray(_) | HirPlace::RecordField { .. } => Vec::new(),
    }
}

fn receiver_arguments(
    receiver: Option<ExpressionId>,
    arguments: &[ExpressionId],
) -> Vec<ExpressionId> {
    receiver
        .into_iter()
        .chain(arguments.iter().copied())
        .collect()
}
