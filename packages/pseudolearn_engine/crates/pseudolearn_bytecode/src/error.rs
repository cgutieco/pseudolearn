#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum VerificationRule {
    OperandWindow,
    FunctionJump,
    ValueClass,
    ReturnPoint,
    SuperInstruction,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum BytecodeError {
    InvalidIr(&'static str),
    InvalidText(String),
    InvalidModule,
    MissingValue,
    MissingFunction,
    MissingBlock,
    UnsupportedOperation,
    TooManyRegisters,
    TooManyConstants,
    Verification(VerificationRule),
}
