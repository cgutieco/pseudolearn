use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared_with};
use pseudolearn_ir::Module;
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
class Sparse { value: i64, ratio: f64, flag: bool, mark: char, name: str }
class Dense { value: i64 }
class Base { first: i64 }
class Derived : Base { second: i64 }
class Node { value: i64, next: obj<Node> }
class Garbage { value: i64 }
func @round_trip() -> i64 {
b0() mass 0:
  %0 = object.new Sparse @1:1-1:5
  %1 = const.i64 41
  object.store %0, value, %1
  %2 = const.f64 1.5
  object.store %0, ratio, %2
  %3 = const.bool true
  object.store %0, flag, %3
  %4 = const.char 'z'
  object.store %0, mark, %4
  %5 = const.str \"four\"
  object.store %0, name, %5
  %6 = object.load %0, value @2:1-2:5
  %7 = object.load %0, ratio @3:1-3:5
  %8 = object.load %0, flag @4:1-4:5
  %9 = object.load %0, mark @5:1-5:5
  %10 = object.load %0, name @6:1-6:5
  %11 = text.length %10
  %12 = int.add %6, %11 @7:1-7:5
  %13 = real.trunc %7 @8:1-8:5
  %14 = int.add %12, %13 @9:1-9:5
  %15 = char.code %9
  %16 = int.add %14, %15 @10:1-10:5
  return %16
}
func @unset(%0: i64) -> i64 {
b0() mass 0:
  %1 = object.new Sparse @11:1-11:5
  %2 = const.i64 0
  %3 = int.cmp eq, %0, %2
  branch %3, b1(), b2()
b1() mass 0:
  %4 = object.load %1, value @12:1-12:5
  return %4
b2() mass 0:
  %5 = const.i64 1
  %6 = int.cmp eq, %0, %5
  branch %6, b3(), b4()
b3() mass 0:
  %7 = object.load %1, ratio @13:1-13:5
  %8 = real.trunc %7 @14:1-14:5
  return %8
b4() mass 0:
  %9 = object.load %1, name @15:1-15:5
  %10 = text.length %9
  return %10
}
func @dense_default() -> i64 {
b0() mass 0:
  %0 = object.new Dense @16:1-16:5
  %1 = object.load %0, value @17:1-17:5
  %2 = const.i64 6
  object.store %0, value, %2
  %3 = object.load %0, value @18:1-18:5
  %4 = int.add %1, %3 @19:1-19:5
  return %4
}
func @absent_receiver() -> i64 {
b0() mass 0:
  %0 = value.undefined obj<Sparse>
  %1 = object.load %0, value @20:1-20:5
  return %1
}
func @duplicate() -> i64 {
b0() mass 0:
  %0 = object.new Sparse @21:1-21:5
  %1 = const.i64 3
  object.store %0, value, %1
  %2 = object.copy %0 @22:1-22:5
  %3 = const.i64 9
  object.store %0, value, %3
  %4 = object.load %2, value @23:1-23:5
  %5 = object.load %0, value @24:1-24:5
  %6 = int.mul %4, %5 @25:1-25:5
  return %6
}
func @identity(%0: i64) -> bool {
b0() mass 0:
  %1 = object.new Sparse @26:1-26:5
  %2 = object.copy %1 @27:1-27:5
  %3 = const.i64 0
  %4 = int.cmp eq, %0, %3
  branch %4, b1(%1), b1(%2)
b1(%5: obj<Sparse>) mass 0:
  %6 = ref.cmp eq, %1, %5
  return %6
}
func @inheritance() -> i64 {
b0() mass 0:
  %0 = object.new Derived @28:1-28:5
  %1 = const.i64 10
  %2 = const.i64 4
  object.store %0, first, %1
  object.store %0, second, %2
  %3 = object.load %0, first @29:1-29:5
  %4 = object.load %0, second @30:1-30:5
  %5 = int.sub %3, %4 @31:1-31:5
  return %5
}
func @list_sum(%0: i64) -> i64 {
b0() mass 0:
  %1 = value.undefined obj<Node>
  %2 = const.i64 0
  jump b1(%2, %1)
b1(%3: i64, %4: obj<Node>) mass 0:
  %5 = int.cmp lt, %3, %0
  branch %5, b2(), b3()
b2() mass 0:
  %6 = object.new Garbage @32:1-32:5
  %7 = object.new Node @33:1-33:5
  object.store %7, value, %3
  object.store %7, next, %4
  %8 = const.i64 1
  %9 = int.add %3, %8 @34:1-34:5
  jump b1(%9, %7)
b3() mass 0:
  %10 = const.i64 0
  %11 = const.i64 1
  %12 = int.sub %0, %11 @35:1-35:5
  jump b4(%4, %10, %10)
b4(%13: obj<Node>, %14: i64, %15: i64) mass 0:
  %16 = int.cmp lt, %15, %12
  branch %16, b5(), b6()
b5() mass 0:
  %17 = object.load %13, value @36:1-36:5
  %18 = int.add %14, %17 @37:1-37:5
  %19 = object.load %13, next @38:1-38:5
  %20 = int.add %15, %11 @39:1-39:5
  jump b4(%19, %18, %20)
b6() mass 0:
  %21 = object.load %13, value @40:1-40:5
  %22 = int.add %14, %21 @41:1-41:5
  return %22
}
";

