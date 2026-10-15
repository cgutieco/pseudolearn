#![forbid(unsafe_code)]

use pseudolearn_ir::verify_module;
use pseudolearn_lowering::lower_module;
use pseudolearn_lowering::statements_while::collect_modified_locals;
use pseudolearn_semantic::expression_model::{HirExpression, HirPlace, Literal};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction, HirLocal, HirModule, Passing};
use pseudolearn_semantic::identities::{ExpressionId, LocalId, StatementId};
use pseudolearn_semantic::statement_model::{HirCase, HirStatement};
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

#[test]
fn lowers_procedural_write_statement() {
    let mut module = HirModule::default();
    let type_i64 = module.types.intern(Type::Integer);
    let type_unit = module.types.intern(Type::Unit);

    let literal_expression = HirExpression::Literal(Literal::Integer(42));
    let literal_expression_id = ExpressionId(0);
    module.expressions.kinds.push(literal_expression);
    module.expressions.types.push(type_i64);
    module.expressions.spans.push(Span::new(10, 20));

    let write_statement = HirStatement::Write {
        values: vec![literal_expression_id],
        newline: true,
    };
    let write_statement_id = StatementId(0);
    module.statements.kinds.push(write_statement);
    module.statements.spans.push(Span::new(5, 25));

    let function = HirFunction {
        kind: FunctionKind::Main,
        name: "main".to_owned(),
        owner: None,
        parameters: Vec::new(),
        result: type_unit,
        body: vec![write_statement_id],
        span: Span::new(0, 30),
        closing_span: Span::new(26, 30),
        syntax: 0,
        private: false,
    };
    module.functions.push(function);

    let source = SourceText::new("Algoritmo P\nEscribir 42;\nFinAlgoritmo\n".to_owned());
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    if let Ok(target_module) = lowered {
        assert_eq!(verify_module(&target_module), Ok(()));
        let main_function = target_module.find_function("main");
        assert!(main_function.is_some());
        if let Some(target_function) = main_function {
            assert_eq!(
                target_function.blocks.first().map(|block| block.mass),
                Some(1)
            );
        }
    }
}

#[test]
fn lowers_conditional_and_while_loop() {
    let mut module = HirModule::default();
    let type_i64 = module.types.intern(Type::Integer);
    let type_bool = module.types.intern(Type::Boolean);
    let type_unit = module.types.intern(Type::Unit);

    let local_variable = HirLocal {
        name: "counter".to_owned(),
        type_id: type_i64,
        passing: Passing::Value,
        span: Span::new(1, 5),
        scope: pseudolearn_semantic::identities::FunctionId(0),
        parameter: false,
    };
    module.locals.push(local_variable);
    let local_id = LocalId(0);

    let zero_expression = HirExpression::Literal(Literal::Integer(0));
    module.expressions.kinds.push(zero_expression);
    module.expressions.types.push(type_i64);
    module.expressions.spans.push(Span::new(10, 11));

    let initialize_statement = HirStatement::Assign {
        destination: HirPlace::Local(local_id),
        value: ExpressionId(0),
    };
    module.statements.kinds.push(initialize_statement);
    module.statements.spans.push(Span::new(8, 12));

    let condition_expression = HirExpression::Literal(Literal::Boolean(false));
    module.expressions.kinds.push(condition_expression);
    module.expressions.types.push(type_bool);
    module.expressions.spans.push(Span::new(20, 25));

    let while_statement = HirStatement::While {
        condition: ExpressionId(1),
        body: Vec::new(),
    };
    module.statements.kinds.push(while_statement);
    module.statements.spans.push(Span::new(15, 30));

    let function = HirFunction {
        kind: FunctionKind::Main,
        name: "main".to_owned(),
        owner: None,
        parameters: Vec::new(),
        result: type_unit,
        body: vec![StatementId(0), StatementId(1)],
        span: Span::new(0, 35),
        closing_span: Span::new(31, 35),
        syntax: 0,
        private: false,
    };
    module.functions.push(function);

    let source = SourceText::new("counter <- 0;\nMientras Falso Hacer\nFinMientras\n".to_owned());
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    if let Ok(target_module) = lowered {
        assert_eq!(verify_module(&target_module), Ok(()));
    }
}

