use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @sum_twice(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = int.add %0, %1 @3:1-3:5
  %3 = int.add %0, %1 @4:1-4:5
  return %3
}
func @sum_after_branch(%0: i64, %1: i64, %2: i64) -> i64 {
b0() mass 0:
  %3 = const.i64 0
  %4 = int.cmp ne, %0, %3
  branch %4, b1(), b2()
b1() mass 0:
  %5 = int.add %1, %2 @5:1-5:5
  jump b3()
b2() mass 0:
  jump b3()
b3() mass 0:
  %6 = int.add %1, %2 @6:1-6:5
  return %6
}
func @decrement_twice(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 1
  %2 = int.sub %0, %1 @7:1-7:5
  %3 = const.i64 1
  %4 = int.sub %0, %3 @8:1-8:5
  %5 = int.add %2, %4 @9:1-9:5
  return %5
}
func @same_slot(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @10:1-10:5
  %3 = const.i64 5
  array.store %2, %0, %3 @11:1-11:5
  %4 = array.load %2, %0 @12:1-12:5
  array.store %2, %0, %4 @13:1-13:5
  return %4
}
func @two_arrays(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @20:1-20:5
  %3 = const.i64 1
  %4 = array.new array<i64, 1>, %3 @21:1-21:5
  %5 = const.i64 9
  array.store %2, %0, %5 @22:1-22:5
  array.store %4, %0, %5 @23:1-23:5
  return %5
}
func @two_indices(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = const.i64 3
  %3 = array.new array<i64, 1>, %2 @30:1-30:5
  %4 = const.i64 7
  array.store %3, %0, %4 @31:1-31:5
  array.store %3, %1, %4 @32:1-32:5
  return %4
}
func @slot_after_branch(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = const.i64 3
  %3 = array.new array<i64, 1>, %2 @40:1-40:5
  %4 = const.i64 0
  %5 = int.cmp ne, %0, %4
  branch %5, b1(), b2()
b1() mass 0:
  %6 = const.i64 4
  array.store %3, %1, %6 @41:1-41:5
  jump b3()
b2() mass 0:
  jump b3()
b3() mass 0:
  %7 = array.load %3, %1 @42:1-42:5
  return %7
}
func @constant_slots(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @50:1-50:5
  %3 = const.i64 2
  %4 = const.i64 2
  array.store %2, %3, %0 @51:1-51:5
  %5 = array.load %2, %4 @52:1-52:5
  return %5
}
";

const SUM_TWICE: usize = 0;
const SUM_AFTER_BRANCH: usize = 1;
const DECREMENT_TWICE: usize = 2;
const SAME_SLOT: usize = 3;
const TWO_ARRAYS: usize = 4;
const TWO_INDICES: usize = 5;
const SLOT_AFTER_BRANCH: usize = 6;
const CONSTANT_SLOTS: usize = 7;

fn signatures() -> Vec<Signature> {
    let function = |count: usize| Signature {
        parameters: vec![Kind::Integer; count],
        returns: Kind::Integer,
    };
    vec![
        function(2),
        function(3),
        function(1),
        function(1),
        function(1),
        function(2),
        function(2),
        function(1),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn a_repeated_checked_addition_keeps_the_value_and_the_first_fault_site() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SUM_TWICE, &["20", "22"]))?, "42")?;
    let maximum = i64::MAX.to_string();
    expect_fault(
        &run(&Call::with(SUM_TWICE, &[&maximum, "1"]))?,
        1,
        "integerOverflow",
        "3:1-3:5",
    )
}

#[test]
fn an_addition_checked_on_one_branch_is_checked_again_after_the_join() -> Result<(), Failure> {
    let maximum = i64::MAX.to_string();
    expect_value(&run(&Call::with(SUM_AFTER_BRANCH, &["1", "2", "3"]))?, "5")?;
    expect_value(&run(&Call::with(SUM_AFTER_BRANCH, &["0", "2", "3"]))?, "5")?;
    expect_fault(
        &run(&Call::with(SUM_AFTER_BRANCH, &["1", &maximum, "1"]))?,
        1,
        "integerOverflow",
        "5:1-5:5",
    )?;
    expect_fault(
        &run(&Call::with(SUM_AFTER_BRANCH, &["0", &maximum, "1"]))?,
        1,
        "integerOverflow",
        "6:1-6:5",
    )
}

#[test]
fn a_repeated_decrement_by_a_constant_checks_the_minimum_once() -> Result<(), Failure> {
    expect_value(&run(&Call::with(DECREMENT_TWICE, &["10"]))?, "18")?;
    let minimum = i64::MIN.to_string();
    expect_fault(
        &run(&Call::with(DECREMENT_TWICE, &[&minimum]))?,
        1,
        "integerOverflow",
        "7:1-7:5",
    )?;
    let near_minimum = (i64::MIN + 1).to_string();
    expect_fault(
        &run(&Call::with(DECREMENT_TWICE, &[&near_minimum]))?,
        1,
        "integerOverflow",
        "9:1-9:5",
    )
}

#[test]
fn a_verified_array_slot_keeps_reading_and_writing_its_element() -> Result<(), Failure> {
    for index in ["0", "1", "2"] {
        expect_value(&run(&Call::with(SAME_SLOT, &[index]))?, "5")?;
    }
    for index in ["3", "-1"] {
        expect_fault(
            &run(&Call::with(SAME_SLOT, &[index]))?,
            1,
            "arrayIndexOutOfRange",
            "11:1-11:5",
        )?;
    }
    Ok(())
}

#[test]
fn a_verified_slot_does_not_cover_another_array_with_the_same_index() -> Result<(), Failure> {
    expect_value(&run(&Call::with(TWO_ARRAYS, &["0"]))?, "9")?;
    expect_fault(
        &run(&Call::with(TWO_ARRAYS, &["1"]))?,
        1,
        "arrayIndexOutOfRange",
        "23:1-23:5",
    )
}

#[test]
fn a_verified_slot_does_not_cover_another_index_of_the_same_array() -> Result<(), Failure> {
    expect_value(&run(&Call::with(TWO_INDICES, &["0", "2"]))?, "7")?;
    expect_fault(
        &run(&Call::with(TWO_INDICES, &["0", "5"]))?,
        1,
        "arrayIndexOutOfRange",
        "32:1-32:5",
    )
}

#[test]
fn a_slot_verified_on_one_branch_is_checked_again_after_the_join() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SLOT_AFTER_BRANCH, &["1", "1"]))?, "4")?;
    expect_fault(
        &run(&Call::with(SLOT_AFTER_BRANCH, &["1", "5"]))?,
        1,
        "arrayIndexOutOfRange",
        "41:1-41:5",
    )?;
    expect_fault(
        &run(&Call::with(SLOT_AFTER_BRANCH, &["0", "5"]))?,
        1,
        "arrayIndexOutOfRange",
        "42:1-42:5",
    )?;
    expect_fault(
        &run(&Call::with(SLOT_AFTER_BRANCH, &["0", "1"]))?,
        1,
        "uninitializedVariableRead",
        "42:1-42:5",
    )
}

#[test]
fn equal_constant_indices_share_one_verified_slot() -> Result<(), Failure> {
    expect_value(&run(&Call::with(CONSTANT_SLOTS, &["13"]))?, "13")
}
