#![forbid(unsafe_code)]

use crate::block_accounting::charge_statement;
use crate::definition::flag_of;
use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, guard_trap, jump_to_trap, operand_value};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{Block, BlockArg, InstBuilder, MemFlagsData, types};
use pseudolearn_ir::{BlockId, IrType, Operand, Operation, ValueId};

pub(crate) const OPERATIONS: &[Operation] = &[
    Operation::StmtEnter,
    Operation::StmtExit,
    Operation::DecideBool,
    Operation::DecideCase,
    Operation::DecideDefault,
    Operation::DecideNone,
    Operation::LoopCheckStep,
    Operation::Jump,
    Operation::Branch,
    Operation::Return,
    Operation::TrapMissingReturn,
    Operation::Unreachable,
];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    match instruction.operation {
        Operation::StmtEnter => charge_statement(lowering, instruction.span),
        Operation::LoopCheckStep => {
            let step = operand_value(lowering, instruction, 0)?;
            let is_zero = lowering.builder.ins().icmp_imm_s(IntCC::Equal, step, 0);
            guard_trap(lowering, is_zero, "zeroStepInCountedLoop", instruction.span)
        }
        Operation::Jump => lower_jump(lowering, instruction),
        Operation::Branch => lower_branch(lowering, instruction),
        Operation::Return => lower_return(lowering, instruction),
        Operation::TrapMissingReturn => {
            jump_to_trap(lowering, "subroutineEndedWithoutReturn", instruction.span)
        }
        Operation::Unreachable => jump_to_trap(lowering, "internalFault", instruction.span),
        _ => Ok(()),
    }
}

pub(crate) fn target_of(
    lowering: &mut Lowering<'_, '_>,
    operand: Option<&Operand>,
) -> Result<(Block, Vec<BlockArg>), CodegenError> {
    let Some(Operand::BlockTarget {
        target_block,
        arguments,
    }) = operand
    else {
        return Err(CodegenError::InvalidModule("branch without block target"));
    };
    let block = block_of(lowering, *target_block)?;
    Ok((block, block_arguments(lowering, *target_block, arguments)))
}

fn block_of(lowering: &Lowering<'_, '_>, identifier: BlockId) -> Result<Block, CodegenError> {
    lowering
        .blocks
        .get(&identifier)
        .copied()
        .ok_or(CodegenError::InvalidModule("unknown block target"))
}

fn block_arguments(
    lowering: &mut Lowering<'_, '_>,
    target: BlockId,
    arguments: &[ValueId],
) -> Vec<BlockArg> {
    let function = lowering.function;
    let mut passed: Vec<BlockArg> = arguments
        .iter()
        .filter_map(|identifier| lowering.values.get(identifier))
        .map(|value| BlockArg::Value(*value))
        .collect();
    let parameters = function
        .block(target)
        .map(|block| block.parameters.as_slice())
        .unwrap_or_default();
    for ((_, parameter_type), source) in parameters.iter().zip(arguments) {
        if *parameter_type == IrType::I64 {
            passed.push(BlockArg::Value(flag_of(lowering, *source)));
        }
    }
    passed
}

fn lower_jump(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let (block, arguments) = target_of(lowering, instruction.operands.first())?;
    lowering.builder.ins().jump(block, &arguments);
    Ok(())
}

fn lower_branch(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let condition = operand_value(lowering, instruction, 0)?;
    let (then_block, then_arguments) = target_of(lowering, instruction.operands.get(1))?;
    let (else_block, else_arguments) = target_of(lowering, instruction.operands.get(2))?;
    lowering.builder.ins().brif(
        condition,
        then_block,
        &then_arguments,
        else_block,
        &else_arguments,
    );
    Ok(())
}

fn lower_return(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    crate::cell_frames::leave(lowering)?;
    let offset = lowering.environment.layout.frame_depth;
    let context = lowering.context;
    let depth = lowering
        .builder
        .ins()
        .load(types::I32, MemFlagsData::trusted(), context, offset);
    let released = lowering.builder.ins().iadd_imm_s(depth, -1);
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), released, context, offset);
    if instruction.operands.is_empty() {
        lowering.builder.ins().return_(&[]);
    } else {
        let value = operand_value(lowering, instruction, 0)?;
        lowering.builder.ins().return_(&[value]);
    }
    Ok(())
}
