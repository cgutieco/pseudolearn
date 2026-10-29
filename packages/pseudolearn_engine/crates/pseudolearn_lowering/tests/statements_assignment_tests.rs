use pseudolearn_ir::{IrType, Operation};
use pseudolearn_lowering::builder::FunctionBuilder;
use pseudolearn_lowering::environment::VariableEnvironment;
use pseudolearn_lowering::expressions::ExpressionContext;
use pseudolearn_lowering::statement_context::StatementContext;
use pseudolearn_lowering::statements_assignment::lower_assign;
use pseudolearn_semantic::expression_model::{HirExpression, HirPlace, Literal};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction, HirLocal, HirModule, Passing};
use pseudolearn_semantic::identities::{ExpressionId, FunctionId, LocalId};
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

fn module(addressed: bool) -> HirModule {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let unit = module.types.intern(Type::Unit);
    module.locals.push(HirLocal {
        name: "number".to_owned(),
        type_id: integer,
        passing: Passing::Value,
        span: Span::new(0, 1),
        scope: FunctionId(0),
        parameter: false,
        mutable: addressed,
    });
    module
        .expressions
        .kinds
        .push(HirExpression::Literal(Literal::Integer(7)));
    module.expressions.types.push(integer);
    module.expressions.spans.push(Span::new(0, 1));
    if addressed {
        module.locals.push(HirLocal {
            name: "target".to_owned(),
            type_id: integer,
            passing: Passing::Reference,
            span: Span::new(0, 1),
            scope: FunctionId(0),
            parameter: true,
            mutable: true,
        });
        module.functions.push(HirFunction {
            kind: FunctionKind::Procedure,
            name: "Update".to_owned(),
            owner: None,
            parameters: vec![LocalId(1)],
            result: unit,
            suspendible: false,
            body: Vec::new(),
            span: Span::new(0, 1),
            closing_span: Span::new(0, 1),
            syntax: 0,
            private: false,
        });
        module
            .expressions
            .kinds
            .push(HirExpression::Local(LocalId(0)));
        module.expressions.kinds.push(HirExpression::Call {
            function: FunctionId(0),
            arguments: vec![ExpressionId(1)],
        });
    }
    module
}

fn initialize(module: &HirModule) -> FunctionBuilder {
    let source = SourceText::new("7".to_owned());
    let expression_context = ExpressionContext {
        module,
        source: &source,
    };
    let mut environment = VariableEnvironment::new();
    let mut builder = FunctionBuilder::new("@main".to_owned(), IrType::Unit);
    let block = builder.create_block();
    builder.set_current_block(block);
    let mut origins = Vec::new();
    let mut context = StatementContext {
        expression_context: &expression_context,
        environment: &mut environment,
        builder: &mut builder,
        origins: &mut origins,
    };
    lower_assign(
        &HirPlace::Local(LocalId(0)),
        ExpressionId(0),
        Span::new(0, 1),
        &mut context,
    );
    builder
}

fn count(builder: &FunctionBuilder, operation: Operation) -> usize {
    builder
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .filter(|identifier| builder.columns.operation(**identifier) == Some(operation))
        .count()
}

#[test]
fn immutable_initializer_stays_in_ssa_without_an_undefined_local() {
    let builder = initialize(&module(false));
    assert_eq!(count(&builder, Operation::CellLocal), 0);
    assert_eq!(count(&builder, Operation::ValueUndefined), 0);
}

#[test]
fn addressed_mutable_initializer_creates_its_cell_before_any_call() {
    let builder = initialize(&module(true));
    assert_eq!(count(&builder, Operation::CellLocal), 1);
    assert_eq!(count(&builder, Operation::CellStore), 1);
}

#[test]
fn assigning_one_local_to_another_produces_distinct_origin_values() {
    let mut hir = module(false);
    let integer = hir
        .locals
        .first()
        .map(|local| local.type_id)
        .unwrap_or(pseudolearn_semantic::identities::TypeId(0));
    hir.locals.push(HirLocal {
        name: "copy".to_owned(),
        type_id: integer,
        passing: Passing::Value,
        span: Span::new(0, 1),
        scope: FunctionId(0),
        parameter: false,
        mutable: false,
    });
    hir.expressions.kinds.push(HirExpression::Local(LocalId(0)));
    hir.expressions.types.push(integer);
    hir.expressions.spans.push(Span::new(0, 1));
    let source = SourceText::new("7".to_owned());
    let expression_context = ExpressionContext {
        module: &hir,
        source: &source,
    };
    let mut environment = VariableEnvironment::new();
    let mut builder = FunctionBuilder::new("@main".to_owned(), IrType::Unit);
    let block = builder.create_block();
    builder.set_current_block(block);
    let mut origins = Vec::new();
    let mut context = StatementContext {
        expression_context: &expression_context,
        environment: &mut environment,
        builder: &mut builder,
        origins: &mut origins,
    };
    lower_assign(
        &HirPlace::Local(LocalId(0)),
        ExpressionId(0),
        Span::new(0, 1),
        &mut context,
    );
    lower_assign(
        &HirPlace::Local(LocalId(1)),
        ExpressionId(1),
        Span::new(0, 1),
        &mut context,
    );
    assert_eq!(count(&builder, Operation::ValueReinterpret), 1);
    assert_eq!(origins.len(), 2);
    assert_ne!(
        origins.first().map(|o| o.value),
        origins.get(1).map(|o| o.value)
    );
}
