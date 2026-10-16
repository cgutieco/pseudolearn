#![forbid(unsafe_code)]

mod assignability;
pub mod columns;
pub mod dominance;
pub mod identities;
pub mod lexer;
pub mod model;
pub mod operand;
pub mod operand_parser;
pub mod operation;
pub mod parser;
pub mod printer;
pub mod span;
pub mod tokens;
pub mod type_checker;
pub mod type_checker_calls;
mod type_checker_collections;
pub mod type_checker_control;
pub mod type_checker_helpers;
pub mod type_checker_intrinsics;
mod type_checker_memory;
pub mod type_checker_values;
pub mod type_parser;
pub mod types;
pub mod verifier;
pub mod verifier_operands;

pub use columns::{InstructionColumns, InstructionDefinition};
pub use dominance::DominatorTree;
pub use identities::{BlockId, ClassId, FunctionId, InstructionId, ValueId, VariableId};
pub use model::{
    Block, ClassDeclaration, FieldDeclaration, Function, Module, OriginEntry, OriginTable,
};
pub use operand::{Operand, PredicateKind};
pub use operation::Operation;
pub use parser::parse_module;
pub use printer::print_canonical;
pub use span::IrSpan;
pub use types::{IrType, ValueClass};
pub use verifier::verify_module;
