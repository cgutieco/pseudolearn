use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @tan(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.tan %0 @1:1-1:5
  return %1
}
func @asin(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.asin %0 @2:1-2:5
  return %1
}
func @log10(%0: f64) -> f64 {
b0() mass 0:
  %1 = math.log10 %0 @3:1-3:5
  return %1
}
func @atan2(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = math.atan2 %0, %1 @4:1-4:5
  return %2
}
func @floor(%0: f64) -> i64 {
b0() mass 0:
  %1 = real.floor %0 @5:1-5:5
  return %1
}
func @ceil(%0: f64) -> i64 {
b0() mass 0:
  %1 = real.ceil %0 @6:1-6:5
  return %1
}
func @rmin(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.min %0, %1 @7:1-7:5
  return %2
}
func @rmax(%0: f64, %1: f64) -> f64 {
b0() mass 0:
  %2 = real.max %0, %1 @8:1-8:5
  return %2
}
func @imin(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.min %0, %1 @9:1-9:5
  return %2
}
func @imax(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.max %0, %1 @10:1-10:5
  return %2
}
";

const TAN: usize = 0;
const ASIN: usize = 1;
const LOG10: usize = 2;
const ATAN2: usize = 3;
const FLOOR: usize = 4;
const CEIL: usize = 5;
const REAL_MIN: usize = 6;
const REAL_MAX: usize = 7;
const INT_MIN: usize = 8;
const INT_MAX: usize = 9;

fn signatures() -> Vec<Signature> {
    let real = |count: usize| Signature {
        parameters: vec![Kind::Real; count],
        returns: Kind::Real,
    };
    let rounding = || Signature {
        parameters: vec![Kind::Real],
        returns: Kind::Integer,
    };
    let integer = || Signature {
        parameters: vec![Kind::Integer, Kind::Integer],
        returns: Kind::Integer,
    };
    vec![
        real(1),
        real(1),
        real(1),
        real(2),
        rounding(),
        rounding(),
        real(2),
        real(2),
        integer(),
        integer(),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn tangent_and_arc_sine_follow_the_library_and_reject_outside_their_domain() -> Result<(), Failure>
{
    expect_value(&run(&Call::with(TAN, &["0.0"]))?, "0.0")?;
    expect_value(&run(&Call::with(ASIN, &["1.0"]))?, "1.5707963267948966")?;
    expect_fault(
        &run(&Call::with(ASIN, &["1.5"]))?,
        1,
        "nonFiniteRealResult",
        "2:1-2:5",
    )
}

#[test]
fn decimal_logarithm_of_zero_traps_and_atan2_of_zeros_is_zero() -> Result<(), Failure> {
    expect_value(&run(&Call::with(LOG10, &["1000.0"]))?, "3.0")?;
    expect_fault(
        &run(&Call::with(LOG10, &["0.0"]))?,
        1,
        "nonFiniteRealResult",
        "3:1-3:5",
    )?;
    expect_value(&run(&Call::with(ATAN2, &["0.0", "0.0"]))?, "0.0")
}

#[test]
fn floor_and_ceiling_keep_signed_zero_and_reject_non_finite_operands() -> Result<(), Failure> {
    expect_value(&run(&Call::with(FLOOR, &["-0.0"]))?, "0")?;
    expect_value(&run(&Call::with(CEIL, &["0.0"]))?, "0")?;
    expect_value(&run(&Call::with(FLOOR, &["-1.5"]))?, "-2")?;
    expect_value(&run(&Call::with(CEIL, &["-1.5"]))?, "-1")?;
    expect_fault(
        &run(&Call::with(FLOOR, &["NaN"]))?,
        1,
        "integerOverflow",
        "5:1-5:5",
    )
}

#[test]
fn real_extremes_order_signed_zero_and_skip_nan() -> Result<(), Failure> {
    expect_value(&run(&Call::with(REAL_MIN, &["0.0", "-0.0"]))?, "-0.0")?;
    expect_value(&run(&Call::with(REAL_MAX, &["-0.0", "0.0"]))?, "0.0")?;
    expect_value(&run(&Call::with(REAL_MIN, &["NaN", "2.0"]))?, "2.0")?;
    expect_value(&run(&Call::with(REAL_MAX, &["1.0", "NaN"]))?, "1.0")
}

#[test]
fn integer_extremes_cover_the_whole_range() -> Result<(), Failure> {
    expect_value(
        &run(&Call::with(INT_MIN, &["-9223372036854775808", "0"]))?,
        "-9223372036854775808",
    )?;
    expect_value(
        &run(&Call::with(INT_MAX, &["9223372036854775807", "-1"]))?,
        "9223372036854775807",
    )?;
    expect_value(&run(&Call::with(INT_MIN, &["3", "3"]))?, "3")
}
