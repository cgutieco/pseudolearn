use pseudolearn_semantic::hir::{HirLocal, HirModule, Passing};
use pseudolearn_semantic::identities::{ExpressionId, FunctionId, LocalId};
use pseudolearn_semantic::inspection_expression::InspectionExpression;
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

#[test]
fn lowers_typed_capture_without_parsing_a_second_program() -> Result<(), String> {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    module.locals.push(HirLocal {
        name: "answer".to_owned(),
        type_id: integer,
        passing: Passing::Value,
        span: Span::default(),
        scope: FunctionId(0),
        parameter: true,
        mutable: false,
    });
    module
        .expressions
        .kinds
        .push(pseudolearn_semantic::expression_model::HirExpression::Local(LocalId(0)));
    module.expressions.types.push(integer);
    module.expressions.spans.push(Span::new(0, 6));
    module
        .expressions
        .value_classes
        .push(pseudolearn_semantic::types::ValueClass::Scalar);
    let inspection = InspectionExpression {
        module,
        expression: ExpressionId(0),
        parameters: vec![LocalId(0)],
        text_captures: Vec::new(),
    };
    let source = SourceText::new("answer".to_owned());
    let lowered = pseudolearn_lowering::inspection_lowering::lower_inspection(&inspection, &source)
        .map_err(|error| error.description)?;
    let function = lowered
        .functions
        .first()
        .ok_or("Missing inspection function")?;
    assert_eq!(function.name, "@main");
    assert_eq!(function.parameters.len(), 1);
    assert_eq!(function.return_type, pseudolearn_ir::IrType::I64);
    Ok(())
}

#[test]
fn rejects_an_invalid_expression_identity() {
    let inspection = InspectionExpression {
        module: HirModule::default(),
        expression: ExpressionId(0),
        parameters: Vec::new(),
        text_captures: Vec::new(),
    };
    assert!(
        pseudolearn_lowering::inspection_lowering::lower_inspection(
            &inspection,
            &SourceText::new(String::new())
        )
        .is_err()
    );
}
