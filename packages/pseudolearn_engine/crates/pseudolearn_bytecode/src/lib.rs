#![forbid(unsafe_code)]

include!(concat!(env!("OUT_DIR"), "/generated_opcodes.rs"));

mod class_verification;
mod classes;
mod compile;
mod definitions;
mod error;
mod model;
mod root_liveness;
mod roots;
mod verify;
mod verify_padding;
mod verify_superinstructions;
mod verify_types;

pub use compile::{
    compile_module, compile_module_with_superinstructions, compile_text,
    compile_text_with_superinstructions,
};
pub use error::{BytecodeError, VerificationRule};
pub use model::DefinitionState;
pub use model::{
    BasicBlock, BytecodeClass, BytecodeFunction, BytecodeModule, BytecodeOperand, CodeVariant,
    Constant, Instruction, Register, RegisterClass, RegisterType, ReturnPoint, SuperInstruction,
    VerifiedBytecode,
};
pub use pseudolearn_ir::IrSpan as SourceSpan;
pub use pseudolearn_ir::IrType as ValueType;
pub use pseudolearn_ir::SourceProfile;
pub use verify::verify_bytecode;