const ROUND_TRIP: usize = 0;
const UNSET: usize = 1;
const DENSE_DEFAULT: usize = 2;
const ABSENT_RECEIVER: usize = 3;
const DUPLICATE: usize = 4;
const IDENTITY: usize = 5;
const INHERITANCE: usize = 6;
const LIST_SUM: usize = 7;

fn signatures() -> Vec<Signature> {
    let function = |parameters: Vec<Kind>, returns: Kind| Signature {
        parameters,
        returns,
    };
    let integer = || vec![Kind::Integer];
    vec![
        function(vec![], Kind::Integer),
        function(integer(), Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Integer),
        function(integer(), Kind::Boolean),
        function(vec![], Kind::Integer),
        function(integer(), Kind::Integer),
    ]
}

fn mark_dense(module: &mut Module) {
    if let Some(class) = module.classes.get_mut(1) {
        class.dense_integers = true;
    }
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared_with(&HARNESS, MODULE, (&signatures(), mark_dense))?.run(call)
}

#[test]
fn every_field_kind_round_trips_through_the_object() -> Result<(), Failure> {
    expect_value(&run(&Call::with(ROUND_TRIP, &[]))?, "168")
}

#[test]
fn fields_without_value_trap_on_read() -> Result<(), Failure> {
    for (selector, span) in [("0", "12:1-12:5"), ("1", "13:1-13:5"), ("2", "15:1-15:5")] {
        expect_fault(
            &run(&Call::with(UNSET, &[selector]))?,
            1,
            "uninitializedVariableRead",
            span,
        )?;
    }
    Ok(())
}

#[test]
fn dense_classes_read_integers_as_defined() -> Result<(), Failure> {
    expect_value(&run(&Call::with(DENSE_DEFAULT, &[]))?, "6")
}

#[test]
fn an_absent_receiver_traps() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(ABSENT_RECEIVER, &[]))?,
        1,
        "uninitializedVariableRead",
        "20:1-20:5",
    )
}

#[test]
fn copies_are_independent_of_the_original() -> Result<(), Failure> {
    expect_value(&run(&Call::with(DUPLICATE, &[]))?, "27")
}

#[test]
fn reference_comparison_distinguishes_a_copy_from_its_source() -> Result<(), Failure> {
    expect_value(&run(&Call::with(IDENTITY, &["0"]))?, "1")?;
    expect_value(&run(&Call::with(IDENTITY, &["1"]))?, "0")
}

#[test]
fn inherited_fields_come_before_the_declared_ones() -> Result<(), Failure> {
    expect_value(&run(&Call::with(INHERITANCE, &[]))?, "6")
}

#[test]
fn a_linked_list_survives_collections_while_garbage_is_reclaimed() -> Result<(), Failure> {
    let mut call = Call::with(LIST_SUM, &["100"]);
    call.cells = Some(400);
    expect_value(&run(&call)?, "4950")?;
    let mut exhausted = Call::with(LIST_SUM, &["100"]);
    exhausted.cells = Some(250);
    expect_fault(&run(&exhausted)?, 1, "cellLimitExceeded", "32:1-32:5")
}
