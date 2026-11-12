use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @sqrt(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.sqrt %0 @1:1-1:5
  return %1
}
func @abs(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.abs %0 @2:1-2:5
  return %1
}
func @ln(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.ln %0 @3:1-3:5
  return %1
}
func @exp(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.exp %0 @4:1-4:5
  return %1
}
func @sin(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.sin %0 @5:1-5:5
  return %1
}
func @cos(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.cos %0 @6:1-6:5
  return %1
}
func @atan(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.atan %0 @7:1-7:5
  return %1
}
";

const SQRT: usize = 0;
const ABS: usize = 1;
const LOGARITHM: usize = 2;
const EXP: usize = 3;
const SIN: usize = 4;
const COS: usize = 5;
const ATAN: usize = 6;

fn signatures() -> Vec<Signature> {
    (0..7)
        .map(|_| Signature {
            parameters: vec![Kind::Real],
            returns: Kind::Real,
        })
        .collect()
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn square_root_is_exact_and_rejects_negative_operands() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SQRT, &["2.0"]))?, "1.4142135623730951")?;
    expect_value(&run(&Call::with(SQRT, &["0.0"]))?, "0.0")?;
    expect_value(&run(&Call::with(SQRT, &["-0.0"]))?, "-0.0")?;
    expect_fault(
        &run(&Call::with(SQRT, &["-1.0"]))?,
        1,
        "nonFiniteRealResult",
        "1:1-1:5",
    )
}

#[test]
fn absolute_value_clears_the_sign_and_never_traps() -> Result<(), Failure> {
    expect_value(&run(&Call::with(ABS, &["-3.5"]))?, "3.5")?;
    expect_value(&run(&Call::with(ABS, &["-0.0"]))?, "0.0")?;
    expect_value(&run(&Call::with(ABS, &["1e300"]))?, "1e300")
}

#[test]
fn logarithm_needs_a_positive_operand() -> Result<(), Failure> {
    expect_value(&run(&Call::with(LOGARITHM, &["1.0"]))?, "0.0")?;
    for operand in ["0.0", "-1.0"] {
        expect_fault(
            &run(&Call::with(LOGARITHM, &[operand]))?,
            1,
            "nonFiniteRealResult",
            "3:1-3:5",
        )?;
    }
    Ok(())
}

#[test]
fn exponential_overflows_into_a_trap() -> Result<(), Failure> {
    expect_value(&run(&Call::with(EXP, &["0.0"]))?, "1.0")?;
    expect_fault(
        &run(&Call::with(EXP, &["1000.0"]))?,
        1,
        "nonFiniteRealResult",
        "4:1-4:5",
    )
}

#[test]
fn trigonometric_functions_match_their_exact_values() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SIN, &["0.0"]))?, "0.0")?;
    expect_value(&run(&Call::with(COS, &["0.0"]))?, "1.0")?;
    expect_value(&run(&Call::with(ATAN, &["1.0"]))?, "0.7853981633974483")?;
    expect_value(&run(&Call::with(ATAN, &["0.0"]))?, "0.0")
}
