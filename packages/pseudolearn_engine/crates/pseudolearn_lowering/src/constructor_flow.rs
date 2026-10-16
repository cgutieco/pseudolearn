use crate::{expressions::ExpressionState, statement_context::StatementContext};
use pseudolearn_semantic::{
    expression_model::HirExpression,
    hir::{FunctionKind, HirFunction, HirModule},
    statement_model::HirStatement,
};

pub(crate) fn find(class: u32, module: &HirModule) -> Option<u32> {
    let mut current = usize::try_from(class).ok();
    for _ in 0..module.classes.len() {
        let class = module.classes.get(current?)?;
        if let Some(constructor) = class.constructor {
            return Some(constructor.0);
        }
        current = class
            .superclass
            .and_then(|parent| usize::try_from(parent.0).ok());
    }
    None
}

pub(crate) fn implicit_super(function: &HirFunction, context: &mut StatementContext<'_, '_>) {
    if function.kind != FunctionKind::Constructor {
        return;
    }
    let module = context.expression_context.module;
    if explicit_super(function, module) {
        return;
    }
    let parent = function
        .owner
        .and_then(|owner| usize::try_from(owner.0).ok())
        .and_then(|index| module.classes.get(index))
        .and_then(|class| class.superclass);
    let target = parent.and_then(|parent| find(parent.0, module));
    let Some(target) = target else {
        return;
    };
    let Some(receiver) = context.builder.receiver else {
        return;
    };
    let span = crate::spans::header_span(function.span, context.expression_context.source);
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    crate::expressions_objects::emit_call(target, receiver, Vec::new(), (false, span, &mut state));
}

fn explicit_super(function: &HirFunction, module: &HirModule) -> bool {
    let statement = function
        .body
        .first()
        .and_then(|identity| usize::try_from(identity.0).ok())
        .and_then(|index| module.statements.kinds.get(index));
    let Some(HirStatement::Call(expression)) = statement else {
        return false;
    };
    let expression = usize::try_from(expression.0)
        .ok()
        .and_then(|index| module.expressions.kinds.get(index));
    let Some(HirExpression::SuperCall {
        function: Some(target),
        ..
    }) = expression
    else {
        return false;
    };
    usize::try_from(target.0)
        .ok()
        .and_then(|index| module.functions.get(index))
        .is_some_and(|target| target.kind == FunctionKind::Constructor)
}
