use crate::support::{Call, Failure, Kind, Signature, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @read_integer() -> i64 {
b0() mass 0:
  %0 = in.read i64 @1:1-1:5
  return %0
}
func @read_real() -> f64 {
b0() mass 0:
  %0 = in.read f64 @2:1-2:5
  return %0
}
func @read_boolean() -> bool {
b0() mass 0:
  %0 = in.read bool @3:1-3:5
  return %0
}
func @read_character() -> char {
b0() mass 0:
  %0 = in.read char @4:1-4:5
  return %0
}
func @read_length() -> i64 {
b0() mass 0:
  %0 = in.read str @5:1-5:5
  %1 = text.length %0
  return %1
}
func @read_pair() -> i64 {
b0() mass 0:
  %0 = in.read i64 @6:1-6:5
  %1 = in.read i64 @7:1-7:5
  %2 = int.add %0, %1 @8:1-8:5
  return %2
}
func @random() -> f64 {
b0() mass 0:
  %0 = host.random @11:1-11:5
  return %0
}
func @write_kinds() -> unit {
b0() mass 0:
  %0 = const.i64 -7
  %1 = const.f64 0.5
  %2 = const.bool false
  %3 = const.char 'x'
  out.write %0, %1, %2, %3, newline @9:1-9:5
  out.write %0 @10:1-10:5
  return
}
";

const READ_INTEGER: usize = 0;
const READ_REAL: usize = 1;
const READ_BOOLEAN: usize = 2;
const READ_CHARACTER: usize = 3;
const READ_LENGTH: usize = 4;
const READ_PAIR: usize = 5;
const RANDOM: usize = 6;
const WRITE_KINDS: usize = 7;

fn signatures() -> Vec<Signature> {
    let nullary = |returns: Kind| Signature {
        parameters: vec![],
        returns,
    };
    vec![
        nullary(Kind::Integer),
        nullary(Kind::Real),
        nullary(Kind::Boolean),
        nullary(Kind::Character),
        nullary(Kind::Integer),
        nullary(Kind::Integer),
        nullary(Kind::Real),
        nullary(Kind::Unit),
    ]
}

fn run(function: usize, input: &str) -> Result<crate::support::Outcome, Failure> {
    let mut call = Call::with(function, &[]);
    call.input = input.to_owned();
    shared(&HARNESS, MODULE, &signatures())?.run(&call)
}

#[test]
fn each_primitive_is_converted_from_its_line() -> Result<(), Failure> {
    expect_value(&run(READ_INTEGER, " 42 \n")?, "42")?;
    expect_value(&run(READ_REAL, "2.5\n")?, "2.5")?;
    expect_value(&run(READ_BOOLEAN, "true\n")?, "1")?;
    expect_value(&run(READ_BOOLEAN, "falso\n")?, "0")?;
    expect_value(&run(READ_CHARACTER, "q\n")?, "113")?;
    expect_value(&run(READ_LENGTH, "añadir\n")?, "6")
}

#[test]
fn a_line_of_the_wrong_type_is_skipped_and_the_next_one_is_read() -> Result<(), Failure> {
    expect_value(&run(READ_INTEGER, "abc\n17\n")?, "17")?;
    expect_value(&run(READ_CHARACTER, "ab\nz\n")?, "122")
}

#[test]
fn consecutive_reads_consume_consecutive_lines() -> Result<(), Failure> {
    expect_value(&run(READ_PAIR, "3\n4\n")?, "7")
}

#[test]
fn exhausted_input_stops_the_program_as_a_limit_without_a_diagnostic() -> Result<(), Failure> {
    for input in ["", "5\n"] {
        let outcome = run(READ_PAIR, input)?;
        if outcome.status != 2 || !outcome.code.is_empty() {
            return Err(format!("expected an input limit, got {outcome:?}"));
        }
    }
    Ok(())
}

#[test]
fn the_random_source_yields_unit_interval_reals() -> Result<(), Failure> {
    let outcome = run(RANDOM, "")?;
    let value: f64 = outcome.value.parse().map_err(|_| outcome.value.clone())?;
    if outcome.status == 0 && (0.0..1.0).contains(&value) {
        Ok(())
    } else {
        Err(format!("random out of range: {outcome:?}"))
    }
}

#[test]
fn writes_render_every_primitive_with_a_single_trailing_newline() -> Result<(), Failure> {
    let outcome = run(WRITE_KINDS, "")?;
    if outcome.status == 0 && outcome.output == "-70.5falsex\n-7" {
        Ok(())
    } else {
        Err(format!("unexpected output: {outcome:?}"))
    }
}
