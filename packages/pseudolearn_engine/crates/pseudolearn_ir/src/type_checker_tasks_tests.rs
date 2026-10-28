use crate::identities::ValueId;
use crate::model::Module;
use crate::operand::Operand;
use crate::operation::Operation;
use crate::type_checker::check_instruction_types;
use crate::types::IrType;

#[test]
fn accepts_well_typed_task_scope_and_result_operations() {
    let module = Module::new("task_module".to_owned(), "es".to_owned());
    let type_of = |value| (value == ValueId(0)).then_some(IrType::I64);
    assert_eq!(
        check_instruction_types(Operation::TaskScopeOpen, &[], type_of, &module),
        Ok(Some(IrType::I64))
    );
    assert_eq!(
        check_instruction_types(
            Operation::TaskSpawn,
            &[
                Operand::Value(ValueId(0)),
                Operand::FunctionTarget {
                    function_name: "@worker".to_owned(),
                    arguments: Vec::new(),
                },
            ],
            type_of,
            &module,
        ),
        Ok(Some(IrType::I64))
    );
    assert_eq!(
        check_instruction_types(
            Operation::TaskAwait,
            &[Operand::Value(ValueId(0)), Operand::Type(IrType::Str)],
            type_of,
            &module,
        ),
        Ok(Some(IrType::Str))
    );
    assert_eq!(
        check_instruction_types(
            Operation::TaskScopeJoin,
            &[Operand::Value(ValueId(0))],
            type_of,
            &module,
        ),
        Ok(Some(IrType::Unit))
    );
    assert_eq!(
        check_instruction_types(Operation::TaskYieldCheck, &[], type_of, &module),
        Ok(None)
    );
}

#[test]
fn rejects_invalid_task_handles_and_incomplete_task_operations() {
    let module = Module::new("task_module".to_owned(), "es".to_owned());
    let type_of = |value| (value == ValueId(0)).then_some(IrType::Str);
    assert!(
        check_instruction_types(
            Operation::TaskSpawn,
            &[
                Operand::Value(ValueId(0)),
                Operand::FunctionTarget {
                    function_name: "@worker".to_owned(),
                    arguments: Vec::new(),
                },
            ],
            type_of,
            &module,
        )
        .is_err()
    );
    assert!(
        check_instruction_types(
            Operation::TaskAwait,
            &[Operand::Value(ValueId(0)), Operand::Type(IrType::Unit)],
            type_of,
            &module,
        )
        .is_err()
    );
    assert!(
        check_instruction_types(
            Operation::TaskScopeJoin,
            &[Operand::Value(ValueId(0))],
            type_of,
            &module,
        )
        .is_err()
    );
    assert!(
        check_instruction_types(
            Operation::TaskYieldCheck,
            &[Operand::LiteralI64(0)],
            type_of,
            &module,
        )
        .is_err()
    );
}
