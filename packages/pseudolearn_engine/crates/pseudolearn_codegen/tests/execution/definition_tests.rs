use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @direct() -> i64 {
b0() mass 0:
  %0 = value.undefined i64
  %1 = value.require %0 @1:1-1:5
  return %1
}
func @merge(%0: i64) -> i64 {
b0() mass 0:
  %1 = value.undefined i64
  %2 = const.i64 0
  %3 = int.cmp gt, %0, %2
  branch %3, b1(), b2(%1)
b1() mass 0:
  %4 = const.i64 7
  jump b2(%4)
b2(%5: i64) mass 0:
  %6 = value.require %5 @3:1-3:5
  return %6
}
func @identity(%0: i64) -> i64 {
b0() mass 0:
  return %0
}
func @pass_undefined() -> i64 {
b0() mass 0:
  %0 = value.undefined i64
  %1 = call @identity(%0) @5:1-5:9
  return %1
}
func @pass_merged(%0: i64) -> i64 {
b0() mass 0:
  %1 = value.undefined i64
  %2 = const.i64 0
  %3 = int.cmp gt, %0, %2
  branch %3, b1(), b2(%1)
b1() mass 0:
  %4 = const.i64 9
  jump b2(%4)
b2(%5: i64) mass 0:
  %6 = call @identity(%5) @7:1-7:9
  return %6
}
func @loop_carry(%0: i64) -> i64 {
b0() mass 0:
  %1 = value.undefined i64
  %2 = const.i64 0
  jump b1(%2, %1)
b1(%3: i64, %4: i64) mass 0:
  %5 = int.cmp lt, %3, %0
  branch %5, b2(), b3()
b2() mass 0:
  %6 = const.i64 1
  %7 = int.add %3, %6 @9:1-9:5
  %8 = const.i64 5
  jump b1(%7, %8)
b3() mass 0:
  %9 = value.require %4 @10:1-10:5
  return %9
}
func @text_reference() -> i64 {
b0() mass 0:
  %0 = value.undefined str
  %1 = value.require %0 @12:1-12:5
  %2 = text.length %1
  return %2
}
";

const DIRECT: usize = 0;
const MERGE: usize = 1;
const PASS_UNDEFINED: usize = 3;
const PASS_MERGED: usize = 4;
const LOOP_CARRY: usize = 5;
const TEXT_REFERENCE: usize = 6;

fn signatures() -> Vec<Signature> {
    let unary = || Signature {
        parameters: vec![Kind::Integer],
        returns: Kind::Integer,
    };
    let nullary = || Signature {
        parameters: vec![],
        returns: Kind::Integer,
    };
    vec![
        nullary(),
        unary(),
        unary(),
        nullary(),
        unary(),
        unary(),
        nullary(),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn requiring_a_statically_undefined_integer_traps() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(DIRECT, &[]))?,
        1,
        "uninitializedVariableRead",
        "1:1-1:5",
    )
}

#[test]
fn a_merged_integer_is_defined_only_on_the_path_that_assigned_it() -> Result<(), Failure> {
    expect_value(&run(&Call::with(MERGE, &["1"]))?, "7")?;
    expect_fault(
        &run(&Call::with(MERGE, &["0"]))?,
        1,
        "uninitializedVariableRead",
        "3:1-3:5",
    )
}

#[test]
fn an_undefined_integer_cannot_cross_a_call_boundary() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(PASS_UNDEFINED, &[]))?,
        1,
        "uninitializedVariableRead",
        "5:1-5:9",
    )
}

#[test]
fn a_dynamically_undefined_argument_traps_and_a_defined_one_passes() -> Result<(), Failure> {
    expect_value(&run(&Call::with(PASS_MERGED, &["1"]))?, "9")?;
    expect_fault(
        &run(&Call::with(PASS_MERGED, &["0"]))?,
        1,
        "uninitializedVariableRead",
        "7:1-7:9",
    )
}

#[test]
fn definition_survives_loop_back_edges() -> Result<(), Failure> {
    expect_value(&run(&Call::with(LOOP_CARRY, &["3"]))?, "5")?;
    expect_fault(
        &run(&Call::with(LOOP_CARRY, &["0"]))?,
        1,
        "uninitializedVariableRead",
        "10:1-10:5",
    )
}

#[test]
fn an_absent_reference_traps_when_required() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(TEXT_REFERENCE, &[]))?,
        1,
        "uninitializedVariableRead",
        "12:1-12:5",
    )
}
