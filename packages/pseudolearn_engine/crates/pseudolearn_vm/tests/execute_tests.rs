use pseudolearn_bytecode::{SuperInstruction, compile_text, compile_text_with_superinstructions};
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, run, run_profiled};

fn execute_source(source_text: &str, fuel: Fuel) -> pseudolearn_vm::RunResult {
    let verified = compile_text(source_text);
    assert!(verified.is_ok());
    let Some(bytecode) = verified.ok() else {
        return pseudolearn_vm::RunResult {
            exit: RunExit::Trap(pseudolearn_vm::VmTrap {
                code: "invalidTestProgram",
                span: None,
            }),
            output: String::new(),
            consumed_statements: 0,
            consumed_probes: 0,
        };
    };
    run(&bytecode, fuel)
}

#[test]
fn executes_checked_integer_and_real_operations() {
    let integer_source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 40\n  %1 = const.i64 2\n  %2 = int.add %0, %1 @2:1-2:4\n  return %2\n}\n";
    let integer_result = execute_source(integer_source, Fuel::unlimited());
    assert_eq!(
        integer_result.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(42)))
    );

    let real_source = "module P es\nfunc @main() -> f64 {\nb0() mass 0:\n  %0 = const.f64 2.5\n  %1 = const.f64 1.5\n  %2 = real.mul %0, %1 @2:1-2:4\n  return %2\n}\n";
    let real_result = execute_source(real_source, Fuel::unlimited());
    assert_eq!(
        real_result.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(3.75_f64.to_bits())))
    );
}

#[test]
fn reports_integer_trap_with_the_instruction_span() {
    let source_text = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = const.i64 0\n  %2 = int.div %0, %1 @5:3-5:8\n  return %2\n}\n";
    let result = execute_source(source_text, Fuel::unlimited());
    let expected = RunExit::Trap(pseudolearn_vm::VmTrap {
        code: "divisionByZero",
        span: Some(pseudolearn_bytecode::SourceSpan::new(5, 3, 5, 8)),
    });
    assert_eq!(result.exit, expected);
}

#[test]
fn fused_compare_branch_preserves_result_and_profile_counts() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = const.i64 3\n  %2 = int.cmp lt, %0, %1 @2:1-2:4\n  branch %2, b1(), b2()\nb1() mass 0:\n  %3 = const.i64 42\n  return %3\nb2() mass 0:\n  %4 = const.i64 0\n  return %4\n}\n";
    let baseline = compile_text(source);
    let fused = compile_text_with_superinstructions(source, &[SuperInstruction::CompareBranch]);
    assert!(baseline.is_ok());
    assert!(fused.is_ok());
    let (Some(baseline), Some(fused)) = (baseline.ok(), fused.ok()) else {
        return;
    };
    let baseline_result = run(&baseline, Fuel::unlimited());
    let (fused_result, profile) = run_profiled(&fused, Fuel::unlimited());
    assert_eq!(baseline_result, fused_result);
    assert_eq!(
        fused_result.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(42)))
    );
    assert_eq!(profile.opcode_counts.get("IntCmp"), Some(&1));
    assert_eq!(profile.opcode_counts.get("Branch"), Some(&1));
}
