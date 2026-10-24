#![forbid(unsafe_code)]

use pseudolearn_ir::{BlockId, IrSpan, IrType, ValueClass};
use std::collections::BTreeMap;

use crate::Opcode;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum RegisterClass {
    Scalar,
    Reference,
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct Register {
    pub class: RegisterClass,
    pub index: u16,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RegisterType {
    pub class: RegisterClass,
    pub value_type: IrType,
}

#[derive(Clone, Debug, PartialEq)]
pub enum Constant {
    I64(i64),
    F64(f64),
    Bool(bool),
    Char(char),
    Str(String),
}

#[derive(Clone, Debug, PartialEq)]
pub enum BytecodeOperand {
    Register(Register),
    BlockTarget {
        target: BlockId,
        arguments: Vec<Register>,
    },
    FunctionTarget {
        function_index: u16,
        arguments: Vec<Register>,
    },
    Constant(u16),
    Type(IrType),
    Predicate(String),
    Identifier(String),
    Newline,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Instruction {
    pub opcode: Opcode,
    pub destination: Option<Register>,
    pub operands: Vec<BytecodeOperand>,
    pub span: Option<IrSpan>,
    pub return_point: Option<u32>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct BasicBlock {
    pub identifier: BlockId,
    pub start_pc: u32,
    pub parameters: Vec<Register>,
    pub mass: u32,
    pub event_mass: u32,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct CodeVariant {
    pub instructions: Vec<Instruction>,
    pub used_length: u32,
    pub blocks: Vec<BasicBlock>,
    pub superinstructions: BTreeMap<u32, u32>,
    pub roots: BTreeMap<u32, Vec<Register>>,
    pub definitions: BTreeMap<u32, BTreeMap<Register, DefinitionState>>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DefinitionState {
    Defined,
    Undefined,
    Dynamic,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SuperInstruction {
    CompareBranch,
    FusedArithmetic,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ReturnPoint {
    pub identifier: u32,
    pub function_index: u16,
    pub fast_program_counter: u32,
    pub fast_continuation_pc: u32,
    pub probed_program_counter: u32,
    pub probed_continuation_pc: u32,
}

#[derive(Clone, Debug, PartialEq)]
pub struct BytecodeFunction {
    pub name: String,
    pub declaration_span: Option<IrSpan>,
    pub names: BTreeMap<Register, String>,
    pub parameters: Vec<Register>,
    pub scalar_types: Vec<IrType>,
    pub reference_types: Vec<IrType>,
    pub constants: Vec<Constant>,
    pub fast: CodeVariant,
    pub probed: CodeVariant,
    pub return_points: Vec<ReturnPoint>,
}

impl BytecodeFunction {
    pub fn register_type(&self, register: Register) -> Option<&IrType> {
        match register.class {
            RegisterClass::Scalar => self.scalar_types.get(usize::from(register.index)),
            RegisterClass::Reference => self.reference_types.get(usize::from(register.index)),
        }
    }

    pub fn register_class(value_class: ValueClass) -> Option<RegisterClass> {
        match value_class {
            ValueClass::Scalar | ValueClass::Unit => Some(RegisterClass::Scalar),
            ValueClass::Reference => Some(RegisterClass::Reference),
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct BytecodeModule {
    pub name: String,
    pub vocabulary: String,
    pub profiles: Vec<pseudolearn_ir::SourceProfile>,
    pub classes: Vec<BytecodeClass>,
    pub functions: Vec<BytecodeFunction>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct BytecodeClass {
    pub name: String,
    pub superclass: Option<String>,
    pub fields: Vec<(String, IrType)>,
    pub methods: BTreeMap<String, u16>,
    pub dense_integers: bool,
    pub references: Vec<u32>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct VerifiedBytecode(BytecodeModule);

impl VerifiedBytecode {
    pub(crate) fn new(module: BytecodeModule) -> Self {
        Self(module)
    }

    pub fn module(&self) -> &BytecodeModule {
        &self.0
    }
}
