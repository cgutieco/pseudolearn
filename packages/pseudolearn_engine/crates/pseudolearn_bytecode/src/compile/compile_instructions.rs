#![forbid(unsafe_code)]

use std::collections::BTreeMap;

use pseudolearn_ir::identities::InstructionId;
use pseudolearn_ir::{Block, Function, Operation};

use crate::Opcode;
use crate::error::BytecodeError;
use crate::model::{BasicBlock, BytecodeOperand, CodeVariant, Instruction, ReturnPoint};

use super::{FunctionPlan, InstructionPlan, compile_constants, compile_operands, register_for};

#[derive(Clone, Copy)]
struct InstructionPosition {
    identifier: InstructionId,
    program_counter: u32,
    fast: bool,
}

pub(super) fn append_block(
    plan: &mut FunctionPlan<'_>,
    block: &Block,
    variant: &mut CodeVariant,
    fast: bool,
) -> Result<(), BytecodeError> {
    let start_pc =
        u32::try_from(variant.instructions.len()).map_err(|_| BytecodeError::InvalidModule)?;
    let parameters = block
        .parameters
        .iter()
        .map(|(value, _)| register_for(&plan.registers, *value))
        .collect::<Result<Vec<_>, _>>()?;
    let event_mass = calculate_event_mass(plan, &block.instructions, fast)?;
    variant.blocks.push(BasicBlock {
        identifier: block.identifier,
        start_pc,
        parameters,
        mass: block.mass,
        event_mass,
    });
    for identifier in &block.instructions {
        append_instruction(plan, *identifier, variant, fast)?;
    }
    Ok(())
}

fn calculate_event_mass(
    plan: &FunctionPlan<'_>,
    instructions: &[InstructionId],
    fast: bool,
) -> Result<u32, BytecodeError> {
    if fast {
        return Ok(0);
    }
    let count = instructions
        .iter()
        .filter(|id| {
            plan.source
                .columns
                .operation(**id)
                .map(is_observation)
                .unwrap_or(false)
        })
        .count();
    u32::try_from(count).map_err(|_| BytecodeError::InvalidModule)
}

fn append_instruction(
    plan: &mut FunctionPlan<'_>,
    identifier: pseudolearn_ir::InstructionId,
    variant: &mut CodeVariant,
    fast: bool,
) -> Result<(), BytecodeError> {
    if omit_instruction(plan, identifier, fast)? {
        return Ok(());
    }
    let program_counter =
        u32::try_from(variant.instructions.len()).map_err(|_| BytecodeError::InvalidModule)?;
    let instruction = compile_instruction(plan, identifier, program_counter, fast)?;
    variant.definitions.insert(
        program_counter,
        crate::definitions::operands(
            plan.source,
            plan.source.columns.operands(identifier),
            &plan.registers,
        )?,
    );
    variant.instructions.push(instruction);
    Ok(())
}

fn omit_instruction(
    plan: &FunctionPlan<'_>,
    identifier: InstructionId,
    fast: bool,
) -> Result<bool, BytecodeError> {
    let operation = plan
        .source
        .columns
        .operation(identifier)
        .ok_or(BytecodeError::UnsupportedOperation)?;
    if fast && is_observation(operation) {
        return Ok(true);
    }
    Ok(plan
        .source
        .columns
        .result(identifier)
        .is_some_and(|result| {
            compile_constants::can_elide(result, &plan.constants_by_value, &plan.register_values)
        }))
}

fn compile_instruction(
    plan: &mut FunctionPlan<'_>,
    identifier: pseudolearn_ir::InstructionId,
    program_counter: u32,
    fast: bool,
) -> Result<Instruction, BytecodeError> {
    let operation = plan
        .source
        .columns
        .operation(identifier)
        .ok_or(BytecodeError::UnsupportedOperation)?;
    let opcode =
        Opcode::from_name(operation.as_str()).ok_or(BytecodeError::UnsupportedOperation)?;
    let destination = plan
        .source
        .columns
        .result(identifier)
        .map(|value| register_for(&plan.registers, value))
        .transpose()?;
    let operands = compile_instruction_operands(plan, identifier, operation)?;
    let return_point = add_return_point(
        operation,
        InstructionPosition {
            identifier,
            program_counter,
            fast,
        },
        plan,
    )?;
    Ok(Instruction {
        opcode,
        destination,
        operands,
        span: plan.source.columns.span(identifier),
        return_point,
    })
}

