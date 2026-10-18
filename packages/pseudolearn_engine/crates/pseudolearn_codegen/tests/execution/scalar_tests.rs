use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @constants() -> i64 {
b0() mass 0:
  %0 = const.i64 -5
  return %0
}
func @character() -> char {
b0() mass 0:
  %0 = const.char 'λ'
  return %0
}
func @not(%0: bool) -> bool {
b0() mass 0:
  %1 = bool.not %0
  return %1
}
func @same(%0: bool, %1: bool) -> bool {
b0() mass 0:
  %2 = bool.cmp eq, %0, %1
  return %2
}
func @before(%0: char, %1: char) -> bool {
b0() mass 0:
  %2 = char.cmp lt, %0, %1
  return %2
}
func @code(%0: char) -> i64 {
b0() mass 0:
  %1 = char.code %0
  return %1
}
func @from_code(%0: i64) -> char {
b0() mass 0:
  %1 = char.from_code %0 @8:3-8:9
  return %1
}
func @required_boolean() -> bool {
b0() mass 0:
  %0 = value.undefined bool
  %1 = value.require %0 @9:1-9:5
  return %1
}
func @required_real() -> f64 {
b0() mass 0:
  %0 = value.undefined f64
  %1 = value.require %0 @10:1-10:5
  return %1
}
func @required_character() -> char {
b0() mass 0:
  %0 = value.undefined char
  %1 = value.require %0 @11:1-11:5
  return %1
}
func @defined_boolean() -> bool {
b0() mass 0:
  %0 = const.bool true
  %1 = value.require %0 @12:1-12:5
  return %1
}
";

const CONSTANTS: usize = 0;
const CHARACTER: usize = 1;
const NOT: usize = 2;
const SAME: usize = 3;
const BEFORE: usize = 4;
const CODE: usize = 5;
const FROM_CODE: usize = 6;
const REQUIRED_BOOLEAN: usize = 7;
const REQUIRED_REAL: usize = 8;
const REQUIRED_CHARACTER: usize = 9;
const DEFINED_BOOLEAN: usize = 10;

fn signature(parameters: Vec<Kind>, returns: Kind) -> Signature {
    Signature {
        parameters,
        returns,
    }
}

fn signatures() -> Vec<Signature> {
    vec![
        signature(vec![], Kind::Integer),
        signature(vec![], Kind::Character),
        signature(vec![Kind::Boolean], Kind::Boolean),
        signature(vec![Kind::Boolean, Kind::Boolean], Kind::Boolean),
        signature(vec![Kind::Character, Kind::Character], Kind::Boolean),
        signature(vec![Kind::Character], Kind::Integer),
        signature(vec![Kind::Integer], Kind::Character),
        signature(vec![], Kind::Boolean),
        signature(vec![], Kind::Real),
        signature(vec![], Kind::Character),
        signature(vec![], Kind::Boolean),
    ]
}

fn run(function: usize, arguments: &[&str]) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(&Call::with(function, arguments))
}

#[test]
fn constants_keep_their_exact_bits() -> Result<(), Failure> {
    expect_value(&run(CONSTANTS, &[])?, "-5")?;
    expect_value(&run(CHARACTER, &[])?, "955")
}

#[test]
fn boolean_operators_are_exact() -> Result<(), Failure> {
    expect_value(&run(NOT, &["1"])?, "0")?;
    expect_value(&run(NOT, &["0"])?, "1")?;
    expect_value(&run(SAME, &["1", "1"])?, "1")?;
    expect_value(&run(SAME, &["1", "0"])?, "0")
}

#[test]
fn characters_compare_and_convert_by_scalar() -> Result<(), Failure> {
    expect_value(&run(BEFORE, &["97", "98"])?, "1")?;
    expect_value(&run(BEFORE, &["955", "97"])?, "0")?;
    expect_value(&run(CODE, &["955"])?, "955")
}

#[test]
fn character_construction_accepts_only_unicode_scalars() -> Result<(), Failure> {
    expect_value(&run(FROM_CODE, &["65"])?, "65")?;
    expect_value(&run(FROM_CODE, &["0"])?, "0")?;
    expect_value(&run(FROM_CODE, &["1114111"])?, "1114111")?;
    expect_value(&run(FROM_CODE, &["55295"])?, "55295")?;
    expect_value(&run(FROM_CODE, &["57344"])?, "57344")
}

#[test]
fn invalid_character_codes_trap_at_the_boundaries() -> Result<(), Failure> {
    for code in ["-1", "55296", "57343", "1114112", "-9223372036854775808"] {
        expect_fault(
            &run(FROM_CODE, &[code])?,
            1,
            "invalidCharacterCode",
            "8:3-8:9",
        )?;
    }
    Ok(())
}

#[test]
fn reading_an_undefined_scalar_traps() -> Result<(), Failure> {
    expect_fault(
        &run(REQUIRED_BOOLEAN, &[])?,
        1,
        "uninitializedVariableRead",
        "9:1-9:5",
    )?;
    expect_fault(
        &run(REQUIRED_REAL, &[])?,
        1,
        "uninitializedVariableRead",
        "10:1-10:5",
    )?;
    expect_fault(
        &run(REQUIRED_CHARACTER, &[])?,
        1,
        "uninitializedVariableRead",
        "11:1-11:5",
    )
}

#[test]
fn reading_a_defined_scalar_passes_it_through() -> Result<(), Failure> {
    expect_value(&run(DEFINED_BOOLEAN, &[])?, "1")
}
