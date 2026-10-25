#![forbid(unsafe_code)]

use pseudolearn_ir::{Function, IrType, Module, Operation, verify_module};
use pseudolearn_lowering::lower_module;
use pseudolearn_semantic::expression_model::{BinaryOperator, HirExpression, HirPlace, Literal};
use pseudolearn_semantic::hir::{
    FunctionKind, HirEnum, HirFunction, HirLocal, HirModule, HirRecord, HirRecordField, Passing,
};
use pseudolearn_semantic::identities::{
    EnumId, ExpressionId, FunctionId, LocalId, RecordId, StatementId, TypeId,
};
use pseudolearn_semantic::statement_model::HirStatement;
use pseudolearn_semantic::types::Type;
use pseudolearn_source::{SourceText, Span};

struct Fixture {
    module: HirModule,
    integer: TypeId,
    unit: TypeId,
    point: TypeId,
}

fn fixture() -> Fixture {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let unit = module.types.intern(Type::Unit);
    let point = module.types.intern(Type::Record(RecordId(0)));
    module.records.push(HirRecord {
        name: "Point".to_owned(),
        fields: vec![
            HirRecordField {
                name: "x".to_owned(),
                type_id: integer,
                offset: 0,
                width: 1,
            },
            HirRecordField {
                name: "z".to_owned(),
                type_id: integer,
                offset: 1,
                width: 1,
            },
        ],
        leaf_types: vec![integer, integer],
        leaf_names: vec!["x".to_owned(), "z".to_owned()],
        span: Span::new(0, 1),
        syntax: 0,
    });
    Fixture {
        module,
        integer,
        unit,
        point,
    }
}

impl Fixture {
    fn local(&mut self, name: &str, type_id: TypeId, parameter: bool) -> LocalId {
        let identifier = LocalId(u32::try_from(self.module.locals.len()).unwrap_or(u32::MAX));
        self.module.locals.push(HirLocal {
            name: name.to_owned(),
            type_id,
            passing: Passing::Value,
            span: Span::new(1, 2),
            scope: FunctionId(0),
            parameter,
        });
        identifier
    }

    fn record_local(&mut self, name: &str, parameter: bool) -> LocalId {
        let point = self.point;
        let integer = self.integer;
        let whole = self.local(name, point, parameter);
        let first = self.local(&format!("{name}.x"), integer, parameter);
        let second = self.local(&format!("{name}.z"), integer, parameter);
        self.module.record_locals.insert(whole, vec![first, second]);
        whole
    }

    fn expression(&mut self, kind: HirExpression, type_id: TypeId) -> ExpressionId {
        let identifier =
            ExpressionId(u32::try_from(self.module.expressions.kinds.len()).unwrap_or(u32::MAX));
        self.module.expressions.kinds.push(kind);
        self.module.expressions.types.push(type_id);
        self.module.expressions.spans.push(Span::new(2, 3));
        identifier
    }

    fn statement(&mut self, kind: HirStatement) -> StatementId {
        let identifier =
            StatementId(u32::try_from(self.module.statements.kinds.len()).unwrap_or(u32::MAX));
        self.module.statements.kinds.push(kind);
        self.module.statements.spans.push(Span::new(3, 4));
        identifier
    }

    fn construct(&mut self, first: i64, second: i64) -> ExpressionId {
        let integer = self.integer;
        let point = self.point;
        let first_literal =
            self.expression(HirExpression::Literal(Literal::Integer(first)), integer);
        let second_literal =
            self.expression(HirExpression::Literal(Literal::Integer(second)), integer);
        self.expression(
            HirExpression::RecordNew {
                record: RecordId(0),
                fields: vec![first_literal, second_literal],
            },
            point,
        )
    }

    fn field(&mut self, local: LocalId, offset: u32) -> ExpressionId {
        let point = self.point;
        let integer = self.integer;
        let whole = self.expression(HirExpression::Local(local), point);
        self.expression(
            HirExpression::RecordField {
                record: whole,
                offset,
            },
            integer,
        )
    }

    fn main(&mut self, body: Vec<StatementId>) {
        let unit = self.unit;
        self.function(FunctionKind::Main, "main", (unit, Vec::new()), body);
    }

