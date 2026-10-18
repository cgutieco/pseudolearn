#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::array_fast_path::require_present;
use crate::error::CodegenError;
use crate::inline_memory::{
    begin_fast_path, branch_unless, clif_load, defined_word, element_slot, finish_fast_path,
    heap_base, spill_words,
};
use crate::lower_scalars::{predicate_of, unsigned_condition};
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::object_fast_path::{define, require_defined};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use crate::word_conversion::{from_word, to_word};
use cranelift_codegen::ir::{Block, BlockArg, InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::{IrType, Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::ObjectNew,
    Operation::ObjectCopy,
    Operation::ObjectLoad,
    Operation::ObjectStore,
    Operation::RefCmp,
];

pub(crate) struct FieldTarget {
    pub(crate) index: u32,
    pub(crate) field_type: IrType,
}

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::ObjectNew => lower_new(lowering, instruction),
        Operation::ObjectCopy => lower_copy(lowering, instruction),
        Operation::ObjectLoad => lower_load(lowering, instruction),
        Operation::ObjectStore => lower_store(lowering, instruction),
        _ => lower_reference_comparison(lowering, instruction),
    }
}

pub(crate) fn field_target(
    lowering: &Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<FieldTarget, CodegenError> {
    let (Some(Operand::Value(object)), Some(Operand::Identifier(name))) =
        (instruction.operands.first(), instruction.operands.get(1))
    else {
        return Err(CodegenError::InvalidModule("malformed field access"));
    };
    let Some(IrType::Object(class)) = lowering.types.get(object) else {
        return Err(CodegenError::InvalidModule("field access on a non-object"));
    };
    let (index, field_type) = lowering
        .environment
        .classes
        .field(class, name)
        .ok_or(CodegenError::InvalidModule("unknown field"))?;
    Ok(FieldTarget {
        index: u32::try_from(index).map_err(|_| CodegenError::InvalidModule("field index"))?,
        field_type: field_type.clone(),
    })
}

fn lower_new(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::Identifier(name)) = instruction.operands.first() else {
        return Err(CodegenError::InvalidModule("object.new without class"));
    };
    let class = lowering
        .environment
        .classes
        .class_index(name)
        .and_then(|index| u32::try_from(index).ok())
        .ok_or(CodegenError::InvalidModule("unknown class"))?;
    let class_value = lowering.builder.ins().iconst(types::I32, i64::from(class));
    allocate(lowering, instruction, (Entry::ObjectNew, class_value))
}

fn lower_copy(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let source = operand_value(lowering, instruction, 0)?;
    allocate(lowering, instruction, (Entry::ObjectCopy, source))
}

fn allocate(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (target, operand): (Entry, Value),
) -> Result<(), CodegenError> {
    let frame = push_roots(lowering, instruction)?;
    let operands = [operand];
    let call = RuntimeCall {
        target,
        code_name: "cellLimitExceeded",
        span: instruction.span,
        operands: &operands,
    };
    let word = call_runtime(lowering, &call)?;
    pop_roots(lowering, frame);
    let handle = lowering.builder.ins().ireduce(types::I32, word);
    bind_result(lowering, instruction, handle);
    Ok(())
}

fn payload_slot(lowering: &mut Lowering<'_, '_>, base: Value, index: u32) -> (Value, Value) {
    let header = lowering
        .builder
        .ins()
        .load(types::I64, MemFlagsData::trusted(), base, 0);
    let flags = lowering.builder.ins().ushr_imm_u(header, 32);
    let payload = lowering.builder.ins().band_imm_u(flags, 0xFFFF);
    let position = lowering.builder.ins().iadd_imm_s(payload, i64::from(index));
    (payload, element_slot(lowering, base, position))
}

fn lower_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = field_target(lowering, instruction)?;
    let object = operand_value(lowering, instruction, 0)?;
    let joined = begin_fast_path(lowering, Some(clif_load(&target.field_type)));
    let fast = fast_field_load(lowering, (object, &target), joined.slow)?;
    lowering
        .builder
        .ins()
        .jump(joined.merge, &[BlockArg::Value(fast)]);
    lowering.builder.switch_to_block(joined.slow);
    let slow = slow_field_load(lowering, instruction, (object, &target))?;
    lowering
        .builder
        .ins()
        .jump(joined.merge, &[BlockArg::Value(slow)]);
    let merged = finish_fast_path(lowering, &joined)
        .ok_or(CodegenError::InvalidModule("missing merged value"))?;
    bind_result(lowering, instruction, merged);
    Ok(())
}

fn fast_field_load(
    lowering: &mut Lowering<'_, '_>,
    (object, target): (Value, &FieldTarget),
    slow: Block,
) -> Result<Value, CodegenError> {
    require_present(lowering, object, slow);
    let (_, base) = heap_base(lowering, object);
    let (payload, address) = payload_slot(lowering, base, target.index);
    let value = lowering.builder.ins().load(
        clif_load(&target.field_type),
        MemFlagsData::trusted(),
        address,
        0,
    );
    match defined_word(lowering, value, &target.field_type) {
        Some(condition) => branch_unless(lowering, condition, slow),
        None => {
            require_defined(lowering, (base, payload, target.index), slow)
                .ok_or(CodegenError::InvalidModule("field index out of range"))?;
        }
    }
    Ok(value)
}

fn slow_field_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    (object, target): (Value, &FieldTarget),
) -> Result<Value, CodegenError> {
    let index = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(target.index));
    let operands = [object, index];
    let call = RuntimeCall {
        target: Entry::ObjectLoad,
        code_name: "uninitializedVariableRead",
        span: instruction.span,
        operands: &operands,
    };
    let word = call_runtime(lowering, &call)?;
    from_word(lowering, word, &target.field_type)
}

fn lower_store(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = field_target(lowering, instruction)?;
    let object = operand_value(lowering, instruction, 0)?;
    let value = operand_value(lowering, instruction, 2)?;
    let word = to_word(lowering, value, &target.field_type)?;
    let joined = begin_fast_path(lowering, None);
    require_present(lowering, object, joined.slow);
    let (_, base) = heap_base(lowering, object);
    let (payload, address) = payload_slot(lowering, base, target.index);
    if target.field_type == IrType::I64 {
        define(lowering, (base, payload, target.index))
            .ok_or(CodegenError::InvalidModule("field index out of range"))?;
    }
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), word, address, 0);
    lowering.builder.ins().jump(joined.merge, &[]);
    lowering.builder.switch_to_block(joined.slow);
    let index = lowering
        .builder
        .ins()
        .iconst(types::I64, i64::from(target.index));
    let buffer = spill_words(lowering, &[index, word])?;
    let operands = [object, buffer];
    let call = RuntimeCall {
        target: Entry::ObjectStore,
        code_name: "uninitializedVariableRead",
        span: instruction.span,
        operands: &operands,
    };
    call_runtime(lowering, &call)?;
    lowering.builder.ins().jump(joined.merge, &[]);
    finish_fast_path(lowering, &joined);
    Ok(())
}

fn lower_reference_comparison(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let predicate = predicate_of(instruction)?;
    let left = operand_value(lowering, instruction, 1)?;
    let right = operand_value(lowering, instruction, 2)?;
    let result = lowering
        .builder
        .ins()
        .icmp(unsigned_condition(predicate), left, right);
    bind_result(lowering, instruction, result);
    Ok(())
}
