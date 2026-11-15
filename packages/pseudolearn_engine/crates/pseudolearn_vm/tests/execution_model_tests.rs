use std::sync::Arc;
use std::sync::atomic::AtomicBool;

use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunExit, RunOptions, TwinMode, load, run_with_options};

#[test]
fn cancels_at_statement_threshold() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 3:\n  stmt.enter @1:1-1:5\n  stmt.exit @1:1-1:5\n  stmt.enter @2:1-2:5\n  stmt.exit @2:1-2:5\n  stmt.enter @3:1-3:5\n  stmt.exit @3:1-3:5\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                cancel_at_statement: Some(2),
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(result.exit, RunExit::Cancelled);
        }
    }
}

#[test]
fn cancels_in_zero_mass_loop_via_poll() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.bool true\n  jump b1()\nb1() mass 0:\n  decide.bool %0 @1:1-1:5\n  branch %0, b1(), b2()\nb2() mass 0:\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                cancel_at_poll: Some(5),
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(result.exit, RunExit::Cancelled);
        }
    }
}

#[test]
fn cancels_via_external_atomic_flag() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 2:\n  stmt.enter @1:1-1:5\n  stmt.exit @1:1-1:5\n  stmt.enter @2:1-2:5\n  stmt.exit @2:1-2:5\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let flag = Arc::new(AtomicBool::new(true));
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                cancelled: Some(Arc::clone(&flag)),
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(result.exit, RunExit::Cancelled);
        }
    }
}
