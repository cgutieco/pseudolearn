use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @add_zero(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.add %0, %1 @3:5-3:9
  return %2
}
func @zero_plus(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.add %1, %0 @4:5-4:9
  return %2
}
func @multiply_one(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 1
  %2 = int.mul %0, %1 @5:5-5:9
  return %2
}
func @constant_sum() -> i64 {
b0() mass 0:
  %0 = const.i64 40
  %1 = const.i64 2
  %2 = int.add %0, %1 @6:5-6:9
  return %2
}
func @constant_overflow() -> i64 {
b0() mass 0:
  %0 = const.i64 9223372036854775807
  %1 = const.i64 1
  %2 = int.add %0, %1 @7:5-7:9
  return %2
}
func @constant_negation_overflow() -> i64 {
b0() mass 0:
  %0 = const.i64 -9223372036854775808
  %1 = int.neg %0 @8:5-8:9
  return %1
}
func @subtract_zero(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.sub %0, %1 @9:5-9:9
  return %2
}
";

const ADD_ZERO: usize = 0;
const ZERO_PLUS: usize = 1;
const MULTIPLY_ONE: usize = 2;
const CONSTANT_SUM: usize = 3;
const CONSTANT_OVERFLOW: usize = 4;
const CONSTANT_NEGATION_OVERFLOW: usize = 5;
const SUBTRACT_ZERO: usize = 6;

fn unary() -> Signature {
    Signature {
        parameters: vec![Kind::Integer],
        returns: Kind::Integer,
    }
}

fn nullary() -> Signature {
    Signature {
        parameters: Vec::new(),
        returns: Kind::Integer,
    }
}

fn signatures() -> Vec<Signature> {
    vec![
        unary(),
        unary(),
        unary(),
        nullary(),
        nullary(),
        nullary(),
        unary(),
    ]
}

fn run(function: usize, arguments: &[&str]) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(&Call::with(function, arguments))
}

const MAXIMUM: &str = "9223372036854775807";

#[test]
fn identity_operands_return_the_other_operand_unchanged() -> Result<(), Failure> {
    expect_value(&run(ADD_ZERO, &[MAXIMUM])?, MAXIMUM)?;
    expect_value(&run(ZERO_PLUS, &["-7"])?, "-7")?;
    expect_value(&run(MULTIPLY_ONE, &[MAXIMUM])?, MAXIMUM)?;
    expect_value(&run(SUBTRACT_ZERO, &["0"])?, "0")
}

#[test]
fn constant_operands_fold_to_the_exact_result() -> Result<(), Failure> {
    expect_value(&run(CONSTANT_SUM, &[])?, "42")
}

#[test]
fn constant_overflow_still_traps_at_run_time() -> Result<(), Failure> {
    expect_fault(
        &run(CONSTANT_OVERFLOW, &[])?,
        1,
        "integerOverflow",
        "7:5-7:9",
    )?;
    expect_fault(
        &run(CONSTANT_NEGATION_OVERFLOW, &[])?,
        1,
        "integerOverflow",
        "8:5-8:9",
    )
}
