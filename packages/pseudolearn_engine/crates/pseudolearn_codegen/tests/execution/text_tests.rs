use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @greet() -> unit {
b0() mass 0:
  %0 = const.str \"hola\"
  out.write %0, newline @101:1-101:5
  return
}
func @join_length() -> i64 {
b0() mass 0:
  %0 = const.str \"ab\"
  %1 = const.str \"cde\"
  %2 = text.concat %0, %1 @102:1-102:5
  %3 = text.length %2
  return %3
}
func @join_characters() -> unit {
b0() mass 0:
  %0 = const.char 'x'
  %1 = const.str \"yz\"
  %2 = text.concat %0, %1 @103:1-103:5
  %3 = const.char 'w'
  %4 = text.concat %2, %3 @104:1-104:5
  out.write %4, newline @105:1-105:5
  return
}
func @character_at(%0: i64) -> char {
b0() mass 0:
  %1 = const.str \"añ😀\"
  %2 = text.char_at %1, %0 @9:1-9:9
  return %2
}
func @order(%0: i64) -> bool {
b0() mass 0:
  %1 = const.str \"abc\"
  %2 = const.str \"abd\"
  %3 = const.i64 0
  %4 = int.cmp eq, %0, %3
  branch %4, b1(%1, %2), b1(%2, %1)
b1(%5: str, %6: str) mass 0:
  %7 = text.cmp lt, %5, %6
  return %7
}
func @show() -> unit {
b0() mass 0:
  %0 = const.i64 -42
  %1 = text.format %0 @106:1-106:5
  %2 = const.f64 2.5
  %3 = text.format %2 @107:1-107:5
  %4 = const.bool true
  %5 = text.format %4 @108:1-108:5
  %6 = const.char 'q'
  %7 = text.format %6 @109:1-109:5
  out.write %1, %3, %5, %7, newline @110:1-110:5
  return
}
func @parse_integer(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.str \"42\"
  %2 = const.str \"4x\"
  %3 = const.i64 0
  %4 = int.cmp eq, %0, %3
  branch %4, b1(%1), b1(%2)
b1(%5: str) mass 0:
  %6 = text.to_integer %5 @20:1-20:9
  return %6
}
func @parse_real() -> f64 {
b0() mass 0:
  %0 = const.str \"1.25\"
  %1 = text.to_real %0 @21:1-21:9
  return %1
}
func @write_pieces() -> unit {
b0() mass 0:
  %0 = const.str \"a\"
  %1 = const.i64 1
  out.write %0, %1 @111:1-111:5
  out.write %0 @112:1-112:5
  return
}
func @empty_text() -> i64 {
b0() mass 0:
  %0 = const.str \"\"
  %1 = text.length %0
  return %1
}
";

const GREET: usize = 0;
const JOIN_LENGTH: usize = 1;
const JOIN_CHARACTERS: usize = 2;
const CHARACTER_AT: usize = 3;
const ORDER: usize = 4;
const SHOW: usize = 5;
const PARSE_INTEGER: usize = 6;
const PARSE_REAL: usize = 7;
const WRITE_PIECES: usize = 8;
const EMPTY_TEXT: usize = 9;

fn signatures() -> Vec<Signature> {
    let function = |parameters: Vec<Kind>, returns: Kind| Signature {
        parameters,
        returns,
    };
    vec![
        function(vec![], Kind::Unit),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Unit),
        function(vec![Kind::Integer], Kind::Character),
        function(vec![Kind::Integer], Kind::Boolean),
        function(vec![], Kind::Unit),
        function(vec![Kind::Integer], Kind::Integer),
        function(vec![], Kind::Real),
        function(vec![], Kind::Unit),
        function(vec![], Kind::Integer),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

fn expect_output(call: &Call, output: &str) -> Result<(), Failure> {
    let outcome = run(call)?;
    if outcome.status == 0 && outcome.output == output {
        Ok(())
    } else {
        Err(format!("expected output {output:?}, got {outcome:?}"))
    }
}

#[test]
fn literals_are_written_with_the_requested_newline() -> Result<(), Failure> {
    expect_output(&Call::with(GREET, &[]), "hola\n")
}

#[test]
fn concatenation_joins_code_points_and_counts_them() -> Result<(), Failure> {
    expect_value(&run(&Call::with(JOIN_LENGTH, &[]))?, "5")?;
    expect_output(&Call::with(JOIN_CHARACTERS, &[]), "xyzw\n")
}

#[test]
fn character_access_is_zero_based_over_code_points() -> Result<(), Failure> {
    expect_value(&run(&Call::with(CHARACTER_AT, &["0"]))?, "97")?;
    expect_value(&run(&Call::with(CHARACTER_AT, &["1"]))?, "241")?;
    expect_value(&run(&Call::with(CHARACTER_AT, &["2"]))?, "128512")
}

#[test]
fn character_access_outside_the_text_traps() -> Result<(), Failure> {
    for position in ["3", "-1"] {
        expect_fault(
            &run(&Call::with(CHARACTER_AT, &[position]))?,
            1,
            "stringPositionOutOfRange",
            "9:1-9:9",
        )?;
    }
    Ok(())
}

#[test]
fn comparison_is_lexicographic_by_code_point() -> Result<(), Failure> {
    expect_value(&run(&Call::with(ORDER, &["0"]))?, "1")?;
    expect_value(&run(&Call::with(ORDER, &["1"]))?, "0")
}

#[test]
fn formatting_renders_each_primitive_like_the_engine() -> Result<(), Failure> {
    expect_output(&Call::with(SHOW, &[]), "-422.5trueq\n")
}

#[test]
fn numeric_conversion_accepts_decimals_and_traps_otherwise() -> Result<(), Failure> {
    expect_value(&run(&Call::with(PARSE_INTEGER, &["0"]))?, "42")?;
    expect_fault(
        &run(&Call::with(PARSE_INTEGER, &["1"]))?,
        1,
        "stringToNumberConversionFailed",
        "20:1-20:9",
    )?;
    expect_value(&run(&Call::with(PARSE_REAL, &[]))?, "1.25")
}

#[test]
fn several_values_in_one_write_share_a_single_newline() -> Result<(), Failure> {
    expect_output(&Call::with(WRITE_PIECES, &[]), "a1a")
}

#[test]
fn the_empty_literal_has_no_code_points() -> Result<(), Failure> {
    expect_value(&run(&Call::with(EMPTY_TEXT, &[]))?, "0")
}
