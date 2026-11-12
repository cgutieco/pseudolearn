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

fn integer_result(session: &AotSession) -> i64 {
    i64::from_ne_bytes(session.context().result_word.to_ne_bytes())
}

fn fault_code(session: &AotSession) -> Option<DiagnosticCode> {
    session.engine().fault().and_then(|record| record.code)
}

#[test]
fn random_below_follows_the_unbiased_seeded_generator() {
    let mut session = session();
    let mut reference = RandomState::seeded(7);
    for bound in [1_i64, 2, 6, 1_000, i64::MAX] {
        assert_eq!(
            rt_aot_random_below(session.context_pointer(), 0, bound),
            STATUS_CONTINUE
        );
        let expected = reference
            .next_below(u64::try_from(bound).unwrap_or(1))
            .and_then(|value| i64::try_from(value).ok());
        assert_eq!(Some(integer_result(&session)), expected);
    }
}

#[test]
fn random_between_follows_the_seeded_generator_inclusively() {
    let mut session = session();
    let mut reference = RandomState::seeded(7);
    for (low, high) in [(1_i64, 6_i64), (-3, -3), (-5, 5), (i64::MIN, i64::MAX)] {
        assert_eq!(
            rt_aot_random_between(session.context_pointer(), 0, low, high),
            STATUS_CONTINUE
        );
        assert_eq!(
            Some(integer_result(&session)),
            reference.next_between(low, high)
        );
        assert!((low..=high).contains(&integer_result(&session)));
    }
}

#[test]
fn random_below_traps_on_a_bound_below_one() {
    for bound in [0_i64, -1, i64::MIN] {
        let mut session = session();
        assert_ne!(
            rt_aot_random_below(session.context_pointer(), 0, bound),
            STATUS_CONTINUE
        );
        assert_eq!(
            fault_code(&session),
            Some(DiagnosticCode::InvalidRandomBound)
        );
    }
}

#[test]
fn random_between_traps_on_an_inverted_range() {
    let mut session = session();
    assert_ne!(
        rt_aot_random_between(session.context_pointer(), 0, 2, 1),
        STATUS_CONTINUE
    );
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::InvalidRandomRange)
    );
}

#[test]
fn random_integers_reject_a_null_context() {
    assert_eq!(
        rt_aot_random_below(std::ptr::null_mut(), 0, 3),
        STATUS_FAILED
    );
    assert_eq!(
        rt_aot_random_between(std::ptr::null_mut(), 0, 1, 3),
        STATUS_FAILED
    );
}
