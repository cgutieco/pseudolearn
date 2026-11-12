use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, load, run, run_loaded};

const PROGRAM: &str = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 7\n  %1 = const.i64 6\n  %2 = int.mul %0, %1 @1:1-1:2\n  return %2\n}\n";

#[test]
fn loaded_program_runs_repeatedly_with_fresh_state() {
    let compiled = compile_text(PROGRAM);
    assert!(compiled.is_ok());
    let Some(bytecode) = compiled.ok() else {
        return;
    };
    let loaded = load(&bytecode);
    assert!(loaded.is_ok());
    let Some(loaded) = loaded.ok() else {
        return;
    };
    let first = run_loaded(&loaded, Fuel::unlimited());
    let second = run_loaded(&loaded, Fuel::unlimited());
    assert_eq!(first, second);
    assert_eq!(first, run(&bytecode, Fuel::unlimited()));
    assert_eq!(
        first.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(42)))
    );
}

#[test]
fn program_without_main_fails_to_load() {
    let source = "module P es\nfunc @other() -> unit {\nb0() mass 0:\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok());
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_err_and(|trap| trap.code == "missingEntryPoint"));
    }
}

#[test]
fn unsupported_operation_traps_only_when_executed() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.bool false\n  branch %0, b1(), b2()\nb1() mass 0:\n  %1 = const.str \"x\"\n  %2 = text.length %1 @3:1-3:2\n  return %2\nb2() mass 0:\n  %3 = const.i64 1\n  return %3\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        assert_eq!(
            run(&bytecode, Fuel::unlimited()).exit,
            RunExit::Completed(Some(RuntimeValue::Scalar(1)))
        );
    }
}
