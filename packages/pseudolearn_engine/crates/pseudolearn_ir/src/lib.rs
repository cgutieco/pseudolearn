#![forbid(unsafe_code)]

mod assignability;
pub mod collection_types;
pub mod columns;
pub mod dominance;
pub mod identities;
pub mod lexer;
mod lexer_literals;
pub mod model;
pub mod operand;
pub mod operand_parser;
pub mod operation;
pub mod parser;
pub mod printer;
mod profile_parser;
pub mod span;
pub mod tokens;
pub mod type_checker;
pub mod type_checker_calls;
mod type_checker_collections;
pub mod type_checker_control;
mod type_checker_dynamic_collections;
pub mod type_checker_helpers;
pub mod type_checker_intrinsics;
mod type_checker_memory;
mod type_checker_tasks;
pub mod type_checker_values;
pub mod type_parser;
pub mod types;
pub mod verifier;
mod verifier_layouts;
pub mod verifier_operands;

pub use columns::{InstructionColumns, InstructionDefinition};
pub use dominance::DominatorTree;
pub use identities::{BlockId, ClassId, FunctionId, InstructionId, ValueId, VariableId};
pub use model::{
    Block, ClassDeclaration, FieldDeclaration, Function, Module, OriginEntry, OriginTable,
    SourceProfile,
};
pub use operand::{Operand, PredicateKind};
pub use operation::Operation;
pub use parser::parse_module;
pub use printer::print_canonical;
pub use span::{IrPosition, IrSpan};
pub use types::{IrType, ValueClass};
pub use verifier::verify_module;
pub use verifier_layouts::{ENVIRONMENT_CLASS_PREFIX, environment_fields_are_ordered};

mod identifier_text;

mod type_checker_effects;

#[cfg(test)]
mod type_checker_tasks_tests;

mod type_checker_channels;

mod verifier_suspension;
#[cfg(test)]
mod verifier_suspension_tests;

mod type_checker_snapshots;

mod parser_result;

pub mod suspension_points;

#[cfg(test)]
mod suspension_points_tests;
