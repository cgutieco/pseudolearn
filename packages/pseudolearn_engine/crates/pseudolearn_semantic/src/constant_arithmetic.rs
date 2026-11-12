use crate::constant_evaluator::{Failure, Value};
use crate::expression_model::{BinaryOperator, Literal};
use crate::types::Type;

#[derive(Clone, Copy)]
enum Number {
    Integer(i64),
    Real(f64),
}

fn number(value: &Value) -> Option<Number> {
    match value {
        (Literal::Integer(integer), Type::Integer) => Some(Number::Integer(*integer)),
        (Literal::Real(real), Type::Real) => Some(Number::Real(*real)),
        _ => None,
    }
}

fn as_real(number: Number) -> f64 {
    match number {
        Number::Integer(integer) => crate::constant_real::integer_to_real(integer),
        Number::Real(real) => real,
    }
}

fn finite(real: f64) -> Result<Value, Failure> {
    if real.is_finite() {
        Ok((Literal::Real(real), Type::Real))
    } else {
        Err(Failure::Overflow)
    }
}

fn integer(value: i64) -> Value {
    (Literal::Integer(value), Type::Integer)
}

fn boolean(value: bool) -> Value {
    (Literal::Boolean(value), Type::Boolean)
}

fn text(value: &Value) -> Option<String> {
    match value {
        (Literal::String(text), Type::String) => Some(text.clone()),
        (Literal::Character(character), Type::Character) => Some(character.to_string()),
        _ => None,
    }
}

pub(crate) fn negate(value: Value) -> Result<Value, Failure> {
    match number(&value) {
        Some(Number::Integer(integer)) => integer
            .checked_neg()
            .map(self::integer)
            .ok_or(Failure::Overflow),
        Some(Number::Real(real)) => finite(-real),
        None => Err(Failure::NotEvaluable),
    }
}

pub(crate) fn keep_sign(value: Value) -> Result<Value, Failure> {
    number(&value).map(|_| value).ok_or(Failure::NotEvaluable)
}

pub(crate) fn invert(value: Value) -> Result<Value, Failure> {
    match value {
        (Literal::Boolean(flag), Type::Boolean) => Ok(boolean(!flag)),
        _ => Err(Failure::NotEvaluable),
    }
}

pub(crate) fn binary(
    operator: BinaryOperator,
    operands: (Value, Value),
    text_limit: usize,
) -> Result<Value, Failure> {
    let (left, right) = operands;
    match operator {
        BinaryOperator::Add => add(left, right, text_limit),
        BinaryOperator::Subtract | BinaryOperator::Multiply => arithmetic(operator, left, right),
        BinaryOperator::Divide => divide(left, right),
        BinaryOperator::IntegerDivide | BinaryOperator::Modulo => {
            integer_division(operator, left, right)
        }
        BinaryOperator::Equal | BinaryOperator::NotEqual => equality(operator, left, right),
        BinaryOperator::Less
        | BinaryOperator::LessEqual
        | BinaryOperator::Greater
        | BinaryOperator::GreaterEqual => ordering(operator, left, right),
        BinaryOperator::Power | BinaryOperator::LogicalAnd | BinaryOperator::LogicalOr => {
            Err(Failure::NotEvaluable)
        }
    }
}

fn add(left: Value, right: Value, text_limit: usize) -> Result<Value, Failure> {
    if let (Some(first), Some(second)) = (text(&left), text(&right)) {
        let joined = format!("{first}{second}");
        if joined.len() > text_limit {
            return Err(Failure::Budget);
        }
        return Ok((Literal::String(joined), Type::String));
    }
    arithmetic(BinaryOperator::Add, left, right)
}

fn arithmetic(operator: BinaryOperator, left: Value, right: Value) -> Result<Value, Failure> {
    let (Some(first), Some(second)) = (number(&left), number(&right)) else {
        return Err(Failure::NotEvaluable);
    };
    if let (Number::Integer(first), Number::Integer(second)) = (first, second) {
        let outcome = match operator {
            BinaryOperator::Add => first.checked_add(second),
            BinaryOperator::Subtract => first.checked_sub(second),
            _ => first.checked_mul(second),
        };
        return outcome.map(integer).ok_or(Failure::Overflow);
    }
    let (first, second) = (as_real(first), as_real(second));
    finite(match operator {
        BinaryOperator::Add => first + second,
        BinaryOperator::Subtract => first - second,
        _ => first * second,
    })
}

fn divide(left: Value, right: Value) -> Result<Value, Failure> {
    let (Some(first), Some(second)) = (number(&left), number(&right)) else {
        return Err(Failure::NotEvaluable);
    };
    let (first, second) = (as_real(first), as_real(second));
    if second == 0.0 {
        return Err(Failure::DivisionByZero);
    }
    finite(first / second)
}

fn integer_division(operator: BinaryOperator, left: Value, right: Value) -> Result<Value, Failure> {
    let (Some(Number::Integer(first)), Some(Number::Integer(second))) =
        (number(&left), number(&right))
    else {
        return Err(Failure::NotEvaluable);
    };
    if second == 0 {
        return Err(Failure::DivisionByZero);
    }
    if operator == BinaryOperator::IntegerDivide {
        return first
            .checked_div(second)
            .map(integer)
            .ok_or(Failure::Overflow);
    }
    if first == i64::MIN && second == -1 {
        return Ok(integer(0));
    }
    first
        .checked_rem(second)
        .map(integer)
        .ok_or(Failure::Overflow)
}

fn equality(operator: BinaryOperator, left: Value, right: Value) -> Result<Value, Failure> {
    let equal = match (number(&left), number(&right)) {
        (Some(first), Some(second)) => as_real(first) == as_real(second),
        (None, None) if left.1 == right.1 && left.1 != Type::Error => left.0 == right.0,
        _ => return Err(Failure::NotEvaluable),
    };
    Ok(boolean(equal == (operator == BinaryOperator::Equal)))
}

fn ordering(operator: BinaryOperator, left: Value, right: Value) -> Result<Value, Failure> {
    let (Some(first), Some(second)) = (number(&left), number(&right)) else {
        return Err(Failure::NotEvaluable);
    };
    let order = match (first, second) {
        (Number::Integer(first), Number::Integer(second)) => Some(first.cmp(&second)),
        _ => as_real(first).partial_cmp(&as_real(second)),
    };
    let Some(order) = order else {
        return Err(Failure::NotEvaluable);
    };
    Ok(boolean(match operator {
        BinaryOperator::Less => order.is_lt(),
        BinaryOperator::LessEqual => order.is_le(),
        BinaryOperator::Greater => order.is_gt(),
        _ => order.is_ge(),
    }))
}
