#![forbid(unsafe_code)]

use crate::error::{BytecodeError, VerificationRule};
use crate::model::{
    BasicBlock, BytecodeFunction, BytecodeModule, BytecodeOperand, CodeVariant, Instruction,
    Register,
};
use crate::verify_padding::{used_length, verify_padding};
use crate::verify_superinstructions::verify_superinstructions;

pub fn verify_bytecode(module: &BytecodeModule) -> Result<(), BytecodeError> {
    crate::class_verification::verify(module)?;
    for (index, function) in module.functions.iter().enumerate() {
        let function_index = u16::try_from(index).map_err(|_| BytecodeError::InvalidModule)?;
        verify_function(module, function, function_index)?;
    }
    Ok(())
}

fn verify_function(
    module: &BytecodeModule,
    function: &BytecodeFunction,
    function_index: u16,
) -> Result<(), BytecodeError> {
    verify_shared_layout(function)?;
    let context = FunctionContext {
        module,
        function,
        function_index,
    };
    verify_variant(&context, &function.fast, false)?;
    verify_variant(&context, &function.probed, true)
}

struct FunctionContext<'module> {
    module: &'module BytecodeModule,
    function: &'module BytecodeFunction,
    function_index: u16,
}

fn verify_variant(
    function_context: &FunctionContext<'_>,
    variant: &CodeVariant,
    probed: bool,
) -> Result<(), BytecodeError> {
    verify_padding(variant)?;
    verify_superinstructions(variant)?;
    for block in &variant.blocks {
        verify_block(function_context.function, variant, block)?;
    }
    for (position, instruction) in variant.instructions.iter().enumerate() {
        let program_counter = u32::try_from(position).map_err(|_| BytecodeError::InvalidModule)?;
        let context = VerifyContext {
            module: function_context.module,
            function: function_context.function,
            variant,
            probed,
        };
        verify_instruction(&context, program_counter, instruction)?;
    }
    crate::roots::verify(function_context.function, variant)?;
    verify_return_points(
        function_context.function,
        function_context.function_index,
        variant,
        probed,
    )
}

fn verify_shared_layout(function: &BytecodeFunction) -> Result<(), BytecodeError> {
    if function.fast.blocks.len() != function.probed.blocks.len() {
        return Err(BytecodeError::InvalidModule);
    }
    if !function.probed.superinstructions.is_empty() {
        return Err(BytecodeError::Verification(
            VerificationRule::SuperInstruction,
        ));
    }
    for (fast, probed) in function.fast.blocks.iter().zip(&function.probed.blocks) {
        if fast.identifier != probed.identifier
            || fast.parameters != probed.parameters
            || fast.mass != probed.mass
        {
            return Err(BytecodeError::InvalidModule);
        }
    }
    Ok(())
}

fn verify_block(
    function: &BytecodeFunction,
    variant: &CodeVariant,
    block: &BasicBlock,
) -> Result<(), BytecodeError> {
    let start = usize::try_from(block.start_pc).map_err(|_| BytecodeError::InvalidModule)?;
    if start >= used_length(variant)? {
        return Err(BytecodeError::Verification(VerificationRule::FunctionJump));
    }
    for register in &block.parameters {
        verify_register(function, *register)?;
    }
    Ok(())
}

struct VerifyContext<'module> {
    module: &'module BytecodeModule,
    function: &'module BytecodeFunction,
    variant: &'module CodeVariant,
    probed: bool,
}

fn verify_instruction(
    context: &VerifyContext<'_>,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    if let Some(destination) = instruction.destination {
        verify_register(context.function, destination)?;
    }
    for operand in &instruction.operands {
        verify_operand(context, operand)?;
    }
    verify_return_point(context, program_counter, instruction)
}

fn verify_operand(
    context: &VerifyContext<'_>,
    operand: &BytecodeOperand,
) -> Result<(), BytecodeError> {
    match operand {
        BytecodeOperand::Register(register) => verify_register(context.function, *register),
        BytecodeOperand::BlockTarget { target, arguments } => {
            verify_block_target(context.function, context.variant, *target, arguments)
        }
        BytecodeOperand::FunctionTarget {
            function_index,
            arguments,
        } => verify_function_target(context.module, context.function, *function_index, arguments),
        BytecodeOperand::Constant(index) => verify_constant(context.function, *index),
        _ => Ok(()),
    }
}

