#![forbid(unsafe_code)]

use pseudolearn_ir::{Operation, verify_module};
use pseudolearn_lowering::lower_module;
use pseudolearn_semantic::expression_model::{HirExpression, HirPlace, Literal};
use pseudolearn_semantic::hir::{
    FunctionKind, HirClass, HirField, HirFunction, HirLocal, HirModule, Passing,
};
use pseudolearn_semantic::identities::{
    ClassId, ExpressionId, FieldId, LocalId, StatementId, TypeId,
};
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

fn create_read_test_module() -> HirModule {
    let mut module = HirModule::default();
    let (integer_type, array_type, object_type) = setup_types(&mut module);
    setup_class(&mut module, integer_type);
    setup_locals(&mut module, integer_type, array_type, object_type);
    setup_expressions(&mut module, integer_type, array_type, object_type);
    setup_statements(&mut module);
    setup_function(&mut module);
    module
}

fn setup_types(module: &mut HirModule) -> (TypeId, TypeId, TypeId) {
    let integer_type = module.types.intern(Type::Integer);
    let array_type = module.types.intern(Type::Array {
        element: integer_type,
        rank: 1,
    });
    let object_type = module.types.intern(Type::Object(ClassId(0)));
    (integer_type, array_type, object_type)
}

fn setup_class(module: &mut HirModule, integer_type: TypeId) {
    module.classes.push(HirClass {
        name: "Point".to_owned(),
        superclass: None,
        fields: vec![HirField {
            id: FieldId(0),
            name: "coord_x".to_owned(),
            type_id: integer_type,
            owner: ClassId(0),
            private: false,
            span: Span::new(0, 0),
        }],
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span: Span::new(0, 0),
        syntax: 0,
    });
}

fn setup_locals(
    module: &mut HirModule,
    integer_type: TypeId,
    array_type: TypeId,
    object_type: TypeId,
) {
    let locals = [
        ("scalar_variable", integer_type),
        ("array_variable", array_type),
        ("object_variable", object_type),
    ];
    for (name, type_id) in locals {
        module.locals.push(HirLocal {
            name: name.to_owned(),
            type_id,
            passing: Passing::Value,
            span: Span::new(0, 0),
            scope: pseudolearn_semantic::identities::FunctionId(0),
            parameter: false,
            mutable: true,
        });
    }
}

fn setup_expressions(
    module: &mut HirModule,
    integer_type: TypeId,
    array_type: TypeId,
    object_type: TypeId,
) {
    module
        .expressions
        .kinds
        .push(HirExpression::Local(LocalId(1)));
    module.expressions.types.push(array_type);
    module.expressions.spans.push(Span::new(22, 25));

    module
        .expressions
        .kinds
        .push(HirExpression::Literal(Literal::Integer(0)));
    module.expressions.types.push(integer_type);
    module.expressions.spans.push(Span::new(26, 27));

    module
        .expressions
        .kinds
        .push(HirExpression::Local(LocalId(2)));
    module.expressions.types.push(object_type);
    module.expressions.spans.push(Span::new(30, 33));

    module.expressions.kinds.push(HirExpression::New {
        class: ClassId(0),
        arguments: Vec::new(),
    });
    module.expressions.types.push(object_type);
    module.expressions.spans.push(Span::new(30, 33));
}

fn setup_statements(module: &mut HirModule) {
    module.statements.kinds.push(HirStatement::Dimension(vec![
        pseudolearn_semantic::statement_model::HirDimension {
            local: LocalId(1),
            dimensions: vec![ExpressionId(1)],
        },
    ]));
    module.statements.spans.push(Span::new(12, 20));

    module.statements.kinds.push(HirStatement::Assign {
        destination: HirPlace::Local(LocalId(2)),
        value: ExpressionId(3),
    });
    module.statements.spans.push(Span::new(21, 30));

    let places = vec![
        HirPlace::Local(LocalId(0)),
        HirPlace::Element {
            array: ExpressionId(0),
            indices: vec![ExpressionId(1)],
        },
        HirPlace::Field {
            receiver: ExpressionId(2),
            field: FieldId(0),
        },
    ];
    module.statements.kinds.push(HirStatement::Read(places));
    module.statements.spans.push(Span::new(31, 55));
}

