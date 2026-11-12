use crate::expressions::ExpressionState;
use pseudolearn_ir::{BlockId, Operand, Operation};

pub(crate) fn prepare(state: &mut ExpressionState<'_, '_>, span: Option<pseudolearn_ir::IrSpan>) {
    let original = state.builder.current_block;
    let cancelled = state.builder.create_block();
    state
        .builder
        .emit_void(Operation::TaskCancelPoint, vec![target(cancelled)], None);
    state.builder.set_current_block(cancelled);
    let mut environment = state.environment.clone();
    crate::task_scopes::emit_active_scope_joins(0, span, state.builder);
    crate::cleanup_edges::emit(state.context, &mut environment, state.builder, 0);
    state.builder.emit_void(Operation::Return, Vec::new(), span);
    state.builder.current_block = original;
    for (scope, exit, depth) in state.builder.scope_exits.clone() {
        let aborted = state.builder.create_block();
        state.builder.emit_void(
            Operation::TaskScopeBoundary,
            vec![Operand::Value(scope), target(aborted)],
            None,
        );
        state.builder.set_current_block(aborted);
        let mut environment = state.environment.clone();
        let scope_depth = state
            .builder
            .task_scopes
            .iter()
            .position(|active| *active == scope)
            .unwrap_or(0);
        crate::task_scopes::emit_active_scope_joins(scope_depth, span, state.builder);
        crate::cleanup_edges::emit(state.context, &mut environment, state.builder, depth);
        state
            .builder
            .emit_void(Operation::Jump, vec![target(exit)], None);
        state.builder.current_block = original;
    }
}

pub(crate) fn target(block: BlockId) -> Operand {
    Operand::BlockTarget {
        target_block: block,
        arguments: Vec::new(),
    }
}
