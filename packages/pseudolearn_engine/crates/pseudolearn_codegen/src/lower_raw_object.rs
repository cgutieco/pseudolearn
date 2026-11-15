use crate::error::CodegenError;
use crate::inline_memory::{clif_load, heap_base};
use crate::lowering::{Instruction, Lowering, bind_result, operand_value};
use cranelift_codegen::ir::{InstBuilder, MemFlagsData};

pub(crate) fn lower(
    lowering: &mut Lowering<'_, '_>,
    instruction: &Instruction<'_>,
) -> Result<(), CodegenError> {
    let target = crate::lower_objects::field_target(lowering, instruction)?;
    let object = operand_value(lowering, instruction, 0)?;
    let absent = lowering.builder.ins().icmp_imm_s(
        cranelift_codegen::ir::condcodes::IntCC::Equal,
        object,
        0,
    );
    crate::lowering::guard_trap(
        lowering,
        absent,
        "uninitializedVariableRead",
        instruction.span,
    )?;
    let (_, base) = heap_base(lowering, object);
    let (_, address) = crate::lower_objects::payload_slot(lowering, base, &target);
    let value = lowering.builder.ins().load(
        clif_load(&target.field_type),
        MemFlagsData::trusted(),
        address,
        0,
    );
    bind_result(lowering, instruction, value);
    Ok(())
}