fn setup_function(module: &mut HirModule) {
    let unit_type = module.types.intern(Type::Unit);
    module.functions.push(HirFunction {
        kind: FunctionKind::Main,
        name: "main".to_owned(),
        owner: None,
        parameters: Vec::new(),
        result: unit_type,
        suspendible: false,
        body: vec![StatementId(0), StatementId(1), StatementId(2)],
        span: Span::new(0, 60),
        closing_span: Span::new(56, 60),
        syntax: 0,
        private: false,
    });
}

#[test]
fn lowers_read_targets_and_verifies_ir() {
    let module = create_read_test_module();
    let source = SourceText::new("Algoritmo P\nDimension arr[1];\nobj <- Nuevo Point();\nLeer num, arr[0], obj.x;\nFinAlgoritmo\n".to_owned());
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    let target_module = match lowered {
        Ok(module) => module,
        Err(_) => return,
    };
    assert_eq!(verify_module(&target_module), Ok(()));
    verify_lowered_counts(&target_module);
}

#[test]
fn lowers_value_field_reads_and_writes_to_direct_operations() {
    let mut module = create_read_test_module();
    let integer_type = module.types.intern(Type::Integer);
    module
        .expressions
        .kinds
        .push(HirExpression::Literal(Literal::Integer(7)));
    module.expressions.types.push(integer_type);
    module.expressions.spans.push(Span::new(61, 62));
    module.expressions.kinds.push(HirExpression::Field {
        receiver: ExpressionId(2),
        field: FieldId(0),
    });
    module.expressions.types.push(integer_type);
    module.expressions.spans.push(Span::new(63, 72));
    module.statements.kinds.push(HirStatement::Assign {
        destination: HirPlace::Field {
            receiver: ExpressionId(2),
            field: FieldId(0),
        },
        value: ExpressionId(4),
    });
    module.statements.spans.push(Span::new(61, 72));
    module.statements.kinds.push(HirStatement::Write {
        values: vec![ExpressionId(5)],
        newline: true,
    });
    module.statements.spans.push(Span::new(73, 83));
    if let Some(function) = module.functions.first_mut() {
        function.body.extend([StatementId(3), StatementId(4)]);
    }
    let source = SourceText::new(
        "Algoritmo P\nDimension arr[1];\nobj <- Nuevo Point();\nLeer num, arr[0], obj.x;\nobj.x <- 7;\nEscribir obj.x;\nFinAlgoritmo\n".to_owned(),
    );
    let lowered = lower_module(&module, &source);
    assert!(lowered.is_ok());
    let Some(target_module) = lowered.ok() else {
        return;
    };
    assert_eq!(verify_module(&target_module), Ok(()));
    let Some(function) = target_module.find_function("main") else {
        return;
    };
    let operations = function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .filter_map(|instruction| function.columns.operation(*instruction))
        .collect::<Vec<_>>();
    assert!(operations.contains(&Operation::ObjectLoad));
    assert!(operations.contains(&Operation::ObjectStore));
    assert!(operations.contains(&Operation::CellField));
}

fn verify_lowered_counts(target_module: &pseudolearn_ir::Module) {
    let target_function = match target_module.find_function("main") {
        Some(function) => function,
        None => return,
    };
    let mut in_read_count: u32 = 0;
    let mut cell_element_count: u32 = 0;
    let mut cell_field_count: u32 = 0;
    for instruction_id in target_function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
    {
        if let Some(operation) = target_function.columns.operation(*instruction_id) {
            match operation {
                Operation::InRead => in_read_count = in_read_count.saturating_add(1),
                Operation::CellElement => {
                    cell_element_count = cell_element_count.saturating_add(1);
                }
                Operation::CellField => {
                    cell_field_count = cell_field_count.saturating_add(1);
                }
                _ => {}
            }
        }
    }
    assert_eq!(in_read_count, 3);
    assert_eq!(cell_element_count, 1);
    assert_eq!(cell_field_count, 1);
}
