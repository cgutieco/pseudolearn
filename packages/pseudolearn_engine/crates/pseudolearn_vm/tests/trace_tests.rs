use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{
    EventPayload, Fuel, RunExit, RunOptions, TraceClass, TwinMode, run_with_options,
};

#[test]
fn probed_mode_emits_structured_events_and_fast_mode_stays_clean() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 2:\n  stmt.enter @1:1-1:5\n  %0 = const.i64 10\n  out.write %0, newline @1:1-1:5\n  stmt.exit @1:1-1:5\n  stmt.enter @2:1-2:5\n  stmt.exit @2:1-2:5\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = pseudolearn_vm::load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let fast_options = RunOptions {
                twin_mode: TwinMode::Fast,
                ..RunOptions::default()
            };
            let fast_result = run_with_options(&program, Fuel::unlimited(), fast_options);
            assert_eq!(fast_result.exit, RunExit::Completed(None));
            assert!(fast_result.events.is_empty());
            assert_eq!(fast_result.output, "10\n");

            let probed_options = RunOptions {
                twin_mode: TwinMode::Probed,
                ..RunOptions::default()
            };
            let probed_result = run_with_options(&program, Fuel::unlimited(), probed_options);
            assert_eq!(probed_result.exit, RunExit::Completed(None));
            assert_eq!(probed_result.output, "10\n");
            assert!(!probed_result.events.is_empty());

            let classes = probed_result
                .events
                .iter()
                .map(|event| event.class)
                .collect::<Vec<_>>();
            assert!(classes.contains(&TraceClass::StatementEntered));
            assert!(classes.contains(&TraceClass::Output));
            assert!(classes.contains(&TraceClass::StatementExited));
        }
    }
}

#[test]
fn decision_events_record_affirmative_and_negative_branches() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 1\n  %3 = int.cmp lt, %1, %2 @4:10-4:15\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = pseudolearn_vm::load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let probed_options = RunOptions {
                twin_mode: TwinMode::Probed,
                ..RunOptions::default()
            };
            let probed_result = run_with_options(&program, Fuel::unlimited(), probed_options);
            assert_eq!(probed_result.exit, RunExit::Completed(None));
            let decision_event = probed_result
                .events
                .iter()
                .find(|event| event.class == TraceClass::Decision);
            assert!(decision_event.is_some());
            if let Some(event) = decision_event {
                assert_eq!(
                    event.payload,
                    Some(EventPayload::Decision {
                        rama: "afirmativa".to_owned(),
                        indice: None,
                    })
                );
            }
        }
    }
}

#[test]
fn failure_event_is_recorded_on_runtime_trap() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @1:1-1:10\n  %0 = const.i64 10\n  %1 = const.i64 0\n  %2 = int.div %0, %1 @1:1-1:10\n  return\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok(), "{compiled:?}");
    if let Ok(bytecode) = compiled {
        let loaded = pseudolearn_vm::load(&bytecode);
        assert!(loaded.is_ok(), "{loaded:?}");
        if let Ok(program) = loaded {
            let probed_options = RunOptions {
                twin_mode: TwinMode::Probed,
                ..RunOptions::default()
            };
            let probed_result = run_with_options(&program, Fuel::unlimited(), probed_options);
            assert!(matches!(probed_result.exit, RunExit::Trap(_)));
            let failure_event = probed_result
                .events
                .iter()
                .find(|event| event.class == TraceClass::Failure);
            assert!(failure_event.is_some());
            if let Some(event) = failure_event {
                assert_eq!(
                    event.payload,
                    Some(EventPayload::Failure {
                        codigo: "divisionByZero".to_owned(),
                    })
                );
            }
        }
    }
}
