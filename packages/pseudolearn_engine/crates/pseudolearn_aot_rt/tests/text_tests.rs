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

fn session_with(sites: Vec<FaultSite>, input: &str) -> AotSession {
    AotSession::new(
        AotConfig {
            limits: AotLimits::default(),
            seed: 7,
            boolean_words: BooleanWords {
                truth: "verdadero".to_owned(),
                falsity: "falso".to_owned(),
            },
        },
        sites,
        AotStreams {
            input: Box::new(Cursor::new(input.as_bytes().to_vec())),
            output: Box::new(std::io::sink()),
        },
    )
}

fn session() -> AotSession {
    session_with(vec![site(DiagnosticCode::InternalFault)], "")
}

fn fault_code(session: &AotSession) -> Option<DiagnosticCode> {
    session.engine().fault().and_then(|record| record.code)
}

use pseudolearn_abi::Handle;
use pseudolearn_runtime::text_content;

fn literal(session: &mut AotSession, content: &str) -> u64 {
    let status = rt_aot_text_literal(
        session.context_pointer(),
        0,
        content.as_ptr(),
        content.len(),
    );
    assert_eq!(status, STATUS_CONTINUE);
    session.context().result_word
}

fn content_of(session: &AotSession, word: u64) -> String {
    let handle = Handle(u32::try_from(word).unwrap_or(0));
    text_content(session.engine().heap(), handle)
        .unwrap_or("")
        .to_owned()
}

#[test]
fn literal_text_round_trips_through_the_heap() {
    let mut session = session();
    let word = literal(&mut session, "héllo");
    assert_eq!(content_of(&session, word), "héllo");
}

#[test]
fn empty_literal_accepts_a_null_pointer() {
    let mut session = session();
    let status = rt_aot_text_literal(session.context_pointer(), 0, std::ptr::null(), 0);
    assert_eq!(status, STATUS_CONTINUE);
}

#[test]
fn non_empty_literal_with_null_pointer_is_an_internal_fault() {
    let mut session = session();
    let status = rt_aot_text_literal(session.context_pointer(), 0, std::ptr::null(), 3);
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn literal_with_invalid_utf8_is_an_internal_fault() {
    let mut session = session();
    let bytes = [0xff_u8, 0xfe];
    let status = rt_aot_text_literal(session.context_pointer(), 0, bytes.as_ptr(), bytes.len());
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn concat_joins_text_and_characters() {
    let mut session = session();
    let left = literal(&mut session, "ab");
    let status = rt_aot_text_concat(
        session.context_pointer(),
        0,
        left,
        u64::from(u32::from('z')) | CHARACTER_OPERAND_FLAG,
    );
    assert_eq!(status, STATUS_CONTINUE);
    assert_eq!(content_of(&session, session.context().result_word), "abz");
}

#[test]
fn concat_rejects_an_invalid_character_operand() {
    let mut session = session();
    let left = literal(&mut session, "ab");
    let status = rt_aot_text_concat(
        session.context_pointer(),
        0,
        left,
        0xd800 | CHARACTER_OPERAND_FLAG,
    );
    assert_eq!(status, STATUS_FAILED);
}

#[test]
fn format_renders_each_primitive_kind() {
    let mut session = session();
    let cases = [
        (
            u64::from_ne_bytes((-42_i64).to_ne_bytes()),
            KIND_INTEGER,
            "-42",
        ),
        (1.0_f64.to_bits(), KIND_REAL, "1.0"),
        (1, KIND_BOOLEAN, "verdadero"),
        (0, KIND_BOOLEAN, "falso"),
        (u64::from(u32::from('ñ')), KIND_CHARACTER, "ñ"),
    ];
    for (word, kind, expected) in cases {
        let status = rt_aot_text_format(session.context_pointer(), 0, word, kind);
        assert_eq!(status, STATUS_CONTINUE);
        assert_eq!(
            content_of(&session, session.context().result_word),
            expected
        );
    }
}

#[test]
fn format_of_a_non_finite_real_fails() {
    let mut session = session_with(vec![site(DiagnosticCode::InternalFault)], "");
    let status = rt_aot_text_format(session.context_pointer(), 0, f64::NAN.to_bits(), KIND_REAL);
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::NonFiniteRealResult)
    );
}

