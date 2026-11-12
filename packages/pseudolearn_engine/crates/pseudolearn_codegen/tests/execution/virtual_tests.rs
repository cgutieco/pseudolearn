use crate::support::{Call, Failure, Kind, Signature, expect_fault, expect_value, shared_with};
use pseudolearn_ir::Module;
use std::sync::OnceLock;

static HARNESS: OnceLock<Result<crate::support::Harness, Failure>> = OnceLock::new();

const MODULE: &str = "module P es
class Animal { age: i64 }
class Dog : Animal { }
class Cat : Animal { }
class Bird : Animal { }
func @Animal.sound(%0: obj<Animal>) -> i64 {
b0() mass 0:
  %1 = const.i64 1
  return %1
}
func @Dog.sound(%0: obj<Dog>) -> i64 {
b0() mass 0:
  %1 = const.i64 2
  return %1
}
func @Bird.sound(%0: obj<Bird>) -> i64 {
b0() mass 0:
  %1 = object.load %0, age @1:1-1:5
  return %1
}
func @Animal.birthday(%0: obj<Animal>) -> unit {
b0() mass 0:
  %1 = object.load %0, age @2:1-2:5
  %2 = const.i64 1
  %3 = int.add %1, %2 @3:1-3:5
  object.store %0, age, %3
  return
}
func @Animal.recurse(%0: obj<Animal>) -> i64 {
b0() mass 0:
  %1 = call.virtual %0, @Animal.recurse(%0) @4:1-4:5
  return %1
}
func @Animal.churn(%0: obj<Animal>) -> i64 {
b0() mass 0:
  %1 = const.i64 20
  %2 = const.i64 0
  %3 = const.i64 60
  jump b1(%2)
b1(%4: i64) mass 0:
  %5 = int.cmp lt, %4, %3
  branch %5, b2(), b3()
b2() mass 0:
  %6 = array.new array<i64, 1>, %1 @5:1-5:5
  %7 = const.i64 1
  %8 = int.add %4, %7 @6:1-6:5
  jump b1(%8)
b3() mass 0:
  return %2
}
func @make(%0: i64) -> obj<Animal> {
b0() mass 0:
  %1 = const.i64 0
  %2 = int.cmp eq, %0, %1
  branch %2, b1(), b2()
b1() mass 0:
  %3 = object.new Animal @7:1-7:5
  return %3
b2() mass 0:
  %4 = const.i64 1
  %5 = int.cmp eq, %0, %4
  branch %5, b3(), b4()
b3() mass 0:
  %6 = object.new Dog @8:1-8:5
  return %6
b4() mass 0:
  %7 = const.i64 2
  %8 = int.cmp eq, %0, %7
  branch %8, b5(), b6()
b5() mass 0:
  %9 = object.new Cat @9:1-9:5
  return %9
b6() mass 0:
  %10 = object.new Bird @10:1-10:5
  %11 = const.i64 33
  object.store %10, age, %11
  return %10
}
func @speak(%0: i64) -> i64 {
b0() mass 0:
  %1 = call @make(%0) @11:1-11:5
  %2 = call.virtual %1, @Animal.sound(%1) @12:1-12:5
  return %2
}
func @grow(%0: i64) -> i64 {
b0() mass 0:
  %1 = call @make(%0) @13:1-13:5
  %2 = const.i64 4
  object.store %1, age, %2
  call.virtual %1, @Animal.birthday(%1) @14:1-14:5
  call.virtual %1, @Animal.birthday(%1) @15:1-15:5
  %3 = object.load %1, age @16:1-16:5
  return %3
}
func @absent() -> i64 {
b0() mass 0:
  %0 = value.undefined obj<Animal>
  %1 = call.virtual %0, @Animal.sound(%0) @17:1-17:5
  return %1
}
func @runaway() -> i64 {
b0() mass 0:
  %0 = const.i64 0
  %1 = call @make(%0) @19:1-19:5
  %2 = call.virtual %1, @Animal.recurse(%1) @20:1-20:5
  return %2
}
func @churned() -> i64 {
b0() mass 0:
  %0 = const.i64 8
  %1 = array.new array<i64, 1>, %0 @21:1-21:5
  %2 = const.i64 0
  %3 = const.i64 55
  array.store %1, %2, %3 @22:1-22:5
  %4 = call @make(%3) @23:1-23:5
  %5 = call.virtual %4, @Animal.churn(%4) @24:1-24:5
  %6 = array.load %1, %2 @25:1-25:5
  return %6
}
";

const SPEAK: usize = 7;
const GROW: usize = 8;
const ABSENT: usize = 9;
const RUNAWAY: usize = 10;
const CHURNED: usize = 11;

fn signatures() -> Vec<Signature> {
    let function = |parameters: Vec<Kind>, returns: Kind| Signature {
        parameters,
        returns,
    };
    let receiver = || vec![Kind::Handle];
    let integer = || vec![Kind::Integer];
    vec![
        function(receiver(), Kind::Integer),
        function(receiver(), Kind::Integer),
        function(receiver(), Kind::Integer),
        function(receiver(), Kind::Unit),
        function(receiver(), Kind::Integer),
        function(receiver(), Kind::Integer),
        function(integer(), Kind::Handle),
        function(integer(), Kind::Integer),
        function(integer(), Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Integer),
        function(vec![], Kind::Integer),
    ]
}

fn attach_methods(module: &mut Module) {
    let methods = [
        (0, "sound", "@Animal.sound"),
        (0, "birthday", "@Animal.birthday"),
        (0, "recurse", "@Animal.recurse"),
        (0, "churn", "@Animal.churn"),
        (1, "sound", "@Dog.sound"),
        (3, "sound", "@Bird.sound"),
    ];
    for (class, name, target) in methods {
        if let Some(declaration) = module.classes.get_mut(class) {
            declaration
                .methods
                .push((name.to_owned(), target.to_owned()));
        }
    }
}

fn run(call: &Call) -> Result<crate::support::Outcome, Failure> {
    shared_with(&HARNESS, MODULE, (&signatures(), attach_methods))?.run(call)
}

#[test]
fn the_implementation_follows_the_class_of_the_receiver() -> Result<(), Failure> {
    expect_value(&run(&Call::with(SPEAK, &["0"]))?, "1")?;
    expect_value(&run(&Call::with(SPEAK, &["1"]))?, "2")?;
    expect_value(&run(&Call::with(SPEAK, &["2"]))?, "1")?;
    expect_value(&run(&Call::with(SPEAK, &["3"]))?, "33")
}

#[test]
fn virtual_calls_without_a_result_mutate_the_receiver() -> Result<(), Failure> {
    expect_value(&run(&Call::with(GROW, &["1"]))?, "6")
}

#[test]
fn an_absent_receiver_traps_at_the_call_site() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(ABSENT, &[]))?,
        1,
        "uninitializedVariableRead",
        "17:1-17:5",
    )
}

#[test]
fn unbounded_virtual_recursion_stops_at_the_frame_limit() -> Result<(), Failure> {
    expect_fault(
        &run(&Call::with(RUNAWAY, &[]))?,
        1,
        "recursionDepthExceeded",
        "4:1-4:5",
    )
}

#[test]
fn references_held_by_the_caller_survive_allocations_in_the_callee() -> Result<(), Failure> {
    let mut call = Call::with(CHURNED, &[]);
    call.cells = Some(150);
    expect_value(&run(&call)?, "55")
}
