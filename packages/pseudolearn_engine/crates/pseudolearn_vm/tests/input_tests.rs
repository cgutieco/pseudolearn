use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{
    EventField, EventPayload, Fuel, RunExit, RunOptions, RuntimeValue, TraceClass, TwinMode, load,
    run_with_options,
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

fn probed_run(value_type: &str, inputs: &[&str]) -> Option<pseudolearn_vm::RunResult> {
    let source = format!(
        "module P es\nfunc @main() -> {value_type} {{\nb0() mass 0:\n  %0 = in.read {value_type} @1:1-1:10\n  return %0\n}}\n"
    );
    let bytecode = compile_text(&source).ok()?;
    let program = load(&bytecode).ok()?;
    let options = RunOptions {
        twin_mode: TwinMode::Probed,
        inputs: inputs.iter().map(|text| (*text).to_owned()).collect(),
        ..RunOptions::default()
    };
    Some(run_with_options(&program, Fuel::unlimited(), options))
}

fn requested_types(result: &pseudolearn_vm::RunResult) -> Vec<String> {
    result
        .events
        .iter()
        .filter(|event| event.class == TraceClass::InputRequested)
        .filter_map(|event| match &event.payload {
            Some(EventPayload::Fields(fields)) => {
                fields
                    .iter()
                    .find_map(|(name, field)| match (*name, field) {
                        ("tipo", EventField::Text(text)) => Some(text.clone()),
                        _ => None,
                    })
            }
            _ => None,
        })
        .collect()
}

fn input_classes(result: &pseudolearn_vm::RunResult) -> Vec<TraceClass> {
    result
        .events
        .iter()
        .map(|event| event.class)
        .filter(|class| {
            matches!(
                class,
                TraceClass::InputRequested | TraceClass::InputReceived
            )
        })
        .collect()
}

#[test]
fn requested_event_names_the_expected_type_of_each_read_kind() {
    let expectations = [
        ("i64", "entero"),
        ("f64", "real"),
        ("bool", "logico"),
        ("char", "caracter"),
        ("str", "cadena"),
    ];
    for (value_type, expected) in expectations {
        let result = probed_run(value_type, &[]);
        assert!(result.is_some(), "{value_type}");
        if let Some(result) = result {
            assert_eq!(result.exit, RunExit::AwaitingInput);
            assert_eq!(requested_types(&result), vec![expected.to_owned()]);
        }
    }
}

#[test]
fn rejected_value_requests_the_same_position_again() {
    let result = probed_run("i64", &["invalido", "99"]);
    assert!(result.is_some());
    if let Some(result) = result {
        assert_eq!(
            input_classes(&result),
            vec![
                TraceClass::InputRequested,
                TraceClass::InputRequested,
                TraceClass::InputReceived,
            ]
        );
        assert_eq!(
            requested_types(&result),
            vec!["entero".to_owned(), "entero".to_owned()]
        );
    }
}

#[test]
fn rejected_value_without_replacement_waits_after_a_new_request() {
    let result = probed_run("char", &["ab"]);
    assert!(result.is_some());
    if let Some(result) = result {
        assert_eq!(result.exit, RunExit::AwaitingInput);
        assert_eq!(
            input_classes(&result),
            vec![TraceClass::InputRequested, TraceClass::InputRequested]
        );
    }
}

#[test]
fn empty_text_is_accepted_without_a_new_request() {
    let result = probed_run("str", &[""]);
    assert!(result.is_some());
    if let Some(result) = result {
        assert_eq!(
            input_classes(&result),
            vec![TraceClass::InputRequested, TraceClass::InputReceived]
        );
    }
}
