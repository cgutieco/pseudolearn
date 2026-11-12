use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared};
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
func @fill_sum(%0: i64) -> i64 {
b0() mass 0:
  %1 = array.new array<i64, 1>, %0 @1:1-1:5
  %2 = const.i64 0
  %3 = const.i64 1
  jump b1(%2)
b1(%4: i64) mass 0:
  %5 = int.cmp lt, %4, %0
  branch %5, b2(), b3()
b2() mass 0:
  %6 = int.add %4, %4 @2:1-2:5
  array.store %1, %4, %6 @3:1-3:5
  %7 = int.add %4, %3 @4:1-4:5
  jump b1(%7)
b3() mass 0:
  %8 = const.i64 0
  jump b4(%8, %8)
b4(%9: i64, %10: i64) mass 0:
  %11 = int.cmp lt, %9, %0
  branch %11, b5(), b6()
b5() mass 0:
  %12 = array.load %1, %9 @5:1-5:5
  %13 = int.add %10, %12 @6:1-6:5
  %14 = int.add %9, %3 @7:1-7:5
  jump b4(%14, %13)
b6() mass 0:
  return %10
}
func @read_unset(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @10:1-10:5
  %3 = array.load %2, %0 @11:1-11:5
  return %3
}
func @write_at(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 3
  %2 = array.new array<i64, 1>, %1 @12:1-12:5
  %3 = const.i64 8
  array.store %2, %0, %3 @13:1-13:5
  return %3
}
func @matrix() -> i64 {
b0() mass 0:
  %0 = const.i64 2
  %1 = const.i64 3
  %2 = array.new array<i64, 2>, %0, %1 @14:1-14:5
  %3 = const.i64 7
  %4 = const.i64 9
  %5 = const.i64 1
  %6 = const.i64 0
  array.store %2, %5, %0, %3 @15:1-15:5
  array.store %2, %6, %0, %4 @16:1-16:5
  %7 = array.load %2, %5, %0 @17:1-17:5
  %8 = array.load %2, %6, %0 @18:1-18:5
  %9 = int.add %7, %8 @19:1-19:5
  return %9
}
func @matrix_bounds(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = const.i64 2
  %3 = const.i64 3
  %4 = array.new array<i64, 2>, %2, %3 @20:1-20:5
  %5 = const.i64 1
  array.store %4, %2, %3, %5 @21:1-21:5
  array.store %4, %0, %1, %5 @22:1-22:5
  %6 = array.load %4, %0, %1 @23:1-23:5
  return %6
}
func @make(%0: i64) -> i64 {
b0() mass 0:
  %1 = array.new array<i64, 1>, %0 @24:1-24:5
  %2 = const.i64 1
  return %2
}
func @real_cells(%0: i64) -> f64 {
b0() mass 0:
  %1 = const.i64 2
  %2 = array.new array<f64, 1>, %1 @25:1-25:5
  %3 = const.i64 0
  %4 = const.f64 2.5
  array.store %2, %3, %4 @26:1-26:5
  %5 = array.load %2, %0 @27:1-27:5
  return %5
}
func @boolean_cells(%0: i64) -> bool {
b0() mass 0:
  %1 = const.i64 2
  %2 = array.new array<bool, 1>, %1 @28:1-28:5
  %3 = const.i64 0
  %4 = const.bool true
  array.store %2, %3, %4 @29:1-29:5
  %5 = array.load %2, %0 @30:1-30:5
  return %5
}
func @character_cells(%0: i64) -> char {
b0() mass 0:
  %1 = const.i64 2
  %2 = array.new array<char, 1>, %1 @31:1-31:5
  %3 = const.i64 0
  %4 = const.char 'k'
  array.store %2, %3, %4 @32:1-32:5
  %5 = array.load %2, %0 @33:1-33:5
  return %5
}
func @text_cells(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 2
  %2 = array.new array<str, 1>, %1 @34:1-34:5
  %3 = const.i64 0
  %4 = const.str \"abc\"
  array.store %2, %3, %4 @35:1-35:5
  %5 = array.load %2, %0 @36:1-36:5
  %6 = value.require %5 @37:1-37:5
  %7 = text.length %6
  return %7
}
func @sparse() -> i64 {
b0() mass 0:
  %0 = const.i64 130
  %1 = array.new array<i64, 1>, %0 @38:1-38:5
  %2 = const.i64 129
  %3 = const.i64 5
  array.store %1, %2, %3 @39:1-39:5
  %4 = array.load %1, %2 @40:1-40:5
  %5 = const.i64 64
  %6 = array.load %1, %5 @41:1-41:5
  return %4
}
func @retained(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 20
  %2 = array.new array<i64, 1>, %1 @42:1-42:5
  %3 = const.i64 0
  %4 = const.i64 77
  array.store %2, %3, %4 @43:1-43:5
  jump b1(%3)
b1(%5: i64) mass 0:
  %6 = int.cmp lt, %5, %0
  branch %6, b2(), b3()
b2() mass 0:
  %7 = array.new array<i64, 1>, %1 @44:1-44:5
  %8 = const.i64 1
  %9 = int.add %5, %8 @45:1-45:5
  jump b1(%9)
b3() mass 0:
  %10 = array.load %2, %3 @46:1-46:5
  return %10
}
";

const FILL_SUM: usize = 0;
const READ_UNSET: usize = 1;
const WRITE_AT: usize = 2;
const MATRIX: usize = 3;
const MATRIX_BOUNDS: usize = 4;
const MAKE: usize = 5;
const REAL_CELLS: usize = 6;
const BOOLEAN_CELLS: usize = 7;
const CHARACTER_CELLS: usize = 8;
const TEXT_CELLS: usize = 9;
const SPARSE: usize = 10;
const RETAINED: usize = 11;