    fn function(
        &mut self,
        kind: FunctionKind,
        name: &str,
        signature: (TypeId, Vec<LocalId>),
        body: Vec<StatementId>,
    ) {
        let (result, parameters) = signature;
        self.module.functions.push(HirFunction {
            kind,
            name: name.to_owned(),
            owner: None,
            parameters,
            result,
            body,
            span: Span::new(0, 40),
            closing_span: Span::new(36, 40),
            syntax: 0,
            private: false,
        });
    }

    fn lower(&self) -> Option<Module> {
        let source = SourceText::new("Algoritmo P\nFinAlgoritmo\n".to_owned());
        lower_module(&self.module, &source).ok()
    }
}

fn count(function: &Function, operation: Operation) -> usize {
    function
        .blocks
        .iter()
        .flat_map(|block| block.instructions.iter())
        .filter(|instruction| function.columns.operation(**instruction) == Some(operation))
        .count()
}

fn named<'module>(module: &'module Module, name: &str) -> Option<&'module Function> {
    module
        .functions
        .iter()
        .find(|function| function.name == name)
}

#[test]
fn assigns_and_reads_record_fields_without_cells_or_objects() {
    let mut fixture = fixture();
    let first_local = fixture.record_local("p", false);
    let declare = fixture.statement(HirStatement::Declare(vec![first_local]));
    let value = fixture.construct(1, 2);
    let assign = fixture.statement(HirStatement::Assign {
        destination: HirPlace::Local(first_local),
        value,
    });
    let read = fixture.field(first_local, 1);
    let write = fixture.statement(HirStatement::Write {
        values: vec![read],
        newline: true,
    });
    fixture.main(vec![declare, assign, write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
    let main = lowered.as_ref().and_then(|module| named(module, "@main"));
    assert_eq!(
        main.map(|function| count(function, Operation::CellLocal)),
        Some(0)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::ObjectNew)),
        Some(0)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::ValueUndefined)),
        Some(2)
    );
}