#[test]
fn query_reports_length_in_code_points_and_parses_numbers() {
    let mut session = session();
    let word = literal(&mut session, "añb");
    assert_eq!(
        rt_aot_text_query(session.context_pointer(), 0, TEXT_LENGTH, word),
        STATUS_CONTINUE
    );
    assert_eq!(session.context().result_word, 3);
    let number = literal(&mut session, "123");
    assert_eq!(
        rt_aot_text_query(session.context_pointer(), 0, TEXT_TO_INTEGER, number),
        STATUS_CONTINUE
    );
    assert_eq!(session.context().result_word, 123);
    let real = literal(&mut session, "2.5");
    assert_eq!(
        rt_aot_text_query(session.context_pointer(), 0, TEXT_TO_REAL, real),
        STATUS_CONTINUE
    );
    assert_eq!(f64::from_bits(session.context().result_word), 2.5);
}

#[test]
fn query_conversion_of_malformed_text_fails() {
    let mut session = session();
    let word = literal(&mut session, "abc");
    let status = rt_aot_text_query(session.context_pointer(), 0, TEXT_TO_INTEGER, word);
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::StringToNumberConversionFailed)
    );
}

#[test]
fn query_with_unknown_operation_is_an_internal_fault() {
    let mut session = session();
    let word = literal(&mut session, "abc");
    assert_eq!(
        rt_aot_text_query(session.context_pointer(), 0, 77, word),
        STATUS_FAILED
    );
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn character_access_uses_the_position_the_ir_delivers_and_is_bounded() {
    let mut session = session();
    let word = literal(&mut session, "añ");
    assert_eq!(
        rt_aot_text_character(session.context_pointer(), 0, word, 1),
        STATUS_CONTINUE
    );
    assert_eq!(session.context().result_word, u64::from(u32::from('ñ')));
    for position in [2, 3, -1] {
        let status = rt_aot_text_character(session.context_pointer(), 0, word, position);
        assert_eq!(status, STATUS_FAILED);
    }
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::StringPositionOutOfRange)
    );
}

#[test]
fn compare_returns_the_sign_of_the_ordering() {
    let mut session = session();
    let low = literal(&mut session, "a");
    let high = literal(&mut session, "b");
    let sign = |session: &mut AotSession, left: u64, right: u64| {
        let status = rt_aot_text_compare(session.context_pointer(), 0, left, right);
        assert_eq!(status, STATUS_CONTINUE);
        i64::from_ne_bytes(session.context().result_word.to_ne_bytes())
    };
    assert_eq!(sign(&mut session, low, high), -1);
    assert_eq!(sign(&mut session, high, low), 1);
    assert_eq!(sign(&mut session, low, low), 0);
}

#[test]
fn comparison_accepts_character_operands_marked_with_the_flag() {
    let mut session = session();
    let word = literal(&mut session, "b");
    let sign = |session: &mut AotSession, left: u64, right: u64| {
        let status = rt_aot_text_compare(session.context_pointer(), 0, left, right);
        assert_eq!(status, STATUS_CONTINUE);
        i64::from_ne_bytes(session.context().result_word.to_ne_bytes())
    };
    let low = u64::from(u32::from('a')) | CHARACTER_OPERAND_FLAG;
    let high = u64::from(u32::from('c')) | CHARACTER_OPERAND_FLAG;
    assert_eq!(sign(&mut session, word, low), 1);
    assert_eq!(sign(&mut session, low, word), -1);
    assert_eq!(sign(&mut session, low, high), -1);
    assert_eq!(sign(&mut session, high, high), 0);
    let same = u64::from(u32::from('b')) | CHARACTER_OPERAND_FLAG;
    assert_eq!(sign(&mut session, word, same), 0);
}

#[test]
fn comparison_with_an_invalid_character_is_an_internal_fault() {
    let mut session = session();
    let word = literal(&mut session, "b");
    let invalid = 0xD800_u64 | CHARACTER_OPERAND_FLAG;
    let status = rt_aot_text_compare(session.context_pointer(), 0, word, invalid);
    assert_eq!(status, STATUS_FAILED);
}
