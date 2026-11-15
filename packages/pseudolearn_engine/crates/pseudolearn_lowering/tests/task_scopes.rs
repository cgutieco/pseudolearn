#![forbid(unsafe_code)]

use pseudolearn_ir::verify_module;
use pseudolearn_lowering::lower_module;
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::hir::{FunctionKind, HirFunction, HirModule};
use pseudolearn_semantic::identities::{ExpressionId, FunctionId, StatementId};
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

#[test]
fn lowers_empty_and_nested_task_scopes() {
    let mut module = HirModule::default();
    let unit = module.types.intern(Type::Unit);
    module.statements.kinds.push(HirStatement::TaskScope {
        failure: None,
        body: vec![StatementId(1)],
    });
    module.statements.kinds.push(HirStatement::TaskScope {
        failure: None,
        body: Vec::new(),
    });
    module.statements.spans.resize(2, Span::new(0, 1));
    module.functions.push(function(
        FunctionKind::Main,
        "main",
        unit,
        vec![StatementId(0)],
    ));

    let source = SourceText::new("x".to_owned());
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    if let Ok(lowered) = lowered {
        assert_eq!(verify_module(&lowered), Ok(()));
    }
}

#[test]
fn lowers_a_spawned_call_inside_a_scope() {
    let mut module = HirModule::default();
    let unit = module.types.intern(Type::Unit);
    let task = module.types.intern(Type::Task(unit));
    module.expressions.kinds.push(HirExpression::TaskSpawn {
        function: FunctionId(1),
        arguments: Vec::new(),
    });
    module.expressions.types.push(task);
    module.expressions.spans.push(Span::new(0, 1));
    module
        .statements
        .kinds
        .push(HirStatement::Spawn(ExpressionId(0)));
    module.statements.spans.push(Span::new(0, 1));
    module.statements.kinds.push(HirStatement::TaskScope {
        failure: None,
        body: vec![StatementId(0)],
    });
    module.statements.spans.push(Span::new(0, 1));
    let mut main = function(FunctionKind::Main, "main", unit, vec![StatementId(1)]);
    main.suspendible = true;
    module.functions.push(main);
    let mut child = function(FunctionKind::Procedure, "work", unit, Vec::new());
    child.suspendible = true;
    module.functions.push(child);

    let source = SourceText::new("x".to_owned());
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    if let Ok(lowered) = lowered {
        assert_eq!(verify_module(&lowered), Ok(()));
    }
}

fn function(
    kind: FunctionKind,
    name: &str,
    result: pseudolearn_semantic::identities::TypeId,
    body: Vec<StatementId>,
) -> HirFunction {
    HirFunction {
        kind,
        name: name.to_owned(),
        owner: None,
        parameters: Vec::new(),
        result,
        body,
        span: Span::new(0, 1),
        closing_span: Span::new(0, 1),
        syntax: 0,
        private: false,
        suspendible: false,
    }
}
