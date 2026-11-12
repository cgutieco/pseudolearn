use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @add(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.add %0, %1 @3:5-3:9
  return %2
}
func @mul(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.mul %0, %1 @4:5-4:9
  return %2
}
func @div(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.div %0, %1 @5:5-5:9
  return %2
}
func @neg(%0: f64) -> f64 {
b0() mass 0:
  %1 = real.neg %0
  return %1
}
func @pow(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.pow %0, %1 @7:5-7:9
  return %2
}
func @equal(%0: f64, %1: f64) -> bool {
b0() mass 0:
  %2 = real.cmp eq, %0, %1
  return %2
}
func @trunc(%0: f64) -> i64 {
b0() mass 0:
  %1 = real.trunc %0 @9:5-9:9
  return %1
}
func @round(%0: f64) -> i64 {
b0() mass 0:
  %1 = real.round %0 @10:5-10:9
  return %1
}
";

const ADD: usize = 0;
const MULTIPLY: usize = 1;
const DIVIDE: usize = 2;
const NEGATE: usize = 3;
const POWER: usize = 4;
const EQUAL: usize = 5;
const TRUNCATE: usize = 6;
const ROUND: usize = 7;

fn signature(parameters: usize, returns: Kind) -> Signature {
    Signature {
        parameters: vec![Kind::Real; parameters],
        returns,
    }
}

fn signatures() -> Vec<Signature> {
    vec![
        signature(2, Kind::Real),
        signature(2, Kind::Real),
        signature(2, Kind::Real),
        signature(1, Kind::Real),
        signature(2, Kind::Real),
        signature(2, Kind::Boolean),
        signature(1, Kind::Integer),
        signature(1, Kind::Integer),
    ]
}

fn run(function: usize, arguments: &[&str]) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(&Call::with(function, arguments))
}

#[test]
fn arithmetic_follows_ieee_rounding() -> Result<(), Failure> {
    expect_value(&run(ADD, &["0.1", "0.2"])?, "0.30000000000000004")?;
    expect_value(&run(MULTIPLY, &["1.5", "4.0"])?, "6.0")?;
    expect_value(&run(DIVIDE, &["1.0", "4.0"])?, "0.25")
}

#[test]
fn overflowing_results_trap_as_non_finite() -> Result<(), Failure> {
    expect_fault(
        &run(MULTIPLY, &["1e308", "10.0"])?,
        1,
        "nonFiniteRealResult",
        "4:5-4:9",
    )?;
    expect_fault(
        &run(ADD, &["1.7976931348623157e308", "1.7976931348623157e308"])?,
        1,
        "nonFiniteRealResult",
        "3:5-3:9",
    )
}

#[test]
fn division_by_either_zero_traps_before_the_result_check() -> Result<(), Failure> {
    expect_fault(
        &run(DIVIDE, &["1.0", "0.0"])?,
        1,
        "divisionByZero",
        "5:5-5:9",
    )?;
    expect_fault(
        &run(DIVIDE, &["1.0", "-0.0"])?,
        1,
        "divisionByZero",
        "5:5-5:9",
    )?;
    expect_fault(
        &run(DIVIDE, &["1e308", "1e-308"])?,
        1,
        "nonFiniteRealResult",
        "5:5-5:9",
    )
}

#[test]
fn negation_flips_the_sign_bit_and_never_traps() -> Result<(), Failure> {
    expect_value(&run(NEGATE, &["2.5"])?, "-2.5")?;
    expect_value(&run(NEGATE, &["0.0"])?, "-0.0")
}

#[test]
fn power_delegates_to_the_library() -> Result<(), Failure> {
    expect_value(&run(POWER, &["2.0", "10.0"])?, "1024.0")?;
    expect_fault(
        &run(POWER, &["10.0", "400.0"])?,
        1,
        "nonFiniteRealResult",
        "7:5-7:9",
    )
}

#[test]
fn comparison_treats_signed_zeros_as_equal() -> Result<(), Failure> {
    expect_value(&run(EQUAL, &["0.0", "-0.0"])?, "1")?;
    expect_value(&run(EQUAL, &["1.0", "2.0"])?, "0")
}

#[test]
fn truncation_goes_toward_zero_and_traps_out_of_range() -> Result<(), Failure> {
    expect_value(&run(TRUNCATE, &["-3.9"])?, "-3")?;
    expect_value(&run(TRUNCATE, &["3.9"])?, "3")?;
    expect_fault(&run(TRUNCATE, &["1e300"])?, 1, "integerOverflow", "9:5-9:9")
}

#[test]
fn rounding_moves_ties_away_from_zero() -> Result<(), Failure> {
    expect_value(&run(ROUND, &["2.5"])?, "3")?;
    expect_value(&run(ROUND, &["-2.5"])?, "-3")?;
    expect_fault(&run(ROUND, &["1e300"])?, 1, "integerOverflow", "10:5-10:9")
}
