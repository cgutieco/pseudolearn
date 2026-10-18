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

use std::cell::RefCell;
use std::io::Write;
use std::rc::Rc;

#[derive(Clone, Default)]
struct SharedSink(Rc<RefCell<Vec<u8>>>);

impl Write for SharedSink {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        self.0.borrow_mut().extend_from_slice(bytes);
        Ok(bytes.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

struct BrokenSink;

impl Write for BrokenSink {
    fn write(&mut self, _bytes: &[u8]) -> std::io::Result<usize> {
        Err(std::io::Error::other("closed"))
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

fn session_writing_to(sink: Box<dyn Write>) -> AotSession {
    AotSession::new(
        config(),
        vec![site(DiagnosticCode::InternalFault)],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: sink,
        },
    )
}

fn written(sink: &SharedSink) -> String {
    String::from_utf8_lossy(&sink.0.borrow()).into_owned()
}

#[test]
fn values_are_written_in_call_order_with_optional_newlines() {
    let sink = SharedSink::default();
    let mut session = session_writing_to(Box::new(sink.clone()));
    let pointer = session.context_pointer();
    assert_eq!(rt_aot_write(pointer, 0, 7, KIND_INTEGER), STATUS_CONTINUE);
    assert_eq!(rt_aot_write(pointer, 0, 1, KIND_BOOLEAN), STATUS_CONTINUE);
    assert_eq!(
        rt_aot_write(pointer, 0, 2.5_f64.to_bits(), KIND_REAL | NEWLINE_FLAG),
        STATUS_CONTINUE
    );
    assert_eq!(written(&sink), "7verdadero2.5\n");
}

#[test]
fn writing_a_non_finite_real_fails_without_output() {
    let sink = SharedSink::default();
    let mut session = session_writing_to(Box::new(sink.clone()));
    let status = rt_aot_write(
        session.context_pointer(),
        0,
        f64::INFINITY.to_bits(),
        KIND_REAL,
    );
    assert_eq!(status, STATUS_FAILED);
    assert_eq!(written(&sink), "");
}

#[test]
fn an_unknown_kind_is_an_internal_fault() {
    let mut session = session_writing_to(Box::new(SharedSink::default()));
    assert_eq!(
        rt_aot_write(session.context_pointer(), 0, 1, 42),
        STATUS_FAILED
    );
    let code = session.engine().fault().and_then(|record| record.code);
    assert_eq!(code, Some(DiagnosticCode::InternalFault));
}

#[test]
fn a_closed_output_stream_is_reported_as_an_internal_fault() {
    let mut session = session_writing_to(Box::new(BrokenSink));
    assert_eq!(
        rt_aot_write(session.context_pointer(), 0, 1, KIND_INTEGER),
        STATUS_FAILED
    );
    let code = session.engine().fault().and_then(|record| record.code);
    assert_eq!(code, Some(DiagnosticCode::InternalFault));
}

#[test]
fn flush_reaches_the_underlying_stream() {
    let mut session = session_writing_to(Box::new(SharedSink::default()));
    assert!(session.engine_mut().flush_output().is_ok());
}
