#![forbid(unsafe_code)]

use crate::columns::InstructionColumns;
use crate::dominance::DominatorTree;
use crate::identities::{BlockId, InstructionId, ValueId};
use crate::model::{Block, Function, Module};
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker::check_instruction_types;
use crate::types::IrType;
use crate::verifier_operands::{
    BlockTargetContext, OperandUsageContext, check_block_targets, check_function_calls,
    check_operands_dominance,
};
use std::collections::{HashMap, HashSet};

pub fn verify_module(module: &Module) -> Result<(), &'static str> {
    check_declarations_uniqueness(module)?;
    check_profile_uniqueness(module)?;
    for function in &module.functions {
        verify_function(function, module)?;
    }
    Ok(())
}

fn check_profile_uniqueness(module: &Module) -> Result<(), &'static str> {
    let mut sources = HashSet::new();
    for profile in &module.profiles {
        if !sources.insert(profile.source_id) {
            return Err("IR.MODEL#R1");
        }
    }
    Ok(())
}

fn check_declarations_uniqueness(module: &Module) -> Result<(), &'static str> {
    let mut class_names = HashSet::new();
    for class_declaration in &module.classes {
        if !class_names.insert(&class_declaration.name) {
            return Err("IR.WELL-FORMEDNESS#R8");
        }
    }
    let mut function_names = HashSet::new();
    for function in &module.functions {
        if !function_names.insert(&function.name) {
            return Err("IR.WELL-FORMEDNESS#R8");
        }
    }
    Ok(())
}

struct VerificationContext<'source> {
    function: &'source Function,
    module: &'source Module,
    dominance: &'source DominatorTree,
}

struct VerificationState {
    definitions: HashMap<ValueId, (Option<BlockId>, usize)>,
    value_types: HashMap<ValueId, IrType>,
}

fn verify_function(function: &Function, module: &Module) -> Result<(), &'static str> {
    for block in &function.blocks {
        check_block_terminator(block, &function.columns)?;
        check_block_mass(block, &function.columns)?;
    }
    let dominance = DominatorTree::compute(function);
    let mut state = VerificationState {
        definitions: HashMap::new(),
        value_types: HashMap::new(),
    };

    register_parameters(function, &mut state)?;

    let context = VerificationContext {
        function,
        module,
        dominance: &dominance,
    };
    verify_function_blocks(&context, &mut state)
}

fn register_parameters(
    function: &Function,
    state: &mut VerificationState,
) -> Result<(), &'static str> {
    for (parameter_value, parameter_type) in &function.parameters {
        if state
            .definitions
            .insert(*parameter_value, (None, 0))
            .is_some()
        {
            return Err("IR.WELL-FORMEDNESS#R2");
        }
        state
            .value_types
            .insert(*parameter_value, parameter_type.clone());
    }
    for block in &function.blocks {
        for (parameter_value, parameter_type) in &block.parameters {
            if state
                .definitions
                .insert(*parameter_value, (Some(block.identifier), 0))
                .is_some()
            {
                return Err("IR.WELL-FORMEDNESS#R2");
            }
            state
                .value_types
                .insert(*parameter_value, parameter_type.clone());
        }
    }
    Ok(())
}

fn verify_function_blocks(
    context: &VerificationContext<'_>,
    state: &mut VerificationState,
) -> Result<(), &'static str> {
    for block in &context.function.blocks {
        for (instruction_index, &instruction_id) in block.instructions.iter().enumerate() {
            let verify_state = InstructionVerifyState {
                block,
                instruction_id,
                instruction_index,
            };
            verify_single_instruction(context, &verify_state, state)?;
        }
    }
    Ok(())
}

fn check_block_terminator(block: &Block, columns: &InstructionColumns) -> Result<(), &'static str> {
    let last_instruction_id = block.instructions.last().ok_or("IR.WELL-FORMEDNESS#R4")?;
    let last_operation = columns
        .operation(*last_instruction_id)
        .ok_or("IR.WELL-FORMEDNESS#R1")?;
    if !last_operation.is_terminator() {
        return Err("IR.WELL-FORMEDNESS#R4");
    }
    let empty_instructions: &[InstructionId] = &[];
    for &instruction_id in block
        .instructions
        .split_last()
        .map_or(empty_instructions, |(_, rest)| rest)
    {
        if let Some(operation) = columns.operation(instruction_id)
            && operation.is_terminator()
        {
            return Err("IR.WELL-FORMEDNESS#R4");
        }
    }
    Ok(())
}

