use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{
    Fuel, RunExit, RunOptions, RuntimeValue, TraceClass, TwinMode, load, run_with_options,
};

#[test]
fn awaits_input_when_stream_is_empty() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = in.read i64 @1:1-1:10\n  return %0\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                inputs: Vec::new(),
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(result.exit, RunExit::AwaitingInput);
            assert_eq!(result.inputs_consumed, 0);
            let requested_event = result
                .events
                .iter()
                .find(|event| event.class == TraceClass::InputRequested);
            assert!(requested_event.is_some());
        }
    }
}

#[test]
fn reads_integer_successfully_from_input_stream() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = in.read i64 @1:1-1:10\n  return %0\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                inputs: vec!["42\n".to_owned()],
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(
                result.exit,
                RunExit::Completed(Some(RuntimeValue::Scalar(42)))
            );
            assert_eq!(result.inputs_consumed, 1);
            let received_event = result
                .events
                .iter()
                .find(|event| event.class == TraceClass::InputReceived);
            assert!(received_event.is_some());
        }
    }
}

#[test]
fn retries_on_type_mismatch_and_consumes_next_input() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = in.read i64 @1:1-1:10\n  return %0\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let options = RunOptions {
                twin_mode: TwinMode::Probed,
                inputs: vec!["invalido".to_owned(), "99".to_owned()],
                ..RunOptions::default()
            };
            let result = run_with_options(&program, Fuel::unlimited(), options);
            assert_eq!(
                result.exit,
                RunExit::Completed(Some(RuntimeValue::Scalar(99)))
            );
            assert_eq!(result.inputs_consumed, 2);
            let mismatch_diag = result
                .diagnostics
                .iter()
                .find(|diag| diag.code == "readValueTypeMismatch");
            assert!(mismatch_diag.is_some());
        }
    }
}
