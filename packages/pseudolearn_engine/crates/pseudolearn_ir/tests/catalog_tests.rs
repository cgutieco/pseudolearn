#![forbid(unsafe_code)]

use pseudolearn_ir::Operation;

#[test]
fn verifies_instruction_catalog_properties() {
    let const_i64 = Operation::from_name("const.i64");
    assert_eq!(const_i64, Some(Operation::ConstI64));
    assert!(Operation::ConstI64.has_result());
    assert!(!Operation::ConstI64.is_terminator());

    let int_add = Operation::from_name("int.add");
    assert_eq!(int_add, Some(Operation::IntAdd));
    assert!(Operation::IntAdd.has_result());

    let int_div = Operation::from_name("int.div");
    assert_eq!(int_div, Some(Operation::IntDiv));
    assert!(Operation::IntDiv.can_trap());

    let statement_enter = Operation::from_name("stmt.enter");
    assert_eq!(statement_enter, Some(Operation::StmtEnter));
    assert!(Operation::StmtEnter.is_observation());
    assert!(!Operation::StmtEnter.has_result());

    let jump = Operation::from_name("jump");
    assert_eq!(jump, Some(Operation::Jump));
    assert!(Operation::Jump.is_terminator());
    assert!(!Operation::Jump.has_result());

    let branch = Operation::from_name("branch");
    assert_eq!(branch, Some(Operation::Branch));
    assert!(Operation::Branch.is_terminator());

    let return_operation = Operation::from_name("return");
    assert_eq!(return_operation, Some(Operation::Return));
    assert!(Operation::Return.is_terminator());

    assert_eq!(Operation::from_name("int.teleport"), None);
}

#[test]
fn the_catalog_lists_every_operation_once_and_names_round_trip() {
    assert_eq!(Operation::ALL.len(), 107);
    for operation in Operation::ALL {
        assert_eq!(Operation::from_name(operation.as_str()), Some(*operation));
    }
    let mut names: Vec<&str> = Operation::ALL.iter().map(Operation::as_str).collect();
    names.sort_unstable();
    names.dedup();
    assert_eq!(names.len(), 107);
}
