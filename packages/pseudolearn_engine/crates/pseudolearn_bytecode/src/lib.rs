#![forbid(unsafe_code)]

include!(concat!(env!("OUT_DIR"), "/generated_opcodes.rs"));

mod compile;
mod error;
mod model;
mod verify;
mod verify_superinstructions;

pub use compile::{
    compile_module, compile_module_with_superinstructions, compile_text,
    compile_text_with_superinstructions,
};
pub use error::{BytecodeError, VerificationRule};
pub use model::{
    BasicBlock, BytecodeFunction, BytecodeModule, BytecodeOperand, CodeVariant, Constant,
    Instruction, Register, RegisterClass, RegisterType, ReturnPoint, SuperInstruction,
    VerifiedBytecode,
};
pub use pseudolearn_ir::IrSpan as SourceSpan;
pub use pseudolearn_ir::IrType as ValueType;
pub use verify::verify_bytecode;
