#![forbid(unsafe_code)]

use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use crate::runtime_calls::{RuntimeCall, call_runtime};
use crate::shadow_stack::{pop_roots, push_roots};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, Value, types};
use pseudolearn_ir::{IrType, Operand, Operation, ValueClass, ValueId};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::TaskScopeOpen,
    Operation::TaskSpawn,
    Operation::TaskAwait,
    Operation::TaskScopeJoin,
    Operation::TaskYieldCheck,
    Operation::TaskOutcome,
    Operation::TaskScopeResult,
    Operation::TaskValueLoad,
    Operation::TaskCancelPoint,
    Operation::TaskScopeBoundary,
    Operation::TaskChannel,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::TaskScopeOpen => simple(lowering, instruction, Entry::TaskScopeOpen, &[]),
        Operation::TaskSpawn => lower_spawn(lowering, instruction),
        Operation::TaskAwait => lower_await(lowering, instruction),
        Operation::TaskScopeJoin => {
            let scope = operand_value(lowering, instruction, 0)?;
            rooted(lowering, instruction, Entry::TaskScopeJoin, &[scope]).map(|_| ())
        }
        Operation::TaskYieldCheck => lower_yield(lowering, instruction),
        Operation::TaskOutcome => lower_outcome(lowering, instruction),
        Operation::TaskScopeResult => lower_scope_result(lowering, instruction),
        Operation::TaskValueLoad => lower_value_load(lowering, instruction),
        Operation::TaskCancelPoint => lower_landing(lowering, instruction, None),
        Operation::TaskScopeBoundary => {
            let scope = operand_value(lowering, instruction, 0)?;
            lower_landing(lowering, instruction, Some(scope))
        }
        _ => crate::lower_channels::lower(lowering, instruction),
    }
}

fn simple(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    target: Entry,
    operands: &[Value],
) -> Result<(), CodegenError> {
    let word = call_runtime(
        lowering,
        &RuntimeCall {
            target,
            code_name: "internalFault",
            span: instruction.span,
            operands,
        },
    )?;
    bind_result(lowering, instruction, word);
    Ok(())
}

pub(crate) fn rooted(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    target: Entry,
    operands: &[Value],
) -> Result<Value, CodegenError> {
    let frame = push_roots(lowering, instruction)?;
    let word = call_runtime(
        lowering,
        &RuntimeCall {
            target,
            code_name: "internalFault",
            span: instruction.span,
            operands,
        },
    )?;
    pop_roots(lowering, frame);
    Ok(word)
}

pub(crate) fn packet(
    lowering: &mut Lowering<'_, '_>,
    values: &[ValueId],
    prefix: &[i64],
) -> Result<Value, CodegenError> {
    let mut kinds = Vec::new();
    let mut words = Vec::new();
    for identifier in values {
        let kind = lowering
            .types
            .get(identifier)
            .cloned()
            .ok_or(CodegenError::InvalidModule("task value type"))?;
        let Some(value) = crate::lowering::value_of(lowering, *identifier) else {
            continue;
        };
        let reference = i64::from(kind.value_class() == ValueClass::Reference);
        kinds.push(lowering.builder.ins().iconst(types::I64, reference));
        words.push(crate::word_conversion::to_word(lowering, value, &kind)?);
    }
    let mut packet: Vec<Value> = prefix
        .iter()
        .map(|word| lowering.builder.ins().iconst(types::I64, *word))
        .collect();
    let count = i64::try_from(kinds.len())
        .map_err(|_| CodegenError::InvalidModule("too many task values"))?;
    packet.push(lowering.builder.ins().iconst(types::I64, count));
    packet.extend(kinds);
    packet.extend(words);
    crate::inline_memory::spill_words(lowering, &packet)
}

fn values_of(operands: &[Operand]) -> Vec<ValueId> {
    operands
        .iter()
        .filter_map(|operand| match operand {
            Operand::Value(value) => Some(*value),
            _ => None,
        })
        .collect()
}

fn lower_spawn(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let scope = operand_value(lowering, instruction, 0)?;
    let Some(Operand::FunctionTarget {
        function_name,
        arguments,
    }) = instruction.operands.get(1)
    else {
        return Err(CodegenError::InvalidModule("spawn without target"));
    };
    let index = crate::task_dispatch::dispatch_index(lowering.environment.module, function_name)
        .ok_or(CodegenError::InvalidModule("spawn target without dispatch"))?;
    crate::lower_calls::require_arguments_defined(lowering, instruction, arguments)?;
    let buffer = packet(lowering, arguments, &[i64::from(index)])?;
    simple(lowering, instruction, Entry::TaskSpawn, &[scope, buffer])
}

