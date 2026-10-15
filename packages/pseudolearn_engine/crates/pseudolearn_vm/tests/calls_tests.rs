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

fn countdown(depth: i64) -> String {
    format!(
        "module P es\nfunc @down(%0: i64) -> i64 {{\nb0() mass 0:\n  %1 = const.i64 0\n  %2 = int.cmp le, %0, %1\n  branch %2, b1(), b2()\nb1() mass 0:\n  return %1\nb2() mass 0:\n  %3 = const.i64 1\n  %4 = int.sub %0, %3 @3:1-3:2\n  %5 = call @down(%4) @4:1-4:5\n  %6 = int.add %5, %3 @5:1-5:2\n  return %6\n}}\nfunc @main() -> i64 {{\nb0() mass 0:\n  %0 = const.i64 {depth}\n  %1 = call @down(%0) @9:1-9:5\n  return %1\n}}\n"
    )
}

#[test]
fn deep_recursion_grows_the_banks() {
    assert_eq!(
        exit_of(&countdown(20_000)),
        RunExit::Completed(Some(RuntimeValue::Scalar(20_000)))
    );
}

#[test]
fn zero_depth_returns_without_recursion() {
    assert_eq!(
        exit_of(&countdown(0)),
        RunExit::Completed(Some(RuntimeValue::Scalar(0)))
    );
}

#[test]
fn undefined_argument_reaches_the_callee_as_undefined() {
    let source = "module P es\nfunc @read(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = value.require %0 @2:1-2:4\n  return %1\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = value.undefined i64\n  %1 = call @read(%0) @6:1-6:5\n  return %1\n}\n";
    assert_eq!(
        exit_of(source),
        RunExit::Trap(VmTrap {
            code: "uninitializedVariableRead",
            span: Some(SourceSpan::new(2, 1, 2, 4)),
        })
    );
}

#[test]
fn callee_trap_reports_the_callee_span() {
    let source = "module P es\nfunc @fail(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = const.i64 0\n  %2 = int.div %0, %1 @2:5-2:9\n  return %2\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 3\n  %1 = call @fail(%0) @6:1-6:5\n  return %1\n}\n";
    assert_eq!(
        exit_of(source),
        RunExit::Trap(VmTrap {
            code: "divisionByZero",
            span: Some(SourceSpan::new(2, 5, 2, 9)),
        })
    );
}
