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

use pseudolearn_runtime::RandomState;

#[test]
fn random_real_follows_the_seeded_generator() {
    let mut session = session();
    let mut reference = RandomState::seeded(7);
    for _ in 0..5 {
        assert_eq!(
            rt_aot_random_real(session.context_pointer(), 0),
            STATUS_CONTINUE
        );
        assert_eq!(
            session.context().result_word,
            reference.next_real().to_bits()
        );
    }
}

#[test]
fn random_real_stays_in_the_unit_interval() {
    let mut session = session();
    for _ in 0..100 {
        assert_eq!(
            rt_aot_random_real(session.context_pointer(), 0),
            STATUS_CONTINUE
        );
        let value = f64::from_bits(session.context().result_word);
        assert!((0.0..1.0).contains(&value));
    }
}

#[test]
fn random_real_rejects_a_null_context() {
    assert_eq!(rt_aot_random_real(std::ptr::null_mut(), 0), STATUS_FAILED);
}
