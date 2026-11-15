#![forbid(unsafe_code)]

use crate::assignability::assignable;

use crate::dominance::DominatorTree;
use crate::identities::{BlockId, ValueId};
use crate::model::{Function, Module};
use crate::operand::Operand;
use crate::types::IrType;
use std::collections::HashMap;

pub struct OperandUsageContext<'context> {
    pub block_id: BlockId,
    pub instruction_index: usize,
    pub dominance: &'context DominatorTree,
    pub definitions: &'context HashMap<ValueId, (Option<BlockId>, usize)>,
}

pub fn check_operands_dominance(
    operands: &[Operand],
    usage_context: &OperandUsageContext<'_>,
) -> Result<(), &'static str> {
    for operand in operands {
        match operand {
            Operand::Value(value) => {
                check_value_dominance(*value, usage_context)?;
            }
            Operand::BlockTarget { arguments, .. } | Operand::FunctionTarget { arguments, .. } => {
                for argument in arguments {
                    check_value_dominance(*argument, usage_context)?;
                }
            }
            _ => {}
        }
    }
    Ok(())
}

fn check_value_dominance(
    value: ValueId,
    usage_context: &OperandUsageContext<'_>,
) -> Result<(), &'static str> {
    let &(definition_block_option, defined_position) = usage_context
        .definitions
        .get(&value)
        .ok_or("IR.WELL-FORMEDNESS#R2")?;
    let Some(definition_block) = definition_block_option else {
        return Ok(());
    };
    if definition_block == usage_context.block_id {
        if defined_position <= usage_context.instruction_index {
            Ok(())
        } else {
            Err("IR.WELL-FORMEDNESS#R2")
        }
    } else if usage_context
        .dominance
        .dominates_block(definition_block, usage_context.block_id)
    {
        Ok(())
    } else {
        Err("IR.WELL-FORMEDNESS#R2")
    }
}

pub fn check_block_targets(
    operands: &[Operand],
    context: &BlockTargetContext<'_>,
) -> Result<(), &'static str> {
    for operand in operands {
        if let Operand::BlockTarget {
            target_block,
            arguments,
        } = operand
        {
            verify_block_target(*target_block, arguments, context)?;
        }
    }
    Ok(())
}

pub struct BlockTargetContext<'context> {
    pub function: &'context Function,
    pub value_types: &'context HashMap<ValueId, IrType>,
    pub module: &'context Module,
}

fn verify_block_target(
    target_block: BlockId,
    arguments: &[ValueId],
    context: &BlockTargetContext<'_>,
) -> Result<(), &'static str> {
    let target = context
        .function
        .block(target_block)
        .ok_or("IR.WELL-FORMEDNESS#R5")?;
    if target.parameters.len() != arguments.len() {
        return Err("IR.WELL-FORMEDNESS#R5");
    }
    for (argument_value, (_, parameter_type)) in arguments.iter().zip(&target.parameters) {
        let argument_type = context
            .value_types
            .get(argument_value)
            .ok_or("IR.WELL-FORMEDNESS#R5")?;
        if !assignable(context.module, argument_type, parameter_type) {
            return Err("IR.WELL-FORMEDNESS#R5");
        }
    }
    Ok(())
}

pub fn check_function_calls(
    operands: &[Operand],
    module: &Module,
    value_types: &HashMap<ValueId, IrType>,
) -> Result<(), &'static str> {
    for operand in operands {
        if let Operand::FunctionTarget {
            function_name,
            arguments,
        } = operand
        {
            verify_function_call(function_name, arguments, module, value_types)?;
        }
    }
    Ok(())
}

fn verify_function_call(
    function_name: &str,
    arguments: &[ValueId],
    module: &Module,
    value_types: &HashMap<ValueId, IrType>,
) -> Result<(), &'static str> {
    let target_function = module
        .find_function(function_name)
        .ok_or("IR.WELL-FORMEDNESS#R8")?;
    if target_function.parameters.len() != arguments.len() {
        return Err("IR.WELL-FORMEDNESS#R8");
    }
    for (argument_value, (_, parameter_type)) in arguments.iter().zip(&target_function.parameters) {
        let argument_type = value_types
            .get(argument_value)
            .ok_or("IR.WELL-FORMEDNESS#R8")?;
        if !assignable(module, argument_type, parameter_type) {
            return Err("IR.WELL-FORMEDNESS#R8");
        }
    }
    Ok(())
}