fn verify_block_target(
    function: &BytecodeFunction,
    variant: &CodeVariant,
    target: pseudolearn_ir::BlockId,
    arguments: &[Register],
) -> Result<(), BytecodeError> {
    let block = variant
        .blocks
        .iter()
        .find(|block| block.identifier == target)
        .ok_or(BytecodeError::Verification(VerificationRule::FunctionJump))?;
    if block.parameters.len() != arguments.len() {
        return Err(BytecodeError::Verification(VerificationRule::ValueClass));
    }
    for (source, destination) in arguments.iter().zip(&block.parameters) {
        verify_register(function, *source)?;
        if source.class != destination.class {
            return Err(BytecodeError::Verification(VerificationRule::ValueClass));
        }
    }
    Ok(())
}

fn verify_function_target(
    module: &BytecodeModule,
    caller: &BytecodeFunction,
    function_index: u16,
    arguments: &[Register],
) -> Result<(), BytecodeError> {
    let target = module
        .functions
        .get(usize::from(function_index))
        .ok_or(BytecodeError::Verification(VerificationRule::FunctionJump))?;
    if target.parameters.len() != arguments.len() {
        return Err(BytecodeError::Verification(VerificationRule::ValueClass));
    }
    for (source, destination) in arguments.iter().zip(&target.parameters) {
        verify_register(caller, *source)?;
        if source.class != destination.class {
            return Err(BytecodeError::Verification(VerificationRule::ValueClass));
        }
    }
    Ok(())
}

fn verify_constant(function: &BytecodeFunction, index: u16) -> Result<(), BytecodeError> {
    if function.constants.get(usize::from(index)).is_some() {
        Ok(())
    } else {
        Err(BytecodeError::Verification(VerificationRule::OperandWindow))
    }
}

fn verify_register(function: &BytecodeFunction, register: Register) -> Result<(), BytecodeError> {
    if function.register_type(register).is_some() {
        Ok(())
    } else {
        Err(BytecodeError::Verification(VerificationRule::OperandWindow))
    }
}

fn verify_return_points(
    function: &BytecodeFunction,
    function_index: u16,
    variant: &CodeVariant,
    probed: bool,
) -> Result<(), BytecodeError> {
    for point in &function.return_points {
        let (call_pc, continuation_pc) = if probed {
            (point.probed_program_counter, point.probed_continuation_pc)
        } else {
            (point.fast_program_counter, point.fast_continuation_pc)
        };
        let instruction = variant
            .instructions
            .get(usize::try_from(call_pc).map_err(|_| BytecodeError::InvalidModule)?)
            .ok_or(BytecodeError::Verification(VerificationRule::ReturnPoint))?;
        if instruction.return_point != Some(point.identifier)
            || point.function_index != function_index
        {
            return Err(BytecodeError::Verification(VerificationRule::ReturnPoint));
        }
        let continuation = usize::try_from(continuation_pc)
            .map_err(|_| BytecodeError::Verification(VerificationRule::ReturnPoint))?;
        if continuation > used_length(variant)? {
            return Err(BytecodeError::Verification(VerificationRule::ReturnPoint));
        }
    }
    Ok(())
}

fn verify_return_point(
    context: &VerifyContext<'_>,
    program_counter: u32,
    instruction: &Instruction,
) -> Result<(), BytecodeError> {
    let is_call = matches!(instruction.opcode.as_name(), "call" | "call.virtual");
    if !is_call {
        return Ok(());
    }
    let identifier = instruction
        .return_point
        .ok_or(BytecodeError::Verification(VerificationRule::ReturnPoint))?;
    let matched = context.function.return_points.iter().any(|point| {
        let expected_pc = if context.probed {
            point.probed_program_counter
        } else {
            point.fast_program_counter
        };
        point.identifier == identifier && expected_pc == program_counter
    });
    if matched {
        Ok(())
    } else {
        Err(BytecodeError::Verification(VerificationRule::ReturnPoint))
    }
}
