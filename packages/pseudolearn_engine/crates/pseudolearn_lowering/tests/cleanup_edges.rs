use pseudolearn_ir::{IrType, Operand, Operation};
use pseudolearn_lowering::expressions::ExpressionContext;
use pseudolearn_lowering::statement_context::StatementContext;
use pseudolearn_lowering::{FunctionBuilder, VariableEnvironment};
use pseudolearn_semantic::expression_model::Literal;
use pseudolearn_semantic::{
    ExpressionId, HirExpression, HirModule, HirStatement, StatementId, Type,
};
use pseudolearn_source::{SourceText, Span};

fn cleanup_module(returning: bool) -> HirModule {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    for value in [1, 2] {
        module
            .expressions
            .kinds
            .push(HirExpression::Literal(Literal::Integer(value)));
        module.expressions.types.push(integer);
        module.expressions.spans.push(Span::new(0, 1));
    }
    module.statements.kinds = vec![
        HirStatement::Write {
            values: vec![ExpressionId(0)],
            newline: true,
        },
        HirStatement::Write {
            values: vec![ExpressionId(1)],
            newline: true,
        },
        HirStatement::Defer(vec![StatementId(0)]),
        HirStatement::Defer(vec![StatementId(1)]),
        HirStatement::Return(None),
    ];
    module.statements.spans = vec![Span::new(0, 1); 5];
    if !returning {
        module.statements.kinds.pop();
    }
    module
}

fn emitted_operations(returning: bool, with_value: bool) -> Vec<(Operation, Option<i64>)> {
    let mut module = cleanup_module(returning);
    if returning && with_value {
        module.statements.kinds.pop();
        module
            .statements
            .kinds
            .push(HirStatement::Return(Some(ExpressionId(0))));
    }
    let source = SourceText::new("x".to_owned());
    let expression_context = ExpressionContext {
        module: &module,
        source: &source,
    };
    let mut builder = FunctionBuilder::new("main".to_owned(), IrType::Unit);
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let mut environment = VariableEnvironment::new();
    let mut origins = Vec::new();
    let mut context = StatementContext {
        expression_context: &expression_context,
        environment: &mut environment,
        builder: &mut builder,
        origins: &mut origins,
    };
    let body = if returning {
        vec![StatementId(2), StatementId(3), StatementId(4)]
    } else {
        vec![StatementId(2), StatementId(3)]
    };
    pseudolearn_lowering::statements::lower_statement_list(&body, &mut context);
    builder
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .filter_map(|instruction| {
            let operation = builder.columns.operation(*instruction)?;
            let literal = match builder.columns.operands(*instruction).first() {
                Some(Operand::LiteralI64(value)) => Some(*value),
                _ => None,
            };
            Some((operation, literal))
        })
        .collect()
}

fn emitted_cleanup_constants(returning: bool) -> Vec<i64> {
    emitted_operations(returning, false)
        .into_iter()
        .filter(|(operation, _)| *operation == Operation::ConstI64)
        .filter_map(|(_, literal)| literal)
        .collect()
}

#[test]
fn normal_exit_emits_each_cleanup_once_in_reverse_order() {
    assert_eq!(emitted_cleanup_constants(false), vec![2, 1]);
}

#[test]
fn return_emits_each_cleanup_once_without_normal_exit_duplication() {
    assert_eq!(emitted_cleanup_constants(true), vec![2, 1]);
}

#[test]
fn returned_value_is_snapshotted_before_any_cleanup_runs() {
    let operations = emitted_operations(true, true);
    let snapshot = operations
        .iter()
        .position(|(operation, _)| *operation == Operation::ValueRequire);
    let first_cleanup = operations
        .iter()
        .position(|(operation, literal)| *operation == Operation::ConstI64 && *literal == Some(2));
    assert!(snapshot.is_some());
    assert!(snapshot < first_cleanup);
}
