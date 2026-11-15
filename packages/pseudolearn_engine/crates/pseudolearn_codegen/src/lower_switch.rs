use crate::error::CodegenError;
use crate::lowering::{Instruction, Lowering, operand_value};
use cranelift_codegen::ir::{Block, InstBuilder};
use cranelift_frontend::Switch;
use pseudolearn_ir::{Operand, Operation};

pub(crate) const OPERATIONS: &[Operation] = &[Operation::Switch];

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let selector = operand_value(lowering, instruction, 0)?;
    let default = target(lowering, instruction.operands.get(1))?;
    let mut switch = Switch::new();
    for pair in instruction
        .operands
        .get(2..)
        .ok_or(CodegenError::InvalidModule("switch without targets"))?
        .as_chunks::<2>()
        .0
        .iter()
    {
        let Some(Operand::LiteralI64(ordinal)) = pair.first() else {
            return Err(CodegenError::InvalidModule("switch without ordinal"));
        };
        let ordinal = u128::try_from(*ordinal)
            .map_err(|_| CodegenError::InvalidModule("negative switch ordinal"))?;
        let block = target(lowering, pair.get(1))?;
        switch.set_entry(ordinal, block);
    }
    switch.emit(&mut lowering.builder, selector, default);
    Ok(())
}

fn target(
    lowering: &mut Lowering<'_, '_>,
    operand: Option<&Operand>,
) -> Result<Block, CodegenError> {
    let (target, arguments) = crate::lower_control::target_of(lowering, operand)?;
    if arguments.is_empty() {
        return Ok(target);
    }
    let current = lowering
        .builder
        .current_block()
        .ok_or(CodegenError::InvalidModule("switch without block"))?;
    let bridge = lowering.builder.create_block();
    lowering.builder.switch_to_block(bridge);
    lowering.builder.ins().jump(target, &arguments);
    lowering.builder.switch_to_block(current);
    Ok(bridge)
}
