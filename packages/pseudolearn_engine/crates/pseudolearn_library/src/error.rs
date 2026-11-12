#![forbid(unsafe_code)]

use pseudolearn_runtime::ArithmeticError;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum LibraryError {
    Arithmetic(ArithmeticError),
    NegativeSquareRoot,
    NonFiniteInput,
    NonFiniteResult,
    PrecisionExhausted,
}

impl From<ArithmeticError> for LibraryError {
    fn from(error: ArithmeticError) -> Self {
        Self::Arithmetic(error)
    }
}
