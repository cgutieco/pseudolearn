use crate::effect_bytes_faults::{BYTES_AT, with_bytes_index};
use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::HostValue;

fn index_trap() -> Trap {
    Trap::with_code(DiagnosticCode::ArrayIndexOutOfRange)
}

#[test]
fn adds_the_requested_index_and_the_byte_count_like_the_vm() {
    let trap = with_bytes_index(index_trap(), (BYTES_AT, Some(2)), &[HostValue::Integer(5)]);
    assert_eq!(
        trap.arguments,
        vec![
            ("index".to_owned(), "5".to_owned()),
            ("size".to_owned(), "2".to_owned())
        ]
    );
}

#[test]
fn keeps_a_negative_index_and_an_empty_sequence() {
    let trap = with_bytes_index(index_trap(), (BYTES_AT, Some(0)), &[HostValue::Integer(-1)]);
    assert_eq!(
        trap.arguments,
        vec![
            ("index".to_owned(), "-1".to_owned()),
            ("size".to_owned(), "0".to_owned())
        ]
    );
}

#[test]
fn leaves_other_faults_operations_and_unexpected_operands_untouched() {
    let other_fault = with_bytes_index(
        Trap::with_code(DiagnosticCode::DivisionByZero),
        (BYTES_AT, Some(2)),
        &[HostValue::Integer(5)],
    );
    assert!(other_fault.arguments.is_empty());
    let other_operation = with_bytes_index(
        index_trap(),
        ("bytes_length", Some(2)),
        &[HostValue::Integer(5)],
    );
    assert!(other_operation.arguments.is_empty());
    let unknown_size = with_bytes_index(index_trap(), (BYTES_AT, None), &[HostValue::Integer(5)]);
    assert!(unknown_size.arguments.is_empty());
    let malformed = with_bytes_index(index_trap(), (BYTES_AT, Some(2)), &[]);
    assert!(malformed.arguments.is_empty());
}