#[test]
fn updating_one_field_keeps_the_other_component() {
    let mut fixture = fixture();
    let first_local = fixture.record_local("p", false);
    let declare = fixture.statement(HirStatement::Declare(vec![first_local]));
    let value = fixture.construct(1, 2);
    let assign = fixture.statement(HirStatement::Assign {
        destination: HirPlace::Local(first_local),
        value,
    });
    let integer = fixture.integer;
    let seven = fixture.expression(HirExpression::Literal(Literal::Integer(7)), integer);
    let update = fixture.statement(HirStatement::Assign {
        destination: HirPlace::RecordField {
            local: first_local,
            offset: 0,
            type_id: integer,
        },
        value: seven,
    });
    let read = fixture.field(first_local, 1);
    let write = fixture.statement(HirStatement::Write {
        values: vec![read],
        newline: true,
    });
    fixture.main(vec![declare, assign, update, write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
}

#[test]
fn record_equality_chains_one_branch_per_extra_leaf() {
    let mut fixture = fixture();
    let first_local = fixture.record_local("p", false);
    let second_local = fixture.record_local("q", false);
    let declare = fixture.statement(HirStatement::Declare(vec![first_local, second_local]));
    let (first, second) = (fixture.construct(1, 2), fixture.construct(1, 2));
    let assign_p = fixture.statement(HirStatement::Assign {
        destination: HirPlace::Local(first_local),
        value: first,
    });
    let assign_q = fixture.statement(HirStatement::Assign {
        destination: HirPlace::Local(second_local),
        value: second,
    });
    let point = fixture.point;
    let left = fixture.expression(HirExpression::Local(first_local), point);
    let right = fixture.expression(HirExpression::Local(second_local), point);
    let boolean = fixture.module.types.intern(Type::Boolean);
    let equal = fixture.expression(
        HirExpression::Binary {
            operator: BinaryOperator::Equal,
            left,
            right,
            operator_span: Span::new(2, 3),
        },
        boolean,
    );
    let write = fixture.statement(HirStatement::Write {
        values: vec![equal],
        newline: true,
    });
    fixture.main(vec![declare, assign_p, assign_q, write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
    let main = lowered.as_ref().and_then(|module| named(module, "@main"));
    assert_eq!(
        main.map(|function| count(function, Operation::IntCmp)),
        Some(2)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::Branch)),
        Some(1)
    );
}

#[test]
fn record_function_flattens_parameters_and_returns_through_cells() {
    let mut fixture = fixture();
    let parameter = fixture.record_local("p", true);
    let point = fixture.point;
    let mover_value = fixture.expression(HirExpression::Local(parameter), point);
    let returned = fixture.statement(HirStatement::Return(Some(mover_value)));
    fixture.function(
        FunctionKind::Function,
        "mover",
        (point, vec![parameter]),
        vec![returned],
    );
    let declared = fixture.record_local("a", false);
    let declare = fixture.statement(HirStatement::Declare(vec![declared]));
    let argument = fixture.construct(1, 2);
    let call = fixture.expression(
        HirExpression::Call {
            function: FunctionId(0),
            arguments: vec![argument],
        },
        point,
    );
    let assign = fixture.statement(HirStatement::Assign {
        destination: HirPlace::Local(declared),
        value: call,
    });
    let read = fixture.field(declared, 0);
    let write = fixture.statement(HirStatement::Write {
        values: vec![read],
        newline: true,
    });
    fixture.main(vec![declare, assign, write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
    let mover = lowered.as_ref().and_then(|module| named(module, "@mover"));
    assert_eq!(mover.map(|function| function.parameters.len()), Some(4));
    assert_eq!(
        mover.map(|function| function.return_type.clone()),
        Some(IrType::Unit)
    );
    let cells = mover.map(|function| {
        function
            .parameters
            .iter()
            .filter(|(_, kind)| matches!(kind, IrType::Cell(_)))
            .count()
    });
    assert_eq!(cells, Some(2));
    assert_eq!(
        mover.map(|function| count(function, Operation::CellStore)),
        Some(2)
    );
    let main = lowered.as_ref().and_then(|module| named(module, "@main"));
    assert_eq!(
        main.map(|function| count(function, Operation::CellLocal)),
        Some(2)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::CellLoad)),
        Some(2)
    );
}

#[test]
fn enum_values_print_member_names_and_compare_as_integers() {
    let mut fixture = fixture();
    fixture.module.enums.push(HirEnum {
        name: "Color".to_owned(),
        members: vec!["Rojo".to_owned(), "Verde".to_owned(), "Azul".to_owned()],
        span: Span::new(0, 1),
    });
    let color = fixture.module.types.intern(Type::Enum(EnumId(0)));
    let member = fixture.expression(HirExpression::Literal(Literal::Integer(1)), color);
    let write = fixture.statement(HirStatement::Write {
        values: vec![member],
        newline: true,
    });
    fixture.main(vec![write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
    let main = lowered.as_ref().and_then(|module| named(module, "@main"));
    assert_eq!(
        main.map(|function| count(function, Operation::ConstStr)),
        Some(3)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::IntCmp)),
        Some(2)
    );
}

#[test]
fn single_member_enum_prints_without_comparisons() {
    let mut fixture = fixture();
    fixture.module.enums.push(HirEnum {
        name: "Solo".to_owned(),
        members: vec!["Uno".to_owned()],
        span: Span::new(0, 1),
    });
    let solo = fixture.module.types.intern(Type::Enum(EnumId(0)));
    let member = fixture.expression(HirExpression::Literal(Literal::Integer(0)), solo);
    let write = fixture.statement(HirStatement::Write {
        values: vec![member],
        newline: true,
    });
    fixture.main(vec![write]);
    let lowered = fixture.lower();
    assert!(
        lowered
            .as_ref()
            .is_some_and(|module| verify_module(module) == Ok(()))
    );
    let main = lowered.as_ref().and_then(|module| named(module, "@main"));
    assert_eq!(
        main.map(|function| count(function, Operation::IntCmp)),
        Some(0)
    );
    assert_eq!(
        main.map(|function| count(function, Operation::ConstStr)),
        Some(1)
    );
}
