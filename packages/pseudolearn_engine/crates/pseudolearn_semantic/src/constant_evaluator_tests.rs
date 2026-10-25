use crate::constant_registry::ConstantLimits;
use crate::session::{AnalysisSession, SemanticOptions};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

fn diagnostics_with(text: &str, limits: ConstantLimits) -> Vec<DiagnosticCode> {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, Profile::English);
    let mut session = AnalysisSession::new(
        &tree,
        &source,
        SemanticOptions {
            profile: Profile::English,
            strict: false,
        },
    );
    session.constant_limits = limits;
    crate::unit_resolver::register(&mut session);
    session
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

const CHAIN: &str = "constant A as integer <- 1 + 2 + 3;\nalgorithm P\nendAlgorithm\n";

fn limits(steps: u32, text_bytes: usize) -> ConstantLimits {
    ConstantLimits { steps, text_bytes }
}

#[test]
fn step_budget_accepts_the_exact_cost() {
    assert!(diagnostics_with(CHAIN, limits(5, 100)).is_empty());
}

#[test]
fn step_budget_rejects_one_step_less() {
    assert_eq!(
        diagnostics_with(CHAIN, limits(4, 100)),
        vec![DiagnosticCode::ConstantBudgetExceeded]
    );
}

#[test]
fn text_budget_accepts_exact_length_and_rejects_longer() {
    let program = "constant S as string <- \"ab\" + \"cd\";\nalgorithm P\nendAlgorithm\n";
    assert!(diagnostics_with(program, limits(100, 4)).is_empty());
    assert_eq!(
        diagnostics_with(program, limits(100, 3)),
        vec![DiagnosticCode::ConstantBudgetExceeded]
    );
}

#[test]
fn zero_step_budget_rejects_every_initializer() {
    assert_eq!(
        diagnostics_with(CHAIN, limits(0, 100)),
        vec![DiagnosticCode::ConstantBudgetExceeded]
    );
}

#[test]
fn evaluation_order_does_not_change_cycle_reporting() {
    let forward =
        "constant A as integer <- B;\nconstant B as integer <- A;\nalgorithm P\nendAlgorithm\n";
    let backward =
        "constant B as integer <- A;\nconstant A as integer <- B;\nalgorithm P\nendAlgorithm\n";
    for program in [forward, backward] {
        assert_eq!(
            diagnostics_with(program, ConstantLimits::default()),
            vec![DiagnosticCode::CircularConstantDefinition]
        );
    }
}

#[test]
fn dependent_of_failed_constant_adds_no_second_diagnostic() {
    let program = "constant A as integer <- 1 div 0;\nconstant B as integer <- A + 1;\nalgorithm P\nendAlgorithm\n";
    assert_eq!(
        diagnostics_with(program, ConstantLimits::default()),
        vec![DiagnosticCode::ConstantDivisionByZero]
    );
}

#[test]
fn short_circuit_hides_failures_of_the_untaken_side() {
    let program = "constant A as boolean <- false and (1 div 0 = 0);\nconstant B as boolean <- true or (1 div 0 = 0);\nalgorithm P\nendAlgorithm\n";
    assert!(diagnostics_with(program, ConstantLimits::default()).is_empty());
}

#[test]
fn integer_arithmetic_is_checked_at_the_boundaries() {
    let maximum = "constant A as integer <- 9223372036854775807;\nconstant B as integer <- A - 1;\nalgorithm P\nendAlgorithm\n";
    assert!(diagnostics_with(maximum, ConstantLimits::default()).is_empty());
    let overflow = "constant A as integer <- 9223372036854775807 * 2;\nalgorithm P\nendAlgorithm\n";
    assert_eq!(
        diagnostics_with(overflow, ConstantLimits::default()),
        vec![DiagnosticCode::ConstantArithmeticOverflow]
    );
    let minimum_division = "constant A as integer <- (0 - 9223372036854775807 - 1) div (0 - 1);\nalgorithm P\nendAlgorithm\n";
    assert_eq!(
        diagnostics_with(minimum_division, ConstantLimits::default()),
        vec![DiagnosticCode::ConstantArithmeticOverflow]
    );
    let minimum_modulo = "constant A as integer <- (0 - 9223372036854775807 - 1) mod (0 - 1);\nalgorithm P\nendAlgorithm\n";
    assert!(diagnostics_with(minimum_modulo, ConstantLimits::default()).is_empty());
}

#[test]
fn modulo_by_zero_and_real_division_by_zero_fail() {
    for program in [
        "constant A as integer <- 5 mod 0;\nalgorithm P\nendAlgorithm\n",
        "constant A as real <- 5.0 / 0.0;\nalgorithm P\nendAlgorithm\n",
    ] {
        assert_eq!(
            diagnostics_with(program, ConstantLimits::default()),
            vec![DiagnosticCode::ConstantDivisionByZero]
        );
    }
}
