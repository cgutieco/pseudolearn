use pseudolearn_semantic::{
    expression_model::{HirExpression, HirPlace},
    hir::HirModule,
    identities::{ExpressionId, FieldId},
    statement_model::HirStatement,
    types::Type,
};
use std::collections::BTreeSet;

pub(crate) fn dense(class: usize, module: &HirModule) -> bool {
    let chain = ancestors(class, module);
    let required = chain
        .iter()
        .filter_map(|index| module.classes.get(*index))
        .flat_map(|class| &class.fields)
        .filter(|field| module.types.get(field.type_id) == Type::Integer)
        .map(|field| field.id)
        .collect::<BTreeSet<_>>();
    if required.is_empty() {
        return true;
    }
    let mut assigned = BTreeSet::new();
    for index in chain.iter().rev() {
        let body = module
            .classes
            .get(*index)
            .and_then(|class| class.constructor)
            .and_then(|constructor| usize::try_from(constructor.0).ok())
            .and_then(|index| module.functions.get(index))
            .map(|function| function.body.as_slice())
            .unwrap_or(&[]);
        for statement in body {
            let statement = usize::try_from(statement.0)
                .ok()
                .and_then(|index| module.statements.kinds.get(index));
            if !advance(statement, module, &mut assigned) {
                return false;
            }
            if required.is_subset(&assigned) {
                return true;
            }
        }
    }
    false
}

fn ancestors(class: usize, module: &HirModule) -> Vec<usize> {
    let mut chain = Vec::new();
    let mut current = Some(class);
    for _ in 0..module.classes.len() {
        let Some(index) = current else {
            break;
        };
        chain.push(index);
        current = module
            .classes
            .get(index)
            .and_then(|class| class.superclass)
            .and_then(|parent| usize::try_from(parent.0).ok());
    }
    chain
}

fn advance(
    statement: Option<&HirStatement>,
    module: &HirModule,
    assigned: &mut BTreeSet<FieldId>,
) -> bool {
    match statement {
        Some(HirStatement::Declare(_)) => true,
        Some(HirStatement::Assign { destination, value }) if pure(*value, module) => {
            match destination {
                HirPlace::Local(_) => true,
                HirPlace::Field { receiver, field }
                    if expression(*receiver, module)
                        .is_some_and(|expression| matches!(expression, HirExpression::This(_))) =>
                {
                    assigned.insert(*field);
                    true
                }
                _ => false,
            }
        }
        Some(HirStatement::Call(target)) => match expression(*target, module) {
            Some(HirExpression::SuperCall {
                function,
                arguments,
                ..
            }) => {
                let constructor = function
                    .and_then(|identity| usize::try_from(identity.0).ok())
                    .and_then(|index| module.functions.get(index))
                    .is_none_or(|function| {
                        function.kind == pseudolearn_semantic::hir::FunctionKind::Constructor
                    });
                constructor && arguments.iter().all(|argument| pure(*argument, module))
            }
            _ => false,
        },
        _ => false,
    }
}

fn pure(identity: ExpressionId, module: &HirModule) -> bool {
    let mut pending = vec![identity];
    while let Some(identity) = pending.pop() {
        match expression(identity, module) {
            Some(HirExpression::Literal(_) | HirExpression::Local(_)) => {}
            Some(HirExpression::Unary { operand, .. } | HirExpression::Widen(operand)) => {
                pending.push(*operand)
            }
            Some(HirExpression::Binary { left, right, .. }) => pending.extend([*left, *right]),
            _ => return false,
        }
    }
    true
}

fn expression(identity: ExpressionId, module: &HirModule) -> Option<&HirExpression> {
    usize::try_from(identity.0)
        .ok()
        .and_then(|index| module.expressions.kinds.get(index))
}