#[test]
fn lowers_for_loop_and_switch_statement() {
    let mut module = HirModule::default();
    let type_i64 = module.types.intern(Type::Integer);
    let type_unit = module.types.intern(Type::Unit);

    let local_variable = HirLocal {
        name: "index".to_owned(),
        type_id: type_i64,
        passing: Passing::Value,
        span: Span::new(1, 5),
        scope: pseudolearn_semantic::identities::FunctionId(0),
        parameter: false,
    };
    module.locals.push(local_variable);
    let local_id = LocalId(0);

    let starting_expression = HirExpression::Literal(Literal::Integer(1));
    module.expressions.kinds.push(starting_expression);
    module.expressions.types.push(type_i64);
    module.expressions.spans.push(Span::new(10, 11));

    let ending_expression = HirExpression::Literal(Literal::Integer(3));
    module.expressions.kinds.push(ending_expression);
    module.expressions.types.push(type_i64);
    module.expressions.spans.push(Span::new(15, 16));

    let for_statement = HirStatement::For {
        control: local_id,
        initial: ExpressionId(0),
        ending: ExpressionId(1),
        step: None,
        body: Vec::new(),
    };
    module.statements.kinds.push(for_statement);
    module.statements.spans.push(Span::new(5, 20));

    let selector_expression = HirExpression::Local(local_id);
    module.expressions.kinds.push(selector_expression);
    module.expressions.types.push(type_i64);
    module.expressions.spans.push(Span::new(25, 30));

    let switch_statement = HirStatement::Switch {
        selector: ExpressionId(2),
        cases: vec![HirCase {
            labels: vec![ExpressionId(0)],
            body: Vec::new(),
        }],
        default: Vec::new(),
    };
    module.statements.kinds.push(switch_statement);
    module.statements.spans.push(Span::new(22, 35));

    let function = HirFunction {
        kind: FunctionKind::Main,
        name: "main".to_owned(),
        owner: None,
        parameters: Vec::new(),
        result: type_unit,
        body: vec![StatementId(0), StatementId(1)],
        span: Span::new(0, 40),
        closing_span: Span::new(36, 40),
        syntax: 0,
        private: false,
    };
    module.functions.push(function);

    let source = SourceText::new(
        "Para index <- 1 Hasta 3 Hacer\nFinPara\nSegun index Hacer\nFinSegun\n".to_owned(),
    );
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    if let Ok(target_module) = lowered {
        assert_eq!(verify_module(&target_module), Ok(()));
    }
}

#[test]
fn collects_loop_writes_nested_in_conditionals_switches_and_inner_loops() {
    let mut module = HirModule::default();
    module.statements.kinds = vec![
        HirStatement::Conditional {
            condition: ExpressionId(0),
            affirmative: vec![StatementId(1)],
            negative: vec![StatementId(2)],
        },
        HirStatement::Assign {
            destination: HirPlace::Local(LocalId(2)),
            value: ExpressionId(0),
        },
        HirStatement::Switch {
            selector: ExpressionId(0),
            cases: vec![HirCase {
                labels: vec![ExpressionId(0)],
                body: vec![StatementId(3)],
            }],
            default: vec![StatementId(4)],
        },
        HirStatement::Assign {
            destination: HirPlace::Local(LocalId(0)),
            value: ExpressionId(0),
        },
        HirStatement::Repeat {
            body: vec![StatementId(5)],
            condition: ExpressionId(0),
        },
        HirStatement::For {
            control: LocalId(3),
            initial: ExpressionId(0),
            ending: ExpressionId(0),
            step: None,
            body: vec![StatementId(6)],
        },
        HirStatement::Assign {
            destination: HirPlace::Local(LocalId(1)),
            value: ExpressionId(0),
        },
    ];
    let modified = collect_modified_locals(&[StatementId(0)], &module);
    assert_eq!(
        modified,
        vec![LocalId(0), LocalId(1), LocalId(2), LocalId(3)]
    );
}
