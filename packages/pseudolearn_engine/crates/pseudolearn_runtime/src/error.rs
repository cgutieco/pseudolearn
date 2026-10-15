#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ArithmeticError {
    DivisionByZero,
    IntegerOverflow,
    NegativeExponent,
    NonFiniteRealResult,
}
