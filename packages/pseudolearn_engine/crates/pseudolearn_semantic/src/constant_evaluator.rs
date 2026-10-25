use crate::constant_nodes::{Budget, Context, evaluate};
use crate::constant_registry::ConstantState;
use crate::expression_model::Literal;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) type Value = (Literal, Type);

pub(crate) const MAXIMUM_DEPTH: usize = 256;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Failure {
    NotEvaluable,
    Overflow,
    DivisionByZero,
    Budget,
    Silent,
}

pub(crate) fn ensure(
    session: &mut AnalysisSession<'_>,
    index: usize,
    depth: usize,
) -> Result<Value, Failure> {
    let Some(entry) = session.constants.get(index).cloned() else {
        return Err(Failure::Silent);
    };
    match entry.state {
        ConstantState::Value(literal, kind) => Ok((literal, kind)),
        ConstantState::Failed => Err(Failure::Silent),
        ConstantState::Evaluating => {
            set_state(session, index, ConstantState::Failed);
            session.named_report(
                DiagnosticCode::CircularConstantDefinition,
                entry.name_node,
                &entry.name,
            );
            Err(Failure::Silent)
        }
        ConstantState::Pending => run(session, index, depth),
    }
}

fn set_state(session: &mut AnalysisSession<'_>, index: usize, state: ConstantState) {
    if let Some(entry) = session.constants.get_mut(index) {
        entry.state = state;
    }
}

fn run(session: &mut AnalysisSession<'_>, index: usize, depth: usize) -> Result<Value, Failure> {
    let Some(entry) = session.constants.get(index).cloned() else {
        return Err(Failure::Silent);
    };
    session.switch_unit(entry.unit);
    set_state(session, index, ConstantState::Evaluating);
    let outcome = evaluate_entry(session, &entry, depth);
    match outcome {
        Ok((literal, kind)) => {
            set_state(
                session,
                index,
                ConstantState::Value(literal.clone(), kind.clone()),
            );
            Ok((literal, kind))
        }
        Err(failure) => {
            if matches!(
                session.constants.get(index).map(|entry| &entry.state),
                Some(ConstantState::Evaluating)
            ) {
                report(session, &entry, failure);
            }
            set_state(session, index, ConstantState::Failed);
            Err(Failure::Silent)
        }
    }
}

fn evaluate_entry(
    session: &mut AnalysisSession<'_>,
    entry: &crate::constant_registry::ConstantEntry,
    depth: usize,
) -> Result<Value, Failure> {
    if depth > MAXIMUM_DEPTH {
        return Err(Failure::Budget);
    }
    let expression = session
        .children(entry.node)
        .last()
        .copied()
        .ok_or(Failure::Silent)?;
    let mut budget = Budget {
        steps: session.constant_limits.steps,
        text_bytes: session.constant_limits.text_bytes,
    };
    let context = Context {
        scope: entry.scope,
        depth,
    };
    let value = evaluate(session, expression, context, &mut budget)?;
    coerce(session, entry, value)
}

fn coerce(
    session: &mut AnalysisSession<'_>,
    entry: &crate::constant_registry::ConstantEntry,
    value: Value,
) -> Result<Value, Failure> {
    let expected = session.module.types.get(entry.declared);
    let allowed = matches!(
        expected,
        Type::Integer | Type::Real | Type::Boolean | Type::Character | Type::String | Type::Enum(_)
    );
    if expected == Type::Error {
        return Err(Failure::Silent);
    }
    if !allowed {
        return Err(Failure::NotEvaluable);
    }
    match (&expected, &value) {
        (expected, (_, found)) if expected == found => Ok(value),
        (Type::Real, (Literal::Integer(integer), Type::Integer)) => Ok((
            Literal::Real(crate::constant_real::integer_to_real(*integer)),
            Type::Real,
        )),
        (_, (_, found)) => {
            session.report(DiagnosticCode::IncompatibleTypesInAssignment, entry.node);
            crate::diagnostic_arguments::assignment_types(session, &expected, found);
            Err(Failure::Silent)
        }
    }
}

fn report(
    session: &mut AnalysisSession<'_>,
    entry: &crate::constant_registry::ConstantEntry,
    failure: Failure,
) {
    let code = match failure {
        Failure::NotEvaluable => DiagnosticCode::ConstantNotEvaluable,
        Failure::Overflow => DiagnosticCode::ConstantArithmeticOverflow,
        Failure::DivisionByZero => DiagnosticCode::ConstantDivisionByZero,
        Failure::Budget => DiagnosticCode::ConstantBudgetExceeded,
        Failure::Silent => return,
    };
    session.named_report(code, entry.name_node, &entry.name);
}