fn check_block_mass(block: &Block, columns: &InstructionColumns) -> Result<(), &'static str> {
    let mut enter_count = 0u32;
    for &instruction_id in &block.instructions {
        if columns.operation(instruction_id) == Some(Operation::StmtEnter) {
            enter_count = enter_count.saturating_add(1);
        }
    }
    if block.mass != enter_count {
        return Err("IR.WELL-FORMEDNESS#R6");
    }
    Ok(())
}

struct InstructionVerifyState<'state> {
    block: &'state Block,
    instruction_id: InstructionId,
    instruction_index: usize,
}

fn verify_single_instruction(
    context: &VerificationContext<'_>,
    state: &InstructionVerifyState<'_>,
    verification_state: &mut VerificationState,
) -> Result<(), &'static str> {
    check_instruction_validity(context, state, verification_state)?;
    record_instruction_result(context, state, verification_state)
}

fn check_span_requirement(
    operation: Operation,
    columns: &InstructionColumns,
    instruction_id: InstructionId,
) -> Result<(), &'static str> {
    if columns
        .span(instruction_id)
        .is_some_and(|span| !span.is_valid())
    {
        return Err("IR.WELL-FORMEDNESS#R7");
    }
    if (operation.can_trap() || operation.is_observation())
        && columns.span(instruction_id).is_none()
    {
        return Err("IR.WELL-FORMEDNESS#R7");
    }
    Ok(())
}

fn check_instruction_validity(
    context: &VerificationContext<'_>,
    state: &InstructionVerifyState<'_>,
    verification_state: &mut VerificationState,
) -> Result<(), &'static str> {
    let columns = &context.function.columns;
    let operation = columns
        .operation(state.instruction_id)
        .ok_or("IR.WELL-FORMEDNESS#R1")?;
    let operands = columns.operands(state.instruction_id);

    check_span_requirement(operation, columns, state.instruction_id)?;

    let usage_context = OperandUsageContext {
        block_id: state.block.identifier,
        instruction_index: state.instruction_index,
        dominance: context.dominance,
        definitions: &verification_state.definitions,
    };
    check_operands_dominance(operands, &usage_context)?;

    let result_type = check_instruction_types(
        operation,
        operands,
        |target_value| verification_state.value_types.get(&target_value).cloned(),
        context.module,
    )
    .map_err(|_| "IR.WELL-FORMEDNESS#R3")?;

    check_targets_and_calls(operands, context, &verification_state.value_types)?;

    if let (Some(result_value), Some(computed_type)) =
        (columns.result(state.instruction_id), result_type)
    {
        verification_state
            .value_types
            .insert(result_value, computed_type);
    }
    Ok(())
}

fn check_targets_and_calls(
    operands: &[Operand],
    context: &VerificationContext<'_>,
    value_types: &HashMap<ValueId, IrType>,
) -> Result<(), &'static str> {
    let block_context = BlockTargetContext {
        function: context.function,
        value_types,
        module: context.module,
    };
    check_block_targets(operands, &block_context)?;
    check_function_calls(operands, context.module, value_types)
}

fn record_instruction_result(
    context: &VerificationContext<'_>,
    state: &InstructionVerifyState<'_>,
    verification_state: &mut VerificationState,
) -> Result<(), &'static str> {
    let columns = &context.function.columns;
    if let Some(result_value) = columns.result(state.instruction_id) {
        let definition_position = state.instruction_index.saturating_add(1);
        if verification_state
            .definitions
            .insert(
                result_value,
                (Some(state.block.identifier), definition_position),
            )
            .is_some()
        {
            return Err("IR.WELL-FORMEDNESS#R2");
        }
    }
    Ok(())
}
