use pseudolearn_bytecode::{SourceSpan, compile_text};
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, VmTrap, run};

fn exit_of(source_text: &str) -> RunExit {
    match compile_text(source_text) {
        Ok(bytecode) => run(&bytecode, Fuel::unlimited()).exit,
        Err(_) => RunExit::Trap(VmTrap {
            code: "invalidTestProgram",
            span: None,
        }),
    }
}

fn uninitialized_at(line: u32) -> RunExit {
    RunExit::Trap(VmTrap {
        code: "uninitializedVariableRead",
        span: Some(SourceSpan::new(line, 1, line, 4)),
    })
}

fn joined_integer(choose_undefined: bool) -> String {
    format!(
        "module P es\nfunc @main() -> i64 {{\nb0() mass 0:\n  %0 = value.undefined i64\n  %1 = const.i64 5\n  %2 = const.bool {choose_undefined}\n  branch %2, b1(%0), b1(%1)\nb1(%3: i64) mass 0:\n  %4 = value.require %3 @3:1-3:4\n  return %4\n}}\n"
    )
}

#[test]
fn defined_integer_flowing_through_a_block_parameter_is_read() {
    assert_eq!(
        exit_of(&joined_integer(false)),
        RunExit::Completed(Some(RuntimeValue::Scalar(5)))
    );
}

#[test]
fn undefined_integer_flowing_through_a_block_parameter_traps() {
    assert_eq!(exit_of(&joined_integer(true)), uninitialized_at(3));
}

#[test]
fn directly_undefined_integer_traps_at_the_require() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = value.undefined i64\n  %1 = value.require %0 @7:1-7:4\n  return %1\n}\n";
    assert_eq!(exit_of(source), uninitialized_at(7));
}

#[test]
fn undefined_real_uses_its_sentinel() {
    let source = "module P es\nfunc @main() -> f64 {\nb0() mass 0:\n  %0 = value.undefined f64\n  %1 = value.require %0 @2:1-2:4\n  return %1\n}\n";
    assert_eq!(exit_of(source), uninitialized_at(2));
}

#[test]
fn undefined_boolean_uses_its_sentinel() {
    let source = "module P es\nfunc @main() -> bool {\nb0() mass 0:\n  %0 = value.undefined bool\n  %1 = value.require %0 @4:1-4:4\n  return %1\n}\n";
    assert_eq!(exit_of(source), uninitialized_at(4));
}

#[test]
fn defined_character_passes_the_require() {
    let source = "module P es\nfunc @main() -> char {\nb0() mass 0:\n  %0 = value.undefined char\n  %1 = const.char 'a'\n  %2 = const.bool false\n  branch %2, b1(%0), b1(%1)\nb1(%3: char) mass 0:\n  %4 = value.require %3 @3:1-3:4\n  return %4\n}\n";
    assert_eq!(
        exit_of(source),
        RunExit::Completed(Some(RuntimeValue::Scalar(u64::from(u32::from('a')))))
    );
}

#[test]
fn swapped_block_arguments_keep_their_values() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = const.i64 2\n  %2 = const.i64 0\n  jump b1(%0, %1, %2)\nb1(%3: i64, %4: i64, %5: i64) mass 0:\n  %6 = const.i64 1\n  %7 = int.cmp lt, %5, %6\n  branch %7, b2(), b3()\nb2() mass 0:\n  %8 = const.i64 1\n  %9 = int.add %5, %8 @1:1-1:2\n  jump b1(%4, %3, %9)\nb3() mass 0:\n  %10 = const.i64 10\n  %11 = int.mul %3, %10 @1:1-1:2\n  %12 = int.add %11, %4 @1:1-1:2\n  return %12\n}\n";
    assert_eq!(
        exit_of(source),
        RunExit::Completed(Some(RuntimeValue::Scalar(21)))
    );
}
