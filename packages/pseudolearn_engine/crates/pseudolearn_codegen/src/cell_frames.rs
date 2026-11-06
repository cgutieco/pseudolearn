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
        let mark = lowering.builder.ins().ireduce(types::I32, word);
        lowering.cell_frame = Some(mark);
        if lowering.variables.is_some() {
            let variable = lowering.builder.declare_var(types::I32);
            lowering.builder.def_var(variable, mark);
            lowering.cell_frame_variable = Some(variable);
        }
    }
    Ok(())
}

pub(crate) fn leave(lowering: &mut Lowering<'_, '_>) -> Result<(), CodegenError> {
    let current = lowering
        .cell_frame_variable
        .map(|variable| lowering.builder.use_var(variable))
        .or(lowering.cell_frame);
    if let Some(base) = current {
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
