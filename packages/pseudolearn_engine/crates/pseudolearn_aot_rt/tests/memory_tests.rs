use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::Cursor;

fn site(code: DiagnosticCode) -> FaultSite {
    FaultSite {
        code,
        range: SourceRange {
            start_line: 3,
            start_column: 5,
            end_line: 3,
            end_column: 9,
        },
    }
}

fn session_with(limits: AotLimits, input: &str) -> AotSession {
    AotSession::new(
        AotConfig {
            limits,
            seed: 7,
            boolean_words: BooleanWords {
                truth: "verdadero".to_owned(),
                falsity: "falso".to_owned(),
            },
        },
        vec![site(DiagnosticCode::InternalFault)],
        AotStreams {
            input: Box::new(Cursor::new(input.as_bytes().to_vec())),
            output: Box::new(std::io::sink()),
        },
    )
}

fn session() -> AotSession {
    session_with(AotLimits::default(), "")
}

fn fault_code(session: &AotSession) -> Option<DiagnosticCode> {
    session.engine().fault().and_then(|record| record.code)
}

use pseudolearn_runtime::{Handle, ObjectLayout, ValueKind, heap_live_cells};

const INTEGER_ARRAY_OF_RANK_ONE: u32 = KIND_INTEGER | (1 << RANK_SHIFT);

fn new_array(session: &mut AotSession, extent: i64) -> u32 {
    let dimensions = [extent];
    rt_aot_array_new(
        session.context_pointer(),
        0,
        INTEGER_ARRAY_OF_RANK_ONE,
        dimensions.as_ptr(),
    )
}

fn layout() -> ObjectLayout {
    ObjectLayout {
        class: 0,
        fields: vec![ValueKind::Integer, ValueKind::Reference],
        dense: false,
        references: vec![1],
    }
}

#[test]
fn array_new_publishes_the_handle_and_a_usable_heap_pointer() {
    let mut session = session();
    assert_eq!(new_array(&mut session, 10), STATUS_CONTINUE);
    assert_ne!(session.context().result_word, 0);
    assert!(!session.context().heap_words_pointer.is_null());
    assert!(session.engine().fault().is_none());
}

#[test]
fn array_new_with_negative_extent_fails_with_negative_size() {
    let mut session = session();
    assert_eq!(new_array(&mut session, -1), STATUS_FAILED);
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::NegativeArraySize)
    );
    assert_eq!(session.context().fault_status, STATUS_FAILED);
}

#[test]
fn array_new_with_zero_extent_is_valid() {
    let mut session = session();
    assert_eq!(new_array(&mut session, 0), STATUS_CONTINUE);
}

#[test]
fn array_new_with_missing_extents_is_an_internal_fault() {
    let mut session = session();
    let status = rt_aot_array_new(
        session.context_pointer(),
        0,
        INTEGER_ARRAY_OF_RANK_ONE,
        std::ptr::null(),
    );
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn array_new_with_unknown_element_kind_is_an_internal_fault() {
    let mut session = session();
    let dimensions = [1_i64];
    let status = rt_aot_array_new(
        session.context_pointer(),
        0,
        99 | (1 << RANK_SHIFT),
        dimensions.as_ptr(),
    );
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn cell_budget_exhaustion_is_a_program_failure_when_everything_is_rooted() {
    let limits = AotLimits {
        cells: 64,
        ..AotLimits::default()
    };
    let mut session = session_with(limits, "");
    for _ in 0..3 {
        assert_eq!(new_array(&mut session, 20), STATUS_CONTINUE);
        let handle = u32::try_from(session.context().result_word).unwrap_or(0);
        assert!(session.push_root(handle));
    }
    assert_eq!(new_array(&mut session, 20), STATUS_FAILED);
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::CellLimitExceeded)
    );
}

#[test]
fn collection_reclaims_unrooted_arrays_and_keeps_rooted_ones() {
    let limits = AotLimits {
        cells: 64,
        ..AotLimits::default()
    };
    let mut session = session_with(limits, "");
    assert_eq!(new_array(&mut session, 20), STATUS_CONTINUE);
    let kept = u32::try_from(session.context().result_word).unwrap_or(0);
    assert!(session.push_root(kept));
    for _ in 0..12 {
        assert_eq!(new_array(&mut session, 20), STATUS_CONTINUE);
    }
    assert!(heap_live_cells(session.engine().heap()) <= 64);
    assert_eq!(
        session.engine().heap().reachable_cells(&[Handle(kept)]),
        Ok(21)
    );
}

#[test]
fn object_new_and_copy_use_the_registered_layout() {
    let mut session = session();
    assert_eq!(session.engine_mut().register_layout(layout()), Ok(()));
    assert_eq!(
        rt_aot_object_new(session.context_pointer(), 0, 0),
        STATUS_CONTINUE
    );
    let original = u32::try_from(session.context().result_word).unwrap_or(0);
    assert_eq!(
        rt_aot_object_copy(session.context_pointer(), 0, original),
        STATUS_CONTINUE
    );
    let copy = u32::try_from(session.context().result_word).unwrap_or(0);
    assert_ne!(original, copy);
}

#[test]
fn object_new_with_unregistered_class_is_an_internal_fault() {
    let mut session = session();
    assert_eq!(
        rt_aot_object_new(session.context_pointer(), 0, 4),
        STATUS_FAILED
    );
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn object_copy_of_a_non_object_handle_fails() {
    let mut session = session();
    assert_eq!(
        rt_aot_object_copy(session.context_pointer(), 0, 0),
        STATUS_FAILED
    );
}

#[test]
fn entry_points_reject_a_null_context() {
    assert_eq!(rt_aot_object_new(std::ptr::null_mut(), 0, 0), STATUS_FAILED);
}
