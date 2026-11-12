use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @fibonacci(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 2
  %2 = int.cmp lt, %0, %1
  branch %2, b1(), b2()
b1() mass 0:
  return %0
b2() mass 0:
  %3 = const.i64 1
  %4 = int.sub %0, %3 @6:9-6:12
  %5 = call @fibonacci(%4) @6:5-6:20
  %6 = const.i64 2
  %7 = int.sub %0, %6 @6:25-6:28
  %8 = call @fibonacci(%7) @6:23-6:38
  %9 = int.add %5, %8 @6:5-6:38
  return %9
}
func @towers(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.cmp eq, %0, %1
  branch %2, b1(), b2()
b1() mass 0:
  return %1
b2() mass 0:
  %3 = const.i64 1
  %4 = int.sub %0, %3 @11:9-11:12
  %5 = call @towers(%4) @12:5-12:20
  %6 = int.add %5, %5 @13:5-13:9
  %7 = int.add %6, %3 @14:5-14:9
  return %7
}
func @forever(%0: i64) -> i64 {
b0() mass 0:
  %1 = call @forever(%0) @15:5-15:20
  return %1
}
func @inner(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 10
  %2 = int.div %1, %0 @18:5-18:10
  return %2
}
func @outer(%0: i64) -> i64 {
b0() mass 0:
  %1 = call @inner(%0) @21:5-21:15
  %2 = const.i64 1
  %3 = int.add %1, %2 @22:5-22:10
  return %3
}
func @count(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.cmp eq, %0, %1
  branch %2, b1(), b2()
b1() mass 0:
  return %1
b2() mass 0:
  %3 = const.i64 1
  %4 = int.sub %0, %3 @25:9-25:12
  %5 = call @count(%4) @26:5-26:15
  %6 = int.add %5, %3 @27:5-27:9
  return %6
}
";

const FIBONACCI: usize = 0;
const TOWERS: usize = 1;
const FOREVER: usize = 2;
const OUTER: usize = 4;
const COUNT: usize = 5;

fn signatures() -> Vec<Signature> {
    let unary = || Signature {
        parameters: vec![Kind::Integer],
        returns: Kind::Integer,
    };
    vec![unary(), unary(), unary(), unary(), unary(), unary()]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn recursion_computes_fibonacci_and_balances_the_frames() -> Result<(), Failure> {
    let outcome = run(&Call::with(FIBONACCI, &["15"]))?;
    expect_value(&outcome, "610")?;
    if outcome.depth != 0 {
        return Err(format!("frame depth not restored: {outcome:?}"));
    }
    Ok(())
}

#[test]
fn recursion_reaches_exactly_the_frame_limit_and_not_one_more() -> Result<(), Failure> {
    expect_value(&run(&Call::with(COUNT, &["999"]))?, "999")?;
    expect_fault(
        &run(&Call::with(COUNT, &["1000"]))?,
        1,
        "recursionDepthExceeded",
        "26:5-26:15",
    )
}

#[test]
fn overflow_deep_in_the_recursion_wins_over_the_depth_limit() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(TOWERS, &["900"]))?,
        1,
        "integerOverflow",
        "13:5-13:9",
    )
}

#[test]
fn towers_counts_moves_for_small_discs() -> Result<(), Failure> {
    expect_value(&run(&Call::with(TOWERS, &["10"]))?, "1023")?;
    expect_value(&run(&Call::with(TOWERS, &["0"]))?, "0")
}

#[test]
fn unbounded_recursion_stops_at_the_frame_limit_at_the_call_site() -> Result<(), Failure> {
    let outcome = run(&Call::with(FOREVER, &["1"]))?;
    expect_fault(&outcome, 1, "recursionDepthExceeded", "15:5-15:20")?;
    if outcome.depth != 1_000 {
        return Err(format!("expected 1000 active frames, got {outcome:?}"));
    }
    Ok(())
}

#[test]
fn a_smaller_frame_limit_is_honoured() -> Result<(), Failure> {
    let mut call = Call::with(FIBONACCI, &["20"]);
    call.frames = 5;
    expect_fault(&run(&call)?, 1, "recursionDepthExceeded", "6:5-6:20")?;
    call.frames = 30;
    expect_value(&run(&call)?, "6765")
}

#[test]
fn a_trap_in_the_callee_propagates_immediately_with_its_own_site() -> Result<(), Failure> {
    expect_value(&run(&Call::with(OUTER, &["2"]))?, "6")?;
    expect_fault(
        &run(&Call::with(OUTER, &["0"]))?,
        1,
        "divisionByZero",
        "18:5-18:10",
    )
}
