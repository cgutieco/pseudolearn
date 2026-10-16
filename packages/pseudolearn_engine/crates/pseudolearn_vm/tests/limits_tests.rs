use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, LimitKind, RunExit, RunOptions, TwinMode, load, run_with_options};

#[test]
fn statement_budget_stops_at_exact_limit_and_records_diagnostic() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 3:\n  stmt.enter @1:1-1:5\n  %0 = const.i64 1\n  out.write %0, newline @1:1-1:5\n  stmt.exit @1:1-1:5\n  stmt.enter @2:1-2:5\n  %1 = const.i64 2\n  out.write %1, newline @2:1-2:5\n  stmt.exit @2:1-2:5\n  stmt.enter @3:1-3:5\n  %2 = const.i64 3\n  out.write %2, newline @3:1-3:5\n  stmt.exit @3:1-3:5\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Fast,
                statement_limit: Some(2),
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(
                result.exit,
                RunExit::LimitReached {
                    kind: LimitKind::Statements,
                }
            );
            assert_eq!(result.output, "1\n2\n");
            let diagnostic = result
                .diagnostics
                .iter()
                .find(|diag| diag.code == "statementBudgetExhausted");
            assert!(diagnostic.is_some());
            if let Some(trap) = diagnostic {
                assert!(trap.arguments.contains_key("limit"));
            }
        }
    }
}

#[test]
fn recursion_depth_limit_traps_without_overflowing_host_stack() {
    let source = "module P es\nfunc @inf() -> unit {\nb0() mass 0:\n  call @inf() @2:1-2:10\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  call @inf() @6:1-6:10\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                depth: 10,
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert!(matches!(
                result.exit,
                RunExit::Trap(ref trap) if trap.code == "recursionDepthExceeded"
            ));
        }
    }
}
