use pseudolearn_bytecode::{VerifiedBytecode, compile_text};
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, ServiceReason, run};

fn compile_source(source_text: &str) -> Option<VerifiedBytecode> {
    compile_text(source_text).ok()
}

#[test]
fn recursive_calls_return_through_shared_continuation_identity() {
    let source_text = "module P es\nfunc @sum(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = const.i64 0\n  %2 = int.cmp le, %0, %1\n  branch %2, b1(), b2(%0)\nb1() mass 0:\n  return %1\nb2(%3: i64) mass 0:\n  %4 = const.i64 1\n  %5 = int.sub %3, %4 @9:1-9:3\n  %6 = call @sum(%5) @10:1-10:5\n  %7 = int.add %3, %6 @11:1-11:3\n  return %7\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 4\n  %1 = call @sum(%0) @15:1-15:5\n  return %1\n}\n";
    let compiled = compile_text(source_text);
    assert!(compiled.is_ok(), "{compiled:?}");
    let verified = compiled.ok();
    assert!(verified.is_some());
    if let Some(verified) = verified {
        let result = run(&verified, Fuel::unlimited());
        assert_eq!(
            result.exit,
            RunExit::Completed(Some(RuntimeValue::Scalar(10)))
        );
    }
}

#[test]
fn enforces_exact_statement_fuel_at_block_entry() {
    let source_text =
        "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @1:1-1:3\n  return\n}\n";
    let verified = compile_source(source_text);
    assert!(verified.is_some());
    if let Some(verified) = verified {
        let exhausted = run(
            &verified,
            Fuel {
                statements: 0,
                probes: 4,
            },
        );
        assert_eq!(exhausted.exit, RunExit::Service(ServiceReason::Statements));
        assert_eq!(exhausted.consumed_statements, 0);
        let exact = run(
            &verified,
            Fuel {
                statements: 1,
                probes: 4,
            },
        );
        assert_eq!(exact.exit, RunExit::Completed(None));
        assert_eq!(exact.consumed_statements, 1);
    }
}

#[test]
fn empty_backedges_use_independent_probe_fuel() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  jump b1()\nb1() mass 0:\n  jump b1()\n}\n";
    let verified = compile_source(source_text);
    assert!(verified.is_some());
    if let Some(verified) = verified {
        let result = run(
            &verified,
            Fuel {
                statements: 100,
                probes: 0,
            },
        );
        assert_eq!(result.exit, RunExit::Service(ServiceReason::Probe));
        assert_eq!(result.consumed_probes, 0);
    }
}

#[test]
fn statement_fuel_stops_exactly_at_the_exhausting_block() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @1:1-1:3\n  jump b1()\nb1() mass 2:\n  stmt.enter @2:1-2:3\n  stmt.enter @3:1-3:3\n  return\n}\n";
    let verified = compile_source(source_text);
    assert!(verified.is_some());
    if let Some(verified) = verified {
        let short = run(
            &verified,
            Fuel {
                statements: 2,
                probes: 0,
            },
        );
        assert_eq!(short.exit, RunExit::Service(ServiceReason::Statements));
        assert_eq!(short.consumed_statements, 1);
        let exact = run(
            &verified,
            Fuel {
                statements: 3,
                probes: 0,
            },
        );
        assert_eq!(exact.exit, RunExit::Completed(None));
        assert_eq!(exact.consumed_statements, 3);
    }
}

#[test]
fn empty_loop_consumes_every_probe_before_service() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  jump b1()\nb1() mass 0:\n  jump b1()\n}\n";
    let verified = compile_source(source_text);
    assert!(verified.is_some());
    if let Some(verified) = verified {
        let result = run(
            &verified,
            Fuel {
                statements: 0,
                probes: 5,
            },
        );
        assert_eq!(result.exit, RunExit::Service(ServiceReason::Probe));
        assert_eq!(result.consumed_probes, 5);
    }
}