fn signatures() -> Vec<Signature> {
    let function = |parameters: Vec<Kind>, returns: Kind| Signature {
        parameters,
        returns,
    };
    let integer = || vec![Kind::Integer];
    vec![
        function(integer(), Kind::Integer),
        function(integer(), Kind::Integer),
        function(integer(), Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![Kind::Integer, Kind::Integer], Kind::Integer),
        function(integer(), Kind::Integer),
        function(integer(), Kind::Real),
        function(integer(), Kind::Boolean),
        function(integer(), Kind::Character),
        function(integer(), Kind::Integer),
        function(vec![], Kind::Integer),
        function(integer(), Kind::Integer),
    ]
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared(&HARNESS, MODULE, &signatures())?.run(call)
}

#[test]
fn elements_written_in_a_loop_are_read_back() -> Result<(), Failure> {
    expect_value(&run(&Call::with(FILL_SUM, &["10"]))?, "90")?;
    expect_value(&run(&Call::with(FILL_SUM, &["0"]))?, "0")?;
    expect_value(&run(&Call::with(FILL_SUM, &["1"]))?, "0")
}

#[test]
fn reading_an_unassigned_element_traps_but_out_of_range_wins_first() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(READ_UNSET, &["1"]))?,
        1,
        "uninitializedVariableRead",
        "11:1-11:5",
    )?;
    for index in ["3", "-1", "9223372036854775807"] {
        expect_fault(
            &run(&Call::with(READ_UNSET, &[index]))?,
            1,
            "arrayIndexOutOfRange",
            "11:1-11:5",
        )?;
    }
    Ok(())
}

#[test]
fn writing_outside_the_extent_traps() -> Result<(), Failure> {
    expect_value(&run(&Call::with(WRITE_AT, &["2"]))?, "8")?;
    for index in ["3", "-1"] {
        expect_fault(
            &run(&Call::with(WRITE_AT, &[index]))?,
            1,
            "arrayIndexOutOfRange",
            "13:1-13:5",
        )?;
    }
    Ok(())
}

#[test]
fn multidimensional_access_checks_every_dimension() -> Result<(), Failure> {
    expect_value(&run(&Call::with(MATRIX, &[]))?, "16")?;
    expect_fault(
        &run(&Call::with(MATRIX_BOUNDS, &["0", "0"]))?,
        1,
        "arrayIndexOutOfRange",
        "21:1-21:5",
    )
}

#[test]
fn inner_dimension_overflow_is_not_aliased_to_the_next_row() -> Result<(), Failure> {
    let module = "module P es
func @probe(%0: i64, %1: i64) -> i64 {
b0() mass 0:
  %2 = const.i64 2
  %3 = const.i64 3
  %4 = array.new array<i64, 2>, %2, %3 @1:1-1:5
  %5 = const.i64 1
  array.store %4, %0, %1, %5 @2:1-2:5
  return %5
}
";
    static PROBE: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();
    let signature = Signature {
        parameters: vec![Kind::Integer, Kind::Integer],
        returns: Kind::Integer,
    };
    let harness = shared(&PROBE, module, &[signature])?;
    expect_value(&harness.run(&Call::with(0, &["0", "2"]))?, "1")?;
    expect_fault(
        &harness.run(&Call::with(0, &["0", "3"]))?,
        1,
        "arrayIndexOutOfRange",
        "2:1-2:5",
    )
}

#[test]
fn sizes_are_validated_when_the_array_is_created() -> Result<(), Failure> {
    expect_value(&run(&Call::with(MAKE, &["0"]))?, "1")?;
    expect_fault(
        &run(&Call::with(MAKE, &["-1"]))?,
        1,
        "negativeArraySize",
        "24:1-24:5",
    )?;
    expect_fault(
        &run(&Call::with(MAKE, &["5000000"]))?,
        1,
        "cellLimitExceeded",
        "24:1-24:5",
    )
}

#[test]
fn real_elements_distinguish_unset_from_zero() -> Result<(), Failure> {
    expect_value(&run(&Call::with(REAL_CELLS, &["0"]))?, "2.5")?;
    expect_fault(
        &run(&Call::with(REAL_CELLS, &["1"]))?,
        1,
        "uninitializedVariableRead",
        "27:1-27:5",
    )
}

#[test]
fn boolean_and_character_elements_use_their_own_sentinels() -> Result<(), Failure> {
    expect_value(&run(&Call::with(BOOLEAN_CELLS, &["0"]))?, "1")?;
    expect_fault(
        &run(&Call::with(BOOLEAN_CELLS, &["1"]))?,
        1,
        "uninitializedVariableRead",
        "30:1-30:5",
    )?;
    expect_value(&run(&Call::with(CHARACTER_CELLS, &["0"]))?, "107")?;
    expect_fault(
        &run(&Call::with(CHARACTER_CELLS, &["1"]))?,
        1,
        "uninitializedVariableRead",
        "33:1-33:5",
    )
}

#[test]
fn reference_elements_hold_text_and_report_absence() -> Result<(), Failure> {
    expect_value(&run(&Call::with(TEXT_CELLS, &["0"]))?, "3")?;
    expect_fault(
        &run(&Call::with(TEXT_CELLS, &["1"]))?,
        1,
        "uninitializedVariableRead",
        "36:1-36:5",
    )
}

#[test]
fn definition_masks_span_more_than_one_word_of_integers() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(SPARSE, &[]))?,
        1,
        "uninitializedVariableRead",
        "41:1-41:5",
    )
}

#[test]
fn a_live_array_survives_collections_triggered_by_other_allocations() -> Result<(), Failure> {
    let mut call = Call::with(RETAINED, &["200"]);
    call.cells = Some(400);
    expect_value(&run(&call)?, "77")
}
