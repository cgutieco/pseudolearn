use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::Cursor;

fn site(code: DiagnosticCode) -> FaultSite {
    FaultSite {
        lexeme: String::new(),
        code,
        range: SourceRange {
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

use pseudolearn_abi::Handle;
use pseudolearn_runtime::text_content;

fn session_reading(input: &str) -> AotSession {
    AotSession::new(
        config(),
        vec![site(DiagnosticCode::InternalFault)],
        AotStreams {
            input: Box::new(Cursor::new(input.as_bytes().to_vec())),
            output: Box::new(std::io::sink()),
        },
    )
}

fn read(session: &mut AotSession, kind: u32) -> u32 {
    rt_aot_read(session.context_pointer(), 0, kind)
}

#[test]
fn each_read_consumes_one_line_in_order() {
    let mut session = session_reading("12\n  -3  \n");
    assert_eq!(read(&mut session, KIND_INTEGER), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 12);
    assert_eq!(read(&mut session, KIND_INTEGER), STATUS_CONTINUE);
    assert_eq!(
        i64::from_ne_bytes(session.context().result_word.to_ne_bytes()),
        -3
    );
}

#[test]
fn reals_booleans_and_characters_are_converted() {
    let mut session = session_reading("2.5\nVERDADERO\nfalse\nx\r\n");
    assert_eq!(read(&mut session, KIND_REAL), STATUS_CONTINUE);
    assert_eq!(f64::from_bits(session.context().result_word), 2.5);
    assert_eq!(read(&mut session, KIND_BOOLEAN), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 1);
    assert_eq!(read(&mut session, KIND_BOOLEAN), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 0);
    assert_eq!(read(&mut session, KIND_CHARACTER), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, u64::from(u32::from('x')));
}

#[test]
fn text_lines_are_stored_verbatim_without_the_line_terminator() {
    let mut session = session_reading("  hola mundo \r\n");
    assert_eq!(read(&mut session, KIND_REFERENCE), STATUS_CONTINUE);
    let handle = Handle(u32::try_from(session.context().result_word).unwrap_or(0));
    assert_eq!(
        text_content(session.engine().heap(), handle),
        Ok("  hola mundo ")
    );
}

#[test]
fn a_mismatched_line_is_consumed_noted_and_the_read_is_repeated() {
    let mut session = session_reading("abc\n9\n");
    assert_eq!(read(&mut session, KIND_INTEGER), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 9);
    let notices = session.engine().notices();
    assert_eq!(notices.len(), 1);
    let notice = notices.first();
    assert_eq!(
        notice.map(|record| record.code),
        Some(Some(DiagnosticCode::ReadValueTypeMismatch))
    );
    assert_eq!(
        notice.map(|record| record.arguments.clone()),
        Some(vec![
            ("expected".to_owned(), "Entero".to_owned()),
            ("found".to_owned(), "abc".to_owned())
        ])
    );
    assert!(session.engine().fault().is_none());
}

#[test]
fn a_character_read_rejects_longer_lines() {
    let mut session = session_reading("ab\nc\n");
    assert_eq!(read(&mut session, KIND_CHARACTER), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, u64::from(u32::from('c')));
    assert_eq!(session.engine().notices().len(), 1);
}

#[test]
fn exhausted_input_reaches_the_resource_limit_status_without_a_code() {
    let mut session = session_reading("");
    assert_eq!(read(&mut session, KIND_INTEGER), STATUS_LIMIT);
    let record = session.engine().fault();
    assert_eq!(record.map(|fault| fault.code), Some(None));
    assert_eq!(session.context().fault_status, STATUS_LIMIT);
}

#[test]
fn input_that_ends_after_only_mismatches_is_exhausted() {
    let mut session = session_reading("x\ny\n");
    assert_eq!(read(&mut session, KIND_REAL), STATUS_LIMIT);
    assert_eq!(session.engine().notices().len(), 2);
}

#[test]
fn an_unknown_kind_is_an_internal_fault() {
    let mut session = session_reading("1\n");
    assert_eq!(read(&mut session, 9), STATUS_FAILED);
}
