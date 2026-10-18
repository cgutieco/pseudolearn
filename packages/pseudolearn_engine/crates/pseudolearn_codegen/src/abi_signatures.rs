#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::ir::{AbiParam, FuncRef, Function, Signature, Type, types};
use cranelift_module::{FuncId, Linkage, Module};
use cranelift_object::ObjectModule;
use std::collections::HashMap;

pub const FAULT_SYMBOL: &str = "rt_aot_fault";
pub const MATH_UNARY_SYMBOL: &str = "rt_aot_math_unary";
pub const REAL_POWER_SYMBOL: &str = "rt_aot_real_power";
pub const INTEGER_POWER_SYMBOL: &str = "rt_aot_integer_power";

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub(crate) enum Entry {
    Fault,
    MathUnary,
    RealPower,
    IntegerPower,
    TextLiteral,
    TextConcat,
    TextFormat,
    TextQuery,
    TextCharacter,
    TextCompare,
    RandomReal,
    Write,
    Read,
    ArrayNew,
    ObjectNew,
    ObjectCopy,
    ArrayLoad,
    ArrayStore,
    ObjectLoad,
    ObjectStore,
    CellMark,
    CellRelease,
    CellLocal,
    CellElement,
    CellField,
    CellLoad,
    CellStore,
}

#[derive(Clone, Copy)]
enum Slot {
    Word32,
    Word64,
    Address,
}

const NO_OPERANDS: &[Slot] = &[];
const ONE_WORD32: &[Slot] = &[Slot::Word32];
const TWO_WORD64: &[Slot] = &[Slot::Word64, Slot::Word64];

const TABLE: &[(Entry, &str, &[Slot])] = &[
    (Entry::Fault, FAULT_SYMBOL, NO_OPERANDS),
    (
        Entry::MathUnary,
        MATH_UNARY_SYMBOL,
        &[Slot::Word32, Slot::Word64],
    ),
    (Entry::RealPower, REAL_POWER_SYMBOL, TWO_WORD64),
    (Entry::IntegerPower, INTEGER_POWER_SYMBOL, TWO_WORD64),
    (
        Entry::TextLiteral,
        "rt_aot_text_literal",
        &[Slot::Address, Slot::Address],
    ),
    (Entry::TextConcat, "rt_aot_text_concat", TWO_WORD64),
    (
        Entry::TextFormat,
        "rt_aot_text_format",
        &[Slot::Word64, Slot::Word32],
    ),
    (
        Entry::TextQuery,
        "rt_aot_text_query",
        &[Slot::Word32, Slot::Word64],
    ),
    (Entry::TextCharacter, "rt_aot_text_character", TWO_WORD64),
    (Entry::TextCompare, "rt_aot_text_compare", TWO_WORD64),
    (Entry::RandomReal, "rt_aot_random_real", NO_OPERANDS),
    (Entry::Write, "rt_aot_write", &[Slot::Word64, Slot::Word32]),
    (Entry::Read, "rt_aot_read", ONE_WORD32),
    (
        Entry::ArrayNew,
        "rt_aot_array_new",
        &[Slot::Word32, Slot::Address],
    ),
    (Entry::ObjectNew, "rt_aot_object_new", ONE_WORD32),
    (Entry::ObjectCopy, "rt_aot_object_copy", ONE_WORD32),
    (
        Entry::ArrayLoad,
        "rt_aot_array_load",
        &[Slot::Word32, Slot::Address],
    ),
    (
        Entry::ArrayStore,
        "rt_aot_array_store",
        &[Slot::Word32, Slot::Address],
    ),
    (
        Entry::ObjectLoad,
        "rt_aot_object_load",
        &[Slot::Word32, Slot::Word32],
    ),
    (
        Entry::ObjectStore,
        "rt_aot_object_store",
        &[Slot::Word32, Slot::Address],
    ),
    (Entry::CellMark, "rt_aot_cell_mark", NO_OPERANDS),
    (Entry::CellRelease, "rt_aot_cell_release", ONE_WORD32),
    (Entry::CellLocal, "rt_aot_cell_local", ONE_WORD32),
    (
        Entry::CellElement,
        "rt_aot_cell_element",
        &[Slot::Word32, Slot::Address],
    ),
    (
        Entry::CellField,
        "rt_aot_cell_field",
        &[Slot::Word32, Slot::Word32],
    ),
    (Entry::CellLoad, "rt_aot_cell_load", ONE_WORD32),
    (
        Entry::CellStore,
        "rt_aot_cell_store",
        &[Slot::Word32, Slot::Word64],
    ),
];

pub(crate) struct RuntimeImports {
    identifiers: Vec<(Entry, FuncId)>,
}

pub(crate) struct RuntimeRefs {
    references: HashMap<Entry, FuncRef>,
}

impl RuntimeRefs {
    pub(crate) fn get(&self, entry: Entry) -> Result<FuncRef, CodegenError> {
        self.references
            .get(&entry)
            .copied()
            .ok_or(CodegenError::InvalidModule("undeclared runtime entry"))
    }
}

impl RuntimeImports {
    pub(crate) fn declare(module: &mut ObjectModule, pointer: Type) -> Result<Self, CodegenError> {
        let mut identifiers = Vec::new();
        for (entry, symbol, operands) in TABLE {
            let mut parameters = vec![pointer, types::I32];
            parameters.extend(operands.iter().map(|slot| slot_type(*slot, pointer)));
            identifiers.push((*entry, declare_import(module, symbol, &parameters)?));
        }
        Ok(Self { identifiers })
    }

    pub(crate) fn import_into(
        &self,
        module: &mut ObjectModule,
        function: &mut Function,
    ) -> RuntimeRefs {
        RuntimeRefs {
            references: self
                .identifiers
                .iter()
                .map(|(entry, identifier)| {
                    (*entry, module.declare_func_in_func(*identifier, function))
                })
                .collect(),
        }
    }
}

fn slot_type(slot: Slot, pointer: Type) -> Type {
    match slot {
        Slot::Word32 => types::I32,
        Slot::Word64 => types::I64,
        Slot::Address => pointer,
    }
}

fn declare_import(
    module: &mut ObjectModule,
    symbol: &str,
    parameters: &[Type],
) -> Result<FuncId, CodegenError> {
    let mut signature: Signature = module.make_signature();
    for parameter in parameters {
        signature.params.push(AbiParam::new(*parameter));
    }
    signature.returns.push(AbiParam::new(types::I32));
    module
        .declare_function(symbol, Linkage::Import, &signature)
        .map_err(CodegenError::backend)
}
