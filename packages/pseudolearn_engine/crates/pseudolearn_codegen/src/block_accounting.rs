#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::lowering::{Lowering, guard_trap};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{InstBuilder, MemFlagsData, types};
use pseudolearn_ir::{Block, IrSpan, Operation};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum StatementCharging {
    Disabled,
    PerBlock,
    PerStatement,
}

pub(crate) fn charge_block_mass(
    lowering: &mut Lowering<'_, '_>,
    block: &Block,
) -> Result<(), CodegenError> {
    if lowering.environment.charging != StatementCharging::PerBlock {
        return Ok(());
    }
    let span = first_statement_span(lowering, block);
    charge_units(lowering, block.mass, span)
}

pub(crate) fn charge_statement(
    lowering: &mut Lowering<'_, '_>,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    if lowering.environment.charging != StatementCharging::PerStatement {
        return Ok(());
    }
    charge_units(lowering, 1, span)
}

fn charge_units(
    lowering: &mut Lowering<'_, '_>,
    units: u32,
    span: Option<IrSpan>,
) -> Result<(), CodegenError> {
    if units == 0 {
        return Ok(());
    }
    let offset = lowering.environment.layout.instruction_remaining;
    let context = lowering.context;
    let remaining =
        lowering
            .builder
            .ins()
            .load(types::I64, MemFlagsData::trusted(), context, offset);
    let updated = lowering
        .builder
        .ins()
        .iadd_imm_s(remaining, i64::from(units).saturating_neg());
    lowering
        .builder
        .ins()
        .store(MemFlagsData::trusted(), updated, context, offset);
    let exhausted = lowering
        .builder
        .ins()
        .icmp_imm_s(IntCC::SignedLessThan, updated, 0);
    guard_trap(lowering, exhausted, "statementBudgetExhausted", span)
}

fn first_statement_span(lowering: &Lowering<'_, '_>, block: &Block) -> Option<IrSpan> {
    let columns = &lowering.function.columns;
    block
        .instructions
        .iter()
        .find(|identifier| columns.operation(**identifier) == Some(Operation::StmtEnter))
        .and_then(|identifier| columns.span(*identifier))
}