fn compile_instruction_operands(
    plan: &mut FunctionPlan<'_>,
    identifier: InstructionId,
    operation: Operation,
) -> Result<Vec<BytecodeOperand>, BytecodeError> {
    let mut instruction_plan = InstructionPlan {
        function_names: plan.function_names,
        registers: &plan.registers,
        constants_by_value: &plan.constants_by_value,
        constants: &mut plan.constants,
        allow_immediate: compile_constants::supports_immediate(operation),
    };
    let operands = plan
        .source
        .columns
        .operands(identifier)
        .iter()
        .map(|operand| compile_operands::compile_operand(&mut instruction_plan, operand))
        .collect::<Result<Vec<_>, _>>()?;
    Ok(operands)
}

fn add_return_point(
    operation: Operation,
    position: InstructionPosition,
    plan: &mut FunctionPlan<'_>,
) -> Result<Option<u32>, BytecodeError> {
    if !matches!(operation, Operation::Call | Operation::CallVirtual) {
        return Ok(None);
    }
    let identifier = plan
        .return_point_ids
        .get(&position.identifier)
        .copied()
        .ok_or(BytecodeError::InvalidModule)?;
    let continuation_pc = position
        .program_counter
        .checked_add(1)
        .ok_or(BytecodeError::InvalidModule)?;
    let locations = if position.fast {
        &mut plan.fast_return_points
    } else {
        &mut plan.probed_return_points
    };
    locations.insert(identifier, (position.program_counter, continuation_pc));
    Ok(Some(identifier))
}

pub(super) fn return_point_ids(
    function: &Function,
) -> Result<BTreeMap<InstructionId, u32>, BytecodeError> {
    let mut identifiers = BTreeMap::new();
    let mut next_identifier = 0_u32;
    for block in &function.blocks {
        for instruction_id in &block.instructions {
            let operation = function
                .columns
                .operation(*instruction_id)
                .ok_or(BytecodeError::UnsupportedOperation)?;
            if matches!(operation, Operation::Call | Operation::CallVirtual) {
                identifiers.insert(*instruction_id, next_identifier);
                next_identifier = next_identifier
                    .checked_add(1)
                    .ok_or(BytecodeError::InvalidModule)?;
            }
        }
    }
    Ok(identifiers)
}

pub(super) fn return_points(plan: &FunctionPlan<'_>) -> Result<Vec<ReturnPoint>, BytecodeError> {
    let mut points = Vec::with_capacity(plan.return_point_ids.len());
    for identifier in
        0..u32::try_from(plan.return_point_ids.len()).map_err(|_| BytecodeError::InvalidModule)?
    {
        let (fast_program_counter, fast_continuation_pc) = plan
            .fast_return_points
            .get(&identifier)
            .copied()
            .ok_or(BytecodeError::InvalidModule)?;
        let (probed_program_counter, probed_continuation_pc) = plan
            .probed_return_points
            .get(&identifier)
            .copied()
            .ok_or(BytecodeError::InvalidModule)?;
        points.push(ReturnPoint {
            identifier,
            function_index: plan.function_index,
            fast_program_counter,
            fast_continuation_pc,
            probed_program_counter,
            probed_continuation_pc,
        });
    }
    Ok(points)
}

fn is_observation(operation: Operation) -> bool {
    matches!(
        operation,
        Operation::StmtEnter
            | Operation::StmtExit
            | Operation::DecideBool
            | Operation::DecideCase
            | Operation::DecideDefault
            | Operation::DecideNone
    )
}
