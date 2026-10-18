use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::Cursor;

fn session() -> AotSession {
    let mut session = AotSession::new(
        AotConfig {
            limits: AotLimits::default(),
            seed: 1,
            boolean_words: BooleanWords {
                truth: "true".to_owned(),
                falsity: "false".to_owned(),
            },
        },
        vec![FaultSite {
            code: DiagnosticCode::InternalFault,
            range: SourceRange::default(),
        }],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    );
    let descriptor = ClassDescriptor {
        fields: vec![KIND_INTEGER],
        dense: false,
    };
    assert!(session.engine_mut().register_class(0, &descriptor).is_ok());
    session
}

fn result(session: &AotSession) -> u64 {
    session.context().result_word
}

fn fault(session: &AotSession) -> Option<DiagnosticCode> {
    session.engine().fault().and_then(|record| record.code)
}

fn local(session: &mut AotSession, kind: u32) -> u32 {
    assert_eq!(
        rt_aot_cell_local(session.context_pointer(), 0, kind),
        STATUS_CONTINUE
    );
    u32::try_from(result(session)).unwrap_or(0)
}

fn array(session: &mut AotSession, extent: i64) -> u32 {
    let extents = [extent];
    let descriptor = KIND_INTEGER | (1 << RANK_SHIFT);
    let status = rt_aot_array_new(session.context_pointer(), 0, descriptor, extents.as_ptr());
    assert_eq!(status, STATUS_CONTINUE);
    u32::try_from(result(session)).unwrap_or(0)
}

#[test]
fn a_local_cell_starts_without_value_and_keeps_what_is_stored() {
    let mut session = session();
    let cell = local(&mut session, KIND_INTEGER);
    assert_eq!(
        rt_aot_cell_load(session.context_pointer(), 0, cell),
        STATUS_FAILED
    );
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
    let mut other = self::session();
    let target = local(&mut other, KIND_INTEGER);
    assert_eq!(
        rt_aot_cell_store(other.context_pointer(), 0, target, 0),
        STATUS_CONTINUE
    );
    assert_eq!(
        rt_aot_cell_load(other.context_pointer(), 0, target),
        STATUS_CONTINUE
    );
    assert_eq!(result(&other), 0);
}

#[test]
fn sentinel_kinds_report_the_unset_state_without_a_flag() {
    for kind in [KIND_REAL, KIND_BOOLEAN, KIND_CHARACTER, KIND_REFERENCE] {
        let mut session = session();
        let cell = local(&mut session, kind);
        assert_eq!(
            rt_aot_cell_load(session.context_pointer(), 0, cell),
            STATUS_FAILED
        );
        assert_eq!(
            fault(&session),
            Some(DiagnosticCode::UninitializedVariableRead)
        );
    }
}

#[test]
fn distinct_local_cells_do_not_alias() {
    let mut session = session();
    let first = local(&mut session, KIND_INTEGER);
    let second = local(&mut session, KIND_INTEGER);
    assert_ne!(first, second);
    assert_eq!(
        rt_aot_cell_store(session.context_pointer(), 0, first, 5),
        STATUS_CONTINUE
    );
    assert_eq!(
        rt_aot_cell_load(session.context_pointer(), 0, second),
        STATUS_FAILED
    );
}

#[test]
fn element_cells_observe_writes_made_through_the_array() {
    let mut session = session();
    let target = array(&mut session, 3);
    let indices = [1_i64];
    assert_eq!(
        rt_aot_cell_element(session.context_pointer(), 0, target, indices.as_ptr()),
        STATUS_CONTINUE
    );
    let cell = u32::try_from(result(&session)).unwrap_or(0);
    assert_eq!(
        rt_aot_cell_store(session.context_pointer(), 0, cell, 33),
        STATUS_CONTINUE
    );
    let operands = [1_i64];
    assert_eq!(
        rt_aot_array_load(session.context_pointer(), 0, target, operands.as_ptr()),
        STATUS_CONTINUE
    );
    assert_eq!(result(&session), 33);
}

#[test]
fn an_element_cell_outside_the_extent_is_out_of_range() {
    let mut session = session();
    let target = array(&mut session, 2);
    let indices = [2_i64];
    let status = rt_aot_cell_element(session.context_pointer(), 0, target, indices.as_ptr());
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault(&session), Some(DiagnosticCode::ArrayIndexOutOfRange));
}

#[test]
fn field_cells_read_and_write_the_object_field() {
    let mut session = session();
    assert_eq!(
        rt_aot_object_new(session.context_pointer(), 0, 0),
        STATUS_CONTINUE
    );
    let object = u32::try_from(result(&session)).unwrap_or(0);
    assert_eq!(
        rt_aot_cell_field(session.context_pointer(), 0, object, 0),
        STATUS_CONTINUE
    );
    let cell = u32::try_from(result(&session)).unwrap_or(0);
    assert_eq!(
        rt_aot_cell_store(session.context_pointer(), 0, cell, 8),
        STATUS_CONTINUE
    );
    assert_eq!(
        rt_aot_object_load(session.context_pointer(), 0, object, 0),
        STATUS_CONTINUE
    );
    assert_eq!(result(&session), 8);
}

#[test]
fn a_field_cell_for_a_missing_field_or_object_fails() {
    let mut session = session();
    assert_eq!(
        rt_aot_cell_field(session.context_pointer(), 0, 0, 0),
        STATUS_FAILED
    );
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
}

#[test]
fn unknown_cell_identifiers_are_internal_faults() {
    let mut session = session();
    assert_eq!(
        rt_aot_cell_load(session.context_pointer(), 0, 0),
        STATUS_FAILED
    );
    assert_eq!(fault(&session), Some(DiagnosticCode::InternalFault));
    let mut other = self::session();
    assert_eq!(
        rt_aot_cell_store(other.context_pointer(), 0, 9, 1),
        STATUS_FAILED
    );
}

#[test]
fn an_unknown_local_kind_is_an_internal_fault() {
    let mut session = session();
    assert_eq!(
        rt_aot_cell_local(session.context_pointer(), 0, 99),
        STATUS_FAILED
    );
    assert_eq!(fault(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn local_reference_cells_keep_their_text_alive_through_collection() {
    let limits = AotLimits {
        cells: 64,
        ..AotLimits::default()
    };
    let mut session = AotSession::new(
        AotConfig {
            limits,
            seed: 1,
            boolean_words: BooleanWords {
                truth: "true".to_owned(),
                falsity: "false".to_owned(),
            },
        },
        vec![FaultSite {
            code: DiagnosticCode::InternalFault,
            range: SourceRange::default(),
        }],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    );
    let cell = local(&mut session, KIND_REFERENCE);
    let bytes = *b"kept";
    let status = rt_aot_text_literal(session.context_pointer(), 0, bytes.as_ptr(), bytes.len());
    assert_eq!(status, STATUS_CONTINUE);
    let text = result(&session);
    assert_eq!(
        rt_aot_cell_store(session.context_pointer(), 0, cell, text),
        STATUS_CONTINUE
    );
    for _ in 0..6 {
        assert_ne!(array(&mut session, 20), 0);
    }
    assert_eq!(
        rt_aot_cell_load(session.context_pointer(), 0, cell),
        STATUS_CONTINUE
    );
    assert_eq!(result(&session), text);
    let query = rt_aot_text_query(session.context_pointer(), 0, TEXT_LENGTH, text);
    assert_eq!(query, STATUS_CONTINUE);
    assert_eq!(result(&session), 4);
}
