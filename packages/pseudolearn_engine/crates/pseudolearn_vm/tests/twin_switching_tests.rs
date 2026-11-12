use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunExit, RunOptions, RuntimeValue, TwinMode, load, run_with_options};

#[test]
fn fast_and_probed_twins_produce_identical_output_and_value() {
    let source = "module P es\nfunc @factorial(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = const.i64 1\n  %2 = int.cmp le, %0, %1 @2:1-2:10\n  branch %2, b1(), b2(%0)\nb1() mass 0:\n  return %1\nb2(%3: i64) mass 0:\n  %4 = const.i64 1\n  %5 = int.sub %3, %4 @4:1-4:5\n  %6 = call @factorial(%5) @4:1-4:15\n  %7 = int.mul %3, %6 @4:1-4:20\n  return %7\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 5\n  %1 = call @factorial(%0) @8:1-8:15\n  return %1\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let fast_options = RunOptions {
                twin_mode: TwinMode::Fast,
                ..RunOptions::default()
            };
            let fast_result = run_with_options(&program, Fuel::unlimited(), fast_options);

            let probed_options = RunOptions {
                twin_mode: TwinMode::Probed,
                ..RunOptions::default()
            };
            let probed_result = run_with_options(&program, Fuel::unlimited(), probed_options);

            assert_eq!(
                fast_result.exit,
                RunExit::Completed(Some(RuntimeValue::Scalar(120)))
            );
            assert_eq!(fast_result.exit, probed_result.exit);
            assert_eq!(fast_result.output, probed_result.output);
            assert!(fast_result.events.is_empty());
            assert!(!probed_result.events.is_empty());
        }
    }
}

#[test]
fn twin_execution_across_helper_calls_and_returns() {
    let source = "module P es\nfunc @helper(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = const.i64 7\n  %2 = int.add %0, %1 @3:1-3:10\n  return %2\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 35\n  %1 = call @helper(%0) @8:1-8:10\n  return %1\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let fast_result = run_with_options(
                &program,
                Fuel::unlimited(),
                RunOptions {
                    twin_mode: TwinMode::Fast,
                    ..RunOptions::default()
                },
            );
            let probed_result = run_with_options(
                &program,
                Fuel::unlimited(),
                RunOptions {
                    twin_mode: TwinMode::Probed,
                    ..RunOptions::default()
                },
            );
            assert_eq!(
                fast_result.exit,
                RunExit::Completed(Some(RuntimeValue::Scalar(42)))
            );
            assert_eq!(fast_result.exit, probed_result.exit);
            assert_eq!(fast_result.output, probed_result.output);
        }
    }
}
