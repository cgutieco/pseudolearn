use crate::abi_signatures::Entry;
use crate::error::CodegenError;
use crate::lowering::Lowering;
use crate::runtime_calls::{RuntimeCall, call_runtime};
use cranelift_codegen::ir::{InstBuilder, types};
use pseudolearn_ir::Operation;

pub(crate) fn enter(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    let has_cells = lowering
        .function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .any(|instruction| {
            matches!(
                lowering.function.columns.operation(*instruction),
                Some(Operation::CellLocal | Operation::CellElement | Operation::CellField)
            )
        });
    if has_cells {
        let word = call_runtime(
            lowering,
            &RuntimeCall {
                target: Entry::CellMark,
                code_name: "internalFault",
                span: None,
                operands: &[],
            },
        )?;
        lowering.cell_frame = Some(lowering.builder.ins().ireduce(types::I32, word));
    }
    Ok(())
}

pub(crate) fn leave(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    if let Some(base) = lowering.cell_frame {
        call_runtime(
            lowering,
            &RuntimeCall {
                target: Entry::CellRelease,
                code_name: "internalFault",
                span: None,
                operands: &[base],
            },
        )?;
    }
    Ok(())
}
