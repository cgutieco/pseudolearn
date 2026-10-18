use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @sum(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 0
  %2 = const.i64 1
  jump b1(%1, %2)
b1(%3: i64, %4: i64) mass 1:
  stmt.enter @4:1-6:12
  %5 = int.cmp le, %4, %0
  decide.bool %5 @4:10-4:15
  branch %5, b2(), b3()
b2() mass 0:
  %6 = int.add %3, %4 @5:6-5:11
  %7 = const.i64 1
  %8 = int.add %4, %7 @5:12-5:16
  jump b1(%6, %8)
b3() mass 0:
  stmt.exit @4:1-6:12
  return %3
}
func @larger(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.cmp gt, %0, %1
  branch %2, b1(%0), b1(%1)
b1(%3: i64) mass 0:
  return %3
}
func @step(%0: i64) -> unit {
b0() mass 0:
  loop.check_step %0 @8:1-8:5
  return
}
func @missing() -> i64 {
b0() mass 0:
  trap.missing_return @9:1-9:4
}
func @broken() -> unit {
b0() mass 0:
  unreachable @10:1-10:4
}
func @empty() -> unit {
b0() mass 0:
  return
}
";

const SUM: usize = 0;
const LARGER: usize = 1;
const STEP: usize = 2;
const MISSING: usize = 3;
const BROKEN: usize = 4;
const EMPTY: usize = 5;

fn signatures() -> Vec<Signature> {
    vec![
        Signature {
            parameters: vec![Kind::Integer],
            returns: Kind::Integer,
        },
        Signature {
            parameters: vec![Kind::Integer, Kind::Integer],
            returns: Kind::Integer,
        },
        Signature {
            parameters: vec![Kind::Integer],
            returns: Kind::Unit,
        },
        Signature {
            parameters: vec![],
            returns: Kind::Integer,
        },
        Signature {
            parameters: vec![],
            returns: Kind::Unit,
        },
        Signature {
            parameters: vec![],
            returns: Kind::Unit,
        },
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn loops_accumulate_through_block_parameters() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SUM, &["100"]))?, "5050")?;
    expect_value(&run(&Call::with(SUM, &["0"]))?, "0")
}

#[test]
fn branches_pass_arguments_to_the_selected_edge() -> Result<(), Failure> {
    expect_value(&run(&Call::with(LARGER, &["3", "9"]))?, "9")?;
    expect_value(&run(&Call::with(LARGER, &["9", "3"]))?, "9")
}

#[test]
fn block_mass_is_charged_on_every_header_entry() -> Result<(), Failure> {
    let mut call = Call::with(SUM, &["3"]);
    call.budget = Some(100);
    let outcome = run(&call)?;
    expect_value(&outcome, "6")?;
    if outcome.remaining != 96 {
        return Err(format!("expected 96 units left, got {outcome:?}"));
    }
    Ok(())
}

#[test]
fn exhausting_the_budget_stops_at_the_charging_block_as_a_limit() -> Result<(), Failure> {
    let mut call = Call::with(SUM, &["100"]);
    call.budget = Some(10);
    expect_fault(&run(&call)?, 2, "statementBudgetExhausted", "4:1-6:12")
}

#[test]
fn a_budget_that_exactly_fits_does_not_trap() -> Result<(), Failure> {
    let mut call = Call::with(SUM, &["3"]);
    call.budget = Some(4);
    expect_value(&run(&call)?, "6")
}

#[test]
fn a_zero_loop_step_traps_and_a_non_zero_one_passes() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(STEP, &["0"]))?,
        1,
        "zeroStepInCountedLoop",
        "8:1-8:5",
    )?;
    expect_value(&run(&Call::with(STEP, &["-1"]))?, "unit")
}

#[test]
fn a_function_that_reaches_its_end_without_returning_traps() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(MISSING, &[]))?,
        1,
        "subroutineEndedWithoutReturn",
        "9:1-9:4",
    )
}

#[test]
fn reaching_unreachable_code_is_an_internal_fault() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(BROKEN, &[]))?,
        1,
        "internalFault",
        "10:1-10:4",
    )
}

#[test]
fn a_function_without_instructions_but_return_balances_the_frame() -> Result<(), Failure> {
    let outcome = run(&Call::with(EMPTY, &[]))?;
    expect_value(&outcome, "unit")?;
    if outcome.depth != 0 {
        return Err(format!("frame depth not restored: {outcome:?}"));
    }
    Ok(())
}
