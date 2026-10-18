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
            lexeme: String::new(),
            code: DiagnosticCode::InternalFault,
            range: SourceRange::default(),
        }],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    );
    let descriptor = ClassDescriptor {
        fields: vec![KIND_INTEGER, KIND_REAL, KIND_REFERENCE],
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

fn new_array(session: &mut AotSession, kind: u32, extents: &[i64]) -> u32 {
    let rank = u32::try_from(extents.len()).unwrap_or(0);
    let status = rt_aot_array_new(
        session.context_pointer(),
        0,
        kind | (rank << RANK_SHIFT),
        extents.as_ptr(),
    );
    assert_eq!(status, STATUS_CONTINUE);
    u32::try_from(result(session)).unwrap_or(0)
}

fn new_object(session: &mut AotSession) -> u32 {
    assert_eq!(
        rt_aot_object_new(session.context_pointer(), 0, 0),
        STATUS_CONTINUE
    );
    u32::try_from(result(session)).unwrap_or(0)
}

fn store(session: &mut AotSession, array: u32, operands: &[i64]) -> u32 {
    rt_aot_array_store(session.context_pointer(), 0, array, operands.as_ptr())
}

fn load(session: &mut AotSession, array: u32, indices: &[i64]) -> u32 {
    rt_aot_array_load(session.context_pointer(), 0, array, indices.as_ptr())
}

#[test]
fn stored_integer_elements_are_read_back() {
    let mut session = session();
    let array = new_array(&mut session, KIND_INTEGER, &[4]);
    assert_eq!(store(&mut session, array, &[2, 41]), STATUS_CONTINUE);
    assert_eq!(load(&mut session, array, &[2]), STATUS_CONTINUE);
    assert_eq!(result(&session), 41);
}

#[test]
fn multidimensional_elements_use_row_major_positions() {
    let mut session = session();
    let array = new_array(&mut session, KIND_INTEGER, &[2, 3]);
    assert_eq!(store(&mut session, array, &[1, 2, 7]), STATUS_CONTINUE);
    assert_eq!(store(&mut session, array, &[0, 2, 9]), STATUS_CONTINUE);
    assert_eq!(load(&mut session, array, &[1, 2]), STATUS_CONTINUE);
    assert_eq!(result(&session), 7);
    assert_eq!(load(&mut session, array, &[0, 2]), STATUS_CONTINUE);
    assert_eq!(result(&session), 9);
}

#[test]
fn reading_an_unassigned_element_is_an_uninitialized_read() {
    let mut session = session();
    let array = new_array(&mut session, KIND_INTEGER, &[3]);
    assert_eq!(load(&mut session, array, &[1]), STATUS_FAILED);
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
}

#[test]
fn an_index_outside_the_extent_is_out_of_range_for_load_and_store() {
    let mut session = session();
    let array = new_array(&mut session, KIND_REAL, &[3]);
    assert_eq!(load(&mut session, array, &[3]), STATUS_FAILED);
    assert_eq!(fault(&session), Some(DiagnosticCode::ArrayIndexOutOfRange));
    let mut other = self::session();
    let second = new_array(&mut other, KIND_REAL, &[3]);
    assert_eq!(store(&mut other, second, &[-1, 0]), STATUS_FAILED);
    assert_eq!(fault(&other), Some(DiagnosticCode::ArrayIndexOutOfRange));
}

#[test]
fn an_absent_array_handle_is_an_uninitialized_read() {
    let mut session = session();
    assert_eq!(load(&mut session, 0, &[0]), STATUS_FAILED);
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
}

#[test]
fn missing_operand_buffers_are_internal_faults() {
    let mut session = session();
    let array = new_array(&mut session, KIND_INTEGER, &[3]);
    let status = rt_aot_array_load(session.context_pointer(), 0, array, std::ptr::null());
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn zero_length_arrays_reject_every_index() {
    let mut session = session();
    let array = new_array(&mut session, KIND_INTEGER, &[0]);
    assert_eq!(load(&mut session, array, &[0]), STATUS_FAILED);
    assert_eq!(fault(&session), Some(DiagnosticCode::ArrayIndexOutOfRange));
}

#[test]
fn object_fields_round_trip_and_start_without_value() {
    let mut session = session();
    let object = new_object(&mut session);
    let status = rt_aot_object_load(session.context_pointer(), 0, object, 1);
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
    let mut other = self::session();
    let target = new_object(&mut other);
    let operands = [1_u64, 2.5_f64.to_bits()];
    let stored = rt_aot_object_store(other.context_pointer(), 0, target, operands.as_ptr());
    assert_eq!(stored, STATUS_CONTINUE);
    assert_eq!(
        rt_aot_object_load(other.context_pointer(), 0, target, 1),
        STATUS_CONTINUE
    );
    assert_eq!(f64::from_bits(result(&other)), 2.5);
}

#[test]
fn object_access_through_an_absent_handle_or_bad_field_fails() {
    let mut session = session();
    let status = rt_aot_object_load(session.context_pointer(), 0, 0, 0);
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(
        fault(&session),
        Some(DiagnosticCode::UninitializedVariableRead)
    );
    let mut other = self::session();
    let object = new_object(&mut other);
    assert_eq!(
        rt_aot_object_load(other.context_pointer(), 0, object, 9),
        STATUS_FAILED
    );
    let operands = [9_u64, 1];
    let status = rt_aot_object_store(other.context_pointer(), 0, object, operands.as_ptr());
    assert_eq!(status, STATUS_FAILED);
}

#[test]
fn object_store_without_operands_is_an_internal_fault() {
    let mut session = session();
    let object = new_object(&mut session);
    let status = rt_aot_object_store(session.context_pointer(), 0, object, std::ptr::null());
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn registering_a_class_with_an_unknown_kind_is_rejected() {
    let mut session = session();
    let descriptor = ClassDescriptor {
        fields: vec![77],
        dense: true,
    };
    assert!(session.engine_mut().register_class(1, &descriptor).is_err());
}
