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

fn unary(session: &mut AotSession, operation: u32, operand: f64) -> u32 {
    rt_aot_math_unary(session.context_pointer(), 0, operation, operand.to_bits())
}

fn real_result(session: &AotSession) -> f64 {
    f64::from_bits(session.context().result_word)
}

#[test]
fn transcendental_results_come_from_the_library() {
    let mut session = session();
    assert_eq!(unary(&mut session, MATH_SINE, 0.0), STATUS_CONTINUE);
    assert_eq!(real_result(&session), 0.0);
    assert_eq!(unary(&mut session, MATH_COSINE, 0.0), STATUS_CONTINUE);
    assert_eq!(real_result(&session), 1.0);
    assert_eq!(unary(&mut session, MATH_EXPONENTIAL, 0.0), STATUS_CONTINUE);
    assert_eq!(real_result(&session), 1.0);
    assert_eq!(unary(&mut session, MATH_LOGARITHM, 1.0), STATUS_CONTINUE);
    assert_eq!(real_result(&session), 0.0);
    assert_eq!(unary(&mut session, MATH_ARCTANGENT, 0.0), STATUS_CONTINUE);
    assert_eq!(real_result(&session), 0.0);
}

#[test]
fn rounding_operations_return_integers() {
    let mut session = session();
    assert_eq!(unary(&mut session, MATH_TRUNCATE, -3.9), STATUS_CONTINUE);
    assert_eq!(
        i64::from_ne_bytes(session.context().result_word.to_ne_bytes()),
        -3
    );
    assert_eq!(unary(&mut session, MATH_ROUND, 2.6), STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 3);
}

#[test]
fn logarithm_of_a_negative_number_is_a_domain_failure() {
    let mut session = session();
    assert_eq!(unary(&mut session, MATH_LOGARITHM, -1.0), STATUS_FAILED);
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::NonFiniteRealResult)
    );
}

#[test]
fn library_fault_preserves_the_fault_sites_source_identifier() {
    let mut fault_site = site(DiagnosticCode::NonFiniteRealResult);
    fault_site.range.source_id = 9;
    let mut session = session_with(vec![fault_site], "");
    assert_eq!(unary(&mut session, MATH_LOGARITHM, -1.0), STATUS_FAILED);
    assert_eq!(
        session
            .engine()
            .fault()
            .map(|record| record.range.source_id),
        Some(9)
    );
}

#[test]
fn truncation_outside_the_integer_range_fails() {
    let mut session = session();
    assert_eq!(unary(&mut session, MATH_TRUNCATE, 1.0e300), STATUS_FAILED);
}

#[test]
fn unknown_operation_is_an_internal_fault() {
    let mut session = session();
    assert_eq!(unary(&mut session, 99, 1.0), STATUS_FAILED);
    assert_eq!(fault_code(&session), Some(DiagnosticCode::InternalFault));
}

#[test]
fn power_matches_exact_integers_and_rejects_non_finite_results() {
    let mut session = session();
    let status = rt_aot_real_power(
        session.context_pointer(),
        0,
        2.0_f64.to_bits(),
        10.0_f64.to_bits(),
    );
    assert_eq!(status, STATUS_CONTINUE);
    assert_eq!(real_result(&session), 1024.0);
    let overflow = rt_aot_real_power(
        session.context_pointer(),
        0,
        10.0_f64.to_bits(),
        400.0_f64.to_bits(),
    );
    assert_eq!(overflow, STATUS_FAILED);
}

#[test]
fn integer_power_is_exact_and_traps_on_negative_exponents_and_overflow() {
    let mut session = session();
    let status = rt_aot_integer_power(session.context_pointer(), 0, 3, 4);
    assert_eq!(status, STATUS_CONTINUE);
    assert_eq!(session.context().result_word, 81);
    assert_eq!(
        rt_aot_integer_power(session.context_pointer(), 0, 2, -1),
        STATUS_FAILED
    );
    assert_eq!(
        fault_code(&session),
        Some(DiagnosticCode::NegativeIntegerExponent)
    );
    assert_eq!(
        rt_aot_integer_power(session.context_pointer(), 0, 2, 64),
        STATUS_FAILED
    );
}
