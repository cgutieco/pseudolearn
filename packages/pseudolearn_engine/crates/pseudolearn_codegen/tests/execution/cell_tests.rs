use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
class Counter { value: i64 }
func @bump(%0: cell<i64>) -> unit {
b0() mass 0:
  %1 = cell.load %0 @1:1-1:5
  %2 = const.i64 1
  %3 = int.add %1, %2 @2:1-2:5
  cell.store %0, %3
  return
}
func @local_cell() -> i64 {
b0() mass 0:
  %0 = cell.local i64
  %1 = const.i64 5
  cell.store %0, %1
  call @bump(%0) @3:1-3:5
  call @bump(%0) @4:1-4:5
  %2 = cell.load %0 @5:1-5:5
  return %2
}
func @unset_local() -> i64 {
b0() mass 0:
  %0 = cell.local i64
  call @bump(%0) @6:1-6:5
  %1 = cell.load %0 @7:1-7:5
  return %1
}
func @element_cell(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @8:1-8:5
  %3 = const.i64 1
  %4 = cell.element %2, %0 @9:1-9:5
  %5 = const.i64 10
  cell.store %4, %5
  call @bump(%4) @10:1-10:5
  %6 = array.load %2, %3 @11:1-11:5
  return %6
}
func @field_cell() -> i64 {
b0() mass 0:
  %0 = object.new Counter @12:1-12:5
  %1 = const.i64 20
  object.store %0, value, %1
  %2 = cell.field %0, value
  call @bump(%2) @13:1-13:5
  %3 = object.load %0, value @14:1-14:5
  return %3
}
func @real_cell() -> f64 {
b0() mass 0:
  %0 = cell.local f64
  %1 = const.f64 0.25
  cell.store %0, %1
  %2 = cell.load %0 @15:1-15:5
  return %2
}
func @unset_real_cell() -> f64 {
b0() mass 0:
  %0 = cell.local f64
  %1 = cell.load %0 @16:1-16:5
  return %1
}
func @boolean_cell() -> bool {
b0() mass 0:
  %0 = cell.local bool
  %1 = const.bool true
  cell.store %0, %1
  %2 = cell.load %0 @17:1-17:5
  return %2
}
func @text_cell(%0: i64) -> i64 {
b0() mass 0:
  %1 = cell.local str
  %2 = const.str \"ab\"
  %3 = const.str \"cd\"
  %4 = text.concat %2, %3 @18:1-18:5
  cell.store %1, %4
  %5 = const.i64 0
  %6 = const.i64 20
  jump b1(%5)
b1(%7: i64) mass 0:
  %8 = int.cmp lt, %7, %0
  branch %8, b2(), b3()
b2() mass 0:
  %9 = array.new array<i64, 1>, %6 @19:1-19:5
  %10 = const.i64 1
  %11 = int.add %7, %10 @20:1-20:5
  jump b1(%11)
b3() mass 0:
  %12 = cell.load %1 @21:1-21:5
  %13 = text.length %12
  return %13
}
";

const LOCAL_CELL: usize = 1;
const UNSET_LOCAL: usize = 2;
const ELEMENT_CELL: usize = 3;
const FIELD_CELL: usize = 4;
const REAL_CELL: usize = 5;
const UNSET_REAL_CELL: usize = 6;
const BOOLEAN_CELL: usize = 7;
const TEXT_CELL: usize = 8;

fn signatures() -> Vec<Signature> {
    let function = |parameters: Vec<Kind>, returns: Kind| Signature {
        parameters,
        returns,
    };
    vec![
        function(vec![Kind::Handle], Kind::Unit),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![Kind::Integer], Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Real),
        function(vec![], Kind::Real),
        function(vec![], Kind::Boolean),
        function(vec![Kind::Integer], Kind::Integer),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn a_callee_updates_the_caller_local_through_the_cell() -> Result<(), Failure> {
    expect_value(&run(&Call::with(LOCAL_CELL, &[]))?, "7")
}

#[test]
fn a_local_cell_without_value_traps_in_the_callee() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(UNSET_LOCAL, &[]))?,
        1,
        "uninitializedVariableRead",
        "1:1-1:5",
    )
}

#[test]
fn element_cells_alias_the_array_slot() -> Result<(), Failure> {
    expect_value(&run(&Call::with(ELEMENT_CELL, &["1"]))?, "11")?;
    expect_fault(
        &run(&Call::with(ELEMENT_CELL, &["3"]))?,
        1,
        "arrayIndexOutOfRange",
        "9:1-9:5",
    )
}

#[test]
fn field_cells_alias_the_object_field() -> Result<(), Failure> {
    expect_value(&run(&Call::with(FIELD_CELL, &[]))?, "21")
}

#[test]
fn real_and_boolean_cells_keep_their_representation() -> Result<(), Failure> {
    expect_value(&run(&Call::with(REAL_CELL, &[]))?, "0.25")?;
    expect_value(&run(&Call::with(BOOLEAN_CELL, &[]))?, "1")?;
    expect_fault(
        &run(&Call::with(UNSET_REAL_CELL, &[]))?,
        1,
        "uninitializedVariableRead",
        "16:1-16:5",
    )
}

#[test]
fn text_held_only_by_a_cell_survives_collections() -> Result<(), Failure> {
    let mut call = Call::with(TEXT_CELL, &["100"]);
    call.cells = Some(120);
    expect_value(&run(&call)?, "4")
}