fn result_type(lowering: &Lowering<'_, '_>, instruction: &Instruction<'_>) -> Option<IrType> {
    instruction
        .result
        .and_then(|value| lowering.types.get(&value))
        .cloned()
}

fn bind_word(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    word: Value,
) -> Result<(), CodegenError> {
    if let Some(kind) = result_type(lowering, instruction).filter(|kind| *kind != IrType::Unit) {
        let value = crate::word_conversion::from_word(lowering, word, &kind)?;
        bind_result(lowering, instruction, value);
    }
    Ok(())
}

fn lower_await(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let task = operand_value(lowering, instruction, 0)?;
    let aggregate = matches!(
        instruction.operands.get(1),
        Some(Operand::Type(IrType::Unit))
    );
    let flag = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(aggregate));
    let word = rooted(lowering, instruction, Entry::TaskAwait, &[task, flag])?;
    bind_word(lowering, instruction, word)
}

fn lower_yield(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    if !lowering.environment.task_runtime {
        return Ok(());
    }
    let mass = lowering.builder.ins().load(
        types::I64,
        MemFlagsData::trusted(),
        lowering.context,
        lowering.environment.layout.quantum_mass,
    );
    let due = lowering.builder.ins().icmp_imm_s(
        IntCC::SignedGreaterThanOrEqual,
        mass,
        i64::try_from(pseudolearn_aot_rt::TASK_QUANTUM).unwrap_or(i64::MAX),
    );
    let yielding = lowering.builder.create_block();
    let next = lowering.builder.create_block();
    lowering.builder.set_cold_block(yielding);
    lowering.builder.ins().brif(due, yielding, &[], next, &[]);
    lowering.builder.switch_to_block(yielding);
    rooted(lowering, instruction, Entry::TaskYield, &[])?;
    lowering.builder.ins().jump(next, &[]);
    lowering.builder.switch_to_block(next);
    Ok(())
}

fn lower_outcome(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let failure = matches!(
        instruction.operands.first(),
        Some(Operand::Identifier(status)) if status == "error"
    );
    let buffer = packet(lowering, &values_of(instruction.operands), &[])?;
    let flag = lowering
        .builder
        .ins()
        .iconst(types::I32, i64::from(failure));
    simple(lowering, instruction, Entry::TaskOutcome, &[flag, buffer])
}

fn lower_scope_result(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let scope = operand_value(lowering, instruction, 0)?;
    let Some(Operand::Type(IrType::Object(name))) = instruction.operands.get(1) else {
        return Err(CodegenError::InvalidModule("scope result without type"));
    };
    let layout = crate::lower_collections::vector_layout_words(lowering, name)?;
    let words: Vec<Value> = layout
        .iter()
        .map(|word| lowering.builder.ins().iconst(types::I64, *word))
        .collect();
    let buffer = crate::inline_memory::spill_words(lowering, &words)?;
    let word = rooted(
        lowering,
        instruction,
        Entry::TaskScopeResult,
        &[scope, buffer],
    )?;
    bind_word(lowering, instruction, word)
}

fn lower_value_load(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let Some(Operand::LiteralI64(index)) = instruction.operands.get(1) else {
        return Err(CodegenError::InvalidModule("value load without index"));
    };
    let position = lowering.builder.ins().iconst(types::I64, *index);
    let word = call_runtime(
        lowering,
        &RuntimeCall {
            target: Entry::TaskValueLoad,
            code_name: "internalFault",
            span: instruction.span,
            operands: &[position],
        },
    )?;
    bind_word(lowering, instruction, word)
}

fn lower_landing(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
    scope: Option<Value>,
) -> Result<(), CodegenError> {
    let index = crate::task_unwinding::landing_index(lowering, instruction.identifier)
        .ok_or(CodegenError::InvalidModule("landing without index"))?;
    let landing = lowering.builder.ins().iconst(types::I32, i64::from(index));
    let (target, operands) = match scope {
        Some(scope) => (Entry::TaskScopeBoundary, vec![scope, landing]),
        None => (Entry::TaskCancelPoint, vec![landing]),
    };
    call_runtime(
        lowering,
        &RuntimeCall {
            target,
            code_name: "internalFault",
            span: instruction.span,
            operands: &operands,
        },
    )
    .map(|_| ())
}
