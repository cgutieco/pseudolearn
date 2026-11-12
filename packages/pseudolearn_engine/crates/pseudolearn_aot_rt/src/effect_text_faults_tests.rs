use crate::effect_text_faults::with_text_position;
use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::HostValue;

fn position_trap() -> Trap {
    Trap::with_code(DiagnosticCode::StringPositionOutOfRange)
}

fn arguments_of(trap: &Trap) -> Vec<(String, String)> {
    trap.arguments.clone()
}

#[test]
fn adds_the_length_and_the_reported_position_like_the_vm() {
    let trap = with_text_position(
        position_trap(),
        &[
            HostValue::Text("hola".to_owned()),
            HostValue::Integer(0),
            HostValue::Integer(4),
        ],
    );
    assert_eq!(
        arguments_of(&trap),
        vec![
            ("length".to_owned(), "4".to_owned()),
            ("position".to_owned(), "4".to_owned())
        ]
    );
}

#[test]
fn counts_code_points_and_uses_the_start_without_a_third_operand() {
    let trap = with_text_position(
        position_trap(),
        &[HostValue::Text("año".to_owned()), HostValue::Integer(-1)],
    );
    assert_eq!(
        arguments_of(&trap),
        vec![
            ("length".to_owned(), "3".to_owned()),
            ("position".to_owned(), "-1".to_owned())
        ]
    );
}

#[test]
fn falls_back_to_the_start_when_the_sum_overflows() {
    let trap = with_text_position(
        position_trap(),
        &[
            HostValue::Text(String::new()),
            HostValue::Integer(i64::MAX),
            HostValue::Integer(1),
        ],
    );
    assert_eq!(
        arguments_of(&trap),
        vec![
            ("length".to_owned(), "0".to_owned()),
            ("position".to_owned(), i64::MAX.to_string())
        ]
    );
}

#[test]
fn leaves_other_faults_and_unexpected_operands_untouched() {
    let other = with_text_position(
        Trap::with_code(DiagnosticCode::DivisionByZero),
        &[HostValue::Text("a".to_owned()), HostValue::Integer(0)],
    );
    assert!(other.arguments.is_empty());
    let malformed = with_text_position(position_trap(), &[HostValue::Integer(0)]);
    assert!(malformed.arguments.is_empty());
    let empty = with_text_position(position_trap(), &[]);
    assert!(empty.arguments.is_empty());
}
