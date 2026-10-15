use crate::expression_model::BinaryOperator;
use crate::types::Type;

pub(crate) fn numeric(kind: &Type) -> bool {
    matches!(
        kind,
        Type::Integer | Type::Real | Type::Unknown | Type::Error
    )
}

pub(crate) fn result_type(operator: BinaryOperator, left: &Type, right: &Type) -> Type {
    use BinaryOperator::*;
    if *left == Type::Error || *right == Type::Error {
        return Type::Error;
    }
    if matches!(operator, LogicalAnd | LogicalOr) {
        return logical_type(left, right);
    }
    if matches!(
        operator,
        Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual
    ) {
        return relation_type(left, right);
    }
    if operator == Add
        && matches!(left, Type::String | Type::Character)
        && matches!(right, Type::String | Type::Character)
    {
        return Type::String;
    }
    if !numeric(left) || !numeric(right) {
        return Type::Error;
    }
    if matches!(operator, IntegerDivide | Modulo) {
        return if *left == Type::Integer && *right == Type::Integer {
            Type::Integer
        } else {
            Type::Error
        };
    }
    if operator == Divide || *left == Type::Real || *right == Type::Real {
        Type::Real
    } else {
        Type::Integer
    }
}

fn logical_type(left: &Type, right: &Type) -> Type {
    if matches!(left, Type::Boolean | Type::Unknown)
        && matches!(right, Type::Boolean | Type::Unknown)
    {
        Type::Boolean
    } else {
        Type::Error
    }
}

fn relation_type(left: &Type, right: &Type) -> Type {
    if left == right
        || numeric(left) && numeric(right)
        || matches!((left, right), (Type::Object(_), Type::Object(_)))
    {
        Type::Boolean
    } else {
        Type::Error
    }
}
