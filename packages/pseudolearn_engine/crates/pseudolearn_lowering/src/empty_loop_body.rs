#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use pseudolearn_ir::{IrSpan, Operation};
use pseudolearn_semantic::identities::StatementId;

pub(crate) fn charge_iteration(
    body: &[StatementId],
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) {
    if !body.is_empty() {
        return;
    }
    builder.emit_void(Operation::StmtEnter, vec![], span);
    builder.emit_void(Operation::StmtExit, vec![], span);
}
