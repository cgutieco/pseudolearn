use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @add(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.add %0, %1 @3:5-3:9
  return %2
}
func @sub(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.sub %0, %1 @4:5-4:9
  return %2
}
func @mul(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.mul %0, %1 @5:5-5:9
  return %2
}
func @neg(%0: i64) -> i64 {
b0() mass 0:
  %1 = int.neg %0 @6:5-6:9
  return %1
}
func @div(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.div %0, %1 @7:5-7:9
  return %2
}
func @mod(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.mod %0, %1 @8:5-8:9
  return %2
}
func @pow(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.pow %0, %1 @9:5-9:9
  return %2
}
func @less(%0: i64, %1: i64) -> bool {
b0() mass 0:
  %2 = int.cmp lt, %0, %1
  return %2
}
func @widen(%0: i64) -> f64 {
b0() mass 0:
  %1 = int.to_real %0
  return %1
}
";

const BINARY: usize = 0;
const SUBTRACT: usize = 1;
const MULTIPLY: usize = 2;
const NEGATE: usize = 3;
const DIVIDE: usize = 4;
const MODULO: usize = 5;
const POWER: usize = 6;
const LESS: usize = 7;
const WIDEN: usize = 8;

fn binary(returns: Kind) -> Signature {
    Signature {
        parameters: vec![Kind::Integer, Kind::Integer],
        returns,
    }
}

fn signatures() -> Vec<Signature> {
    vec![
        binary(Kind::Integer),
        binary(Kind::Integer),
        binary(Kind::Integer),
        Signature {
            parameters: vec![Kind::Integer],
            returns: Kind::Integer,
        },
        binary(Kind::Integer),
        binary(Kind::Integer),
        binary(Kind::Integer),
        binary(Kind::Boolean),
        Signature {
            parameters: vec![Kind::Integer],
            returns: Kind::Real,
        },
    ]
}

fn run(function: usize, arguments: &[&str]) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(&Call::with(function, arguments))
}

const MAXIMUM: &str = "9223372036854775807";
const MINIMUM: &str = "-9223372036854775808";

#[test]
fn addition_returns_the_exact_sum() -> Result<(), Failure> {
    expect_value(&run(BINARY, &["40", "2"])?, "42")?;
    expect_value(&run(BINARY, &[MAXIMUM, "-1"])?, "9223372036854775806")
}

#[test]
fn addition_traps_exactly_past_the_maximum() -> Result<(), Failure> {
    expect_fault(
        &run(BINARY, &[MAXIMUM, "1"])?,
        1,
        "integerOverflow",
        "3:5-3:9",
    )
}

#[test]
fn subtraction_traps_exactly_below_the_minimum() -> Result<(), Failure> {
    expect_value(&run(SUBTRACT, &["5", "7"])?, "-2")?;
    expect_fault(
        &run(SUBTRACT, &[MINIMUM, "1"])?,
        1,
        "integerOverflow",
        "4:5-4:9",
    )
}

#[test]
fn multiplication_traps_on_minimum_times_minus_one() -> Result<(), Failure> {
    expect_value(&run(MULTIPLY, &["-6", "7"])?, "-42")?;
    expect_fault(
        &run(MULTIPLY, &[MINIMUM, "-1"])?,
        1,
        "integerOverflow",
        "5:5-5:9",
    )?;
    expect_fault(
        &run(MULTIPLY, &[MAXIMUM, "2"])?,
        1,
        "integerOverflow",
        "5:5-5:9",
    )
}

#[test]
fn negation_traps_only_on_the_minimum() -> Result<(), Failure> {
    expect_value(&run(NEGATE, &["9"])?, "-9")?;
    expect_value(&run(NEGATE, &["0"])?, "0")?;
    expect_fault(&run(NEGATE, &[MINIMUM])?, 1, "integerOverflow", "6:5-6:9")
}

#[test]
fn division_truncates_toward_zero_and_traps_on_zero_and_overflow() -> Result<(), Failure> {
    expect_value(&run(DIVIDE, &["-7", "2"])?, "-3")?;
    expect_fault(&run(DIVIDE, &["5", "0"])?, 1, "divisionByZero", "7:5-7:9")?;
    expect_fault(
        &run(DIVIDE, &[MINIMUM, "-1"])?,
        1,
        "integerOverflow",
        "7:5-7:9",
    )?;
    expect_fault(
        &run(DIVIDE, &[MINIMUM, "0"])?,
        1,
        "divisionByZero",
        "7:5-7:9",
    )
}

#[test]
fn modulo_takes_the_dividend_sign_and_never_traps_on_minimum() -> Result<(), Failure> {
    expect_value(&run(MODULO, &["-7", "2"])?, "-1")?;
    expect_value(&run(MODULO, &[MINIMUM, "-1"])?, "0")?;
    expect_fault(&run(MODULO, &["5", "0"])?, 1, "divisionByZero", "8:5-8:9")
}

#[test]
fn power_is_exact_and_traps_on_negative_exponent_and_overflow() -> Result<(), Failure> {
    expect_value(&run(POWER, &["2", "10"])?, "1024")?;
    expect_value(&run(POWER, &["0", "0"])?, "1")?;
    expect_fault(
        &run(POWER, &["2", "-1"])?,
        1,
        "negativeIntegerExponent",
        "9:5-9:9",
    )?;
    expect_fault(&run(POWER, &["2", "63"])?, 1, "integerOverflow", "9:5-9:9")
}

#[test]
fn comparison_is_signed() -> Result<(), Failure> {
    expect_value(&run(LESS, &["-1", "1"])?, "1")?;
    expect_value(&run(LESS, &["1", "-1"])?, "0")?;
    expect_value(&run(LESS, &[MINIMUM, MAXIMUM])?, "1")
}

#[test]
fn widening_rounds_to_the_nearest_real() -> Result<(), Failure> {
    expect_value(&run(WIDEN, &["3"])?, "3.0")?;
    expect_value(&run(WIDEN, &["9007199254740993"])?, "9007199254740992.0")
}
