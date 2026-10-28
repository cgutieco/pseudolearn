use crate::expression_model::HirExpression;
use crate::function_model::HirClosure;
use crate::hir::{FunctionKind, HirFunction};
use crate::identities::{ExpressionId, FunctionId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;

pub(crate) fn reference(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    node: usize,
) -> ExpressionId {
    if crate::suspension_checker::value(session, (function, node)) {
        return crate::expression_checker::invalid(session, node);
    }
    let signature = crate::function_types::signature(session, function);
    let kind = crate::function_types::intern(session, signature, node);
    let wrapper = if let Some(wrapper) = session.module.function_values.get(&function) {
        *wrapper
    } else {
        create_wrapper(session, function, node)
    };
    session.called.insert(function);
    session.called.insert(wrapper);
    session.emit(
        HirExpression::FunctionValue(wrapper),
        kind,
        session.span(node),
    )
}

fn create_wrapper(
    session: &mut AnalysisSession<'_>,
    original: FunctionId,
    node: usize,
) -> FunctionId {
    let Some(function) = crate::hierarchy::function(session, original).cloned() else {
        return original;
    };
    let wrapper = FunctionId(u32::try_from(session.module.functions.len()).unwrap_or(u32::MAX));
    session.tag_function();
    session.module.functions.push(HirFunction {
        name: format!("$functionValue{}", original.0),
        kind: FunctionKind::Function,
        owner: None,
        parameters: Vec::new(),
        result: function.result,
        body: Vec::new(),
        span: session.span(node),
        closing_span: session.span(node),
        syntax: node,
        private: true,
        suspendible: false,
    });
    let parent = std::mem::replace(&mut session.current, wrapper);
    let environment = fill_wrapper(session, &function, original, node);
    session.module.closures.insert(
        wrapper,
        HirClosure {
            environment,
            class: None,
            captures: Vec::new(),
            offsets: Vec::new(),
            layout: pseudolearn_abi::ClosureLayout::from_captures(&[]).ok(),
        },
    );
    session.module.function_values.insert(original, wrapper);
    session.current = parent;
    wrapper
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    original: &[crate::identities::LocalId],
    parameters: &mut Vec<crate::identities::LocalId>,
) -> Vec<ExpressionId> {
    let mut arguments = Vec::new();
    for parameter in original {
        let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .cloned()
        else {
            continue;
        };
        let copy = crate::closure_locals::create(session, local.name, local.type_id, true);
        if let Some(parameter) = usize::try_from(copy.0)
            .ok()
            .and_then(|index| session.module.locals.get_mut(index))
        {
            parameter.passing = local.passing;
        }
        session.reads.insert(copy);
        parameters.push(copy);
        arguments.push(session.emit(HirExpression::Local(copy), local.type_id, local.span));
    }
    arguments
}

fn fill_wrapper(
    session: &mut AnalysisSession<'_>,
    function: &HirFunction,
    original: FunctionId,
    node: usize,
) -> crate::identities::LocalId {
    let wrapper = session.current;
    let reference = session.module.types.intern(Type::String);
    let environment =
        crate::closure_locals::create(session, "$environment".to_owned(), reference, true);
    let mut parameters = vec![environment];
    let arguments = arguments(session, &function.parameters, &mut parameters);
    let call = session.emit(
        HirExpression::Call {
            function: original,
            arguments,
        },
        function.result,
        session.span(node),
    );
    let mut body = Vec::new();
    if session.module.types.get(function.result) == Type::Unit {
        body.push(session.statement(HirStatement::Call(call), session.span(node)));
        body.push(session.statement(HirStatement::Return(None), session.span(node)));
    } else {
        body.push(session.statement(HirStatement::Return(Some(call)), session.span(node)));
    }
    if let Some(function) = usize::try_from(wrapper.0)
        .ok()
        .and_then(|index| session.module.functions.get_mut(index))
    {
        function.parameters = parameters;
        function.body = body;
    }
    environment
}
