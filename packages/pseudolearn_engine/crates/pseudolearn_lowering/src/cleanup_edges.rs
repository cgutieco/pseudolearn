use crate::builder::{FunctionBuilder, is_current_block_terminated};
use crate::environment::VariableEnvironment;
use crate::expressions::ExpressionContext;
use crate::statement_context::StatementContext;
use pseudolearn_semantic::StatementId;

#[derive(Clone, Debug, Default, PartialEq)]
pub struct CleanupScopes {
    pub scopes: Vec<Vec<Vec<StatementId>>>,
    pub origins: Vec<pseudolearn_ir::OriginEntry>,
}

pub(crate) fn emit(
    context: &ExpressionContext<'_>,
    environment: &mut VariableEnvironment,
    builder: &mut FunctionBuilder,
    depth: usize,
) {
    let cleanups: Vec<_> = builder
        .cleanup
        .scopes
        .iter()
        .skip(depth)
        .rev()
        .flat_map(|scope| scope.iter().rev().cloned())
        .collect();
    let mut origins = Vec::new();
    for body in cleanups {
        let mut statements = StatementContext {
            expression_context: context,
            environment,
            builder,
            origins: &mut origins,
        };
        crate::statements::lower_statement_list(&body, &mut statements);
    }
    builder.cleanup.origins.extend(origins);
}

pub(crate) fn finish(context: &mut StatementContext<'_, '_>) {
    let depth = context.builder.cleanup.scopes.len().saturating_sub(1);
    if !is_current_block_terminated(context.builder) {
        emit(
            context.expression_context,
            context.environment,
            context.builder,
            depth,
        );
    }
    context.builder.cleanup.scopes.pop();
}

pub(crate) fn return_from(
    context: &mut StatementContext<'_, '_>,
    span: Option<pseudolearn_ir::IrSpan>,
    operands: Vec<pseudolearn_ir::Operand>,
) {
    let operands = snapshot_operands(context, span, operands);
    emit(
        context.expression_context,
        context.environment,
        context.builder,
        0,
    );
    context
        .builder
        .emit_void(pseudolearn_ir::Operation::StmtExit, Vec::new(), span);
    context
        .builder
        .emit_void(pseudolearn_ir::Operation::Return, operands, span);
}

fn snapshot_operands(
    context: &mut StatementContext<'_, '_>,
    span: Option<pseudolearn_ir::IrSpan>,
    operands: Vec<pseudolearn_ir::Operand>,
) -> Vec<pseudolearn_ir::Operand> {
    let has_cleanup = context
        .builder
        .cleanup
        .scopes
        .iter()
        .any(|scope| !scope.is_empty());
    if !has_cleanup {
        return operands;
    }
    operands
        .into_iter()
        .map(|operand| match operand {
            pseudolearn_ir::Operand::Value(value) => {
                let snapshot = context.builder.next_value();
                context.builder.emit_with_target(
                    pseudolearn_ir::Operation::ValueRequire,
                    vec![pseudolearn_ir::Operand::Value(value)],
                    (Some(snapshot), span),
                );
                pseudolearn_ir::Operand::Value(snapshot)
            }
            other => other,
        })
        .collect()
}
