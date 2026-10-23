use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::Cursor;

fn site(code: DiagnosticCode) -> FaultSite {
    FaultSite {
        lexeme: String::new(),
        code,
        range: SourceRange {
            source_id: 0,
            start_line: 3,
            start_column: 5,
            end_line: 3,
            end_column: 9,
        },
    }
}

fn config() -> AotConfig {
    AotConfig {
        limits: AotLimits::default(),
        seed: 7,
        boolean_words: BooleanWords {
            truth: "verdadero".to_owned(),
            falsity: "falso".to_owned(),
        },
    }
}

use pseudolearn_runtime::ObjectLayout;

fn session_with_sites() -> AotSession {
    AotSession::new(
        config(),
        vec![
            site(DiagnosticCode::DivisionByZero),
            site(DiagnosticCode::StatementBudgetExhausted),
            site(DiagnosticCode::RecursionDepthExceeded),
        ],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    )
}

#[test]
fn a_runtime_failure_site_returns_the_failed_status() {
    let mut session = session_with_sites();
    assert_eq!(rt_aot_fault(session.context_pointer(), 0), STATUS_FAILED);
    let context = session.context();
    assert_eq!(
        (context.fault_site, context.fault_status),
        (0, STATUS_FAILED)
    );
    let record = session.engine().fault();
    assert_eq!(
        record.map(|fault| fault.code),
        Some(Some(DiagnosticCode::DivisionByZero))
    );
    assert_eq!(record.map(|fault| fault.range.start_line), Some(3));
}

#[test]
fn an_exhausted_statement_budget_returns_the_limit_status() {
    let mut session = session_with_sites();
    assert_eq!(rt_aot_fault(session.context_pointer(), 1), STATUS_LIMIT);
    assert_eq!(session.context().fault_status, STATUS_LIMIT);
}

#[test]
fn frame_depth_overflow_is_a_program_failure_not_a_limit() {
    let mut session = session_with_sites();
    assert_eq!(rt_aot_fault(session.context_pointer(), 2), STATUS_FAILED);
    let code = session.engine().fault().and_then(|record| record.code);
    assert_eq!(code, Some(DiagnosticCode::RecursionDepthExceeded));
}

#[test]
fn an_undeclared_site_is_an_internal_fault() {
    let mut session = session_with_sites();
    assert_eq!(rt_aot_fault(session.context_pointer(), 99), STATUS_FAILED);
    let code = session.engine().fault().and_then(|record| record.code);
    assert_eq!(code, Some(DiagnosticCode::InternalFault));
}

#[test]
fn only_the_first_failure_is_kept() {
    let mut session = session_with_sites();
    assert_eq!(rt_aot_fault(session.context_pointer(), 0), STATUS_FAILED);
    assert_eq!(rt_aot_fault(session.context_pointer(), 2), STATUS_FAILED);
    let code = session.engine().fault().and_then(|record| record.code);
    assert_eq!(code, Some(DiagnosticCode::DivisionByZero));
    assert_eq!(session.context().fault_site, 2);
}

#[test]
fn a_null_context_cannot_record_anything_and_fails() {
    assert_eq!(rt_aot_fault(std::ptr::null_mut(), 0), STATUS_FAILED);
}

#[test]
fn layouts_registered_twice_with_different_shapes_are_rejected() {
    let mut session = session_with_sites();
    let first = ObjectLayout {
        class: 0,
        fields: vec![],
        dense: false,
        references: vec![],
    };
    assert_eq!(session.engine_mut().register_layout(first.clone()), Ok(()));
    assert_eq!(session.engine_mut().register_layout(first), Ok(()));
    let different = ObjectLayout {
        class: 0,
        fields: vec![pseudolearn_runtime::ValueKind::Integer],
        dense: false,
        references: vec![],
    };
    assert!(session.engine_mut().register_layout(different).is_err());
}
