use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, run, run_profiled};

#[test]
fn opcode_profile_matches_execution_and_ignores_observation_markers() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 1:\n  stmt.enter @1:1-1:2\n  %0 = const.i64 2\n  %1 = const.i64 3\n  %2 = int.add %0, %1 @1:1-1:2\n  %3 = const.i64 4\n  %4 = int.mul %2, %3 @1:1-1:2\n  stmt.exit @1:1-1:2\n  return %4\n}\n";
    let bytecode = compile_text(source);
    assert!(bytecode.is_ok());
    let Some(program) = bytecode.ok() else {
        return;
    };
    let regular = run(&program, Fuel::unlimited());
    let (profiled, profile) = run_profiled(&program, Fuel::unlimited());
    assert_eq!(profiled, regular);
    assert_eq!(
        profiled.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(20)))
    );
    assert_eq!(profile.opcode_counts.get("IntAdd"), Some(&1));
    assert_eq!(profile.opcode_counts.get("IntMul"), Some(&1));
    assert_eq!(profile.pair_counts.get("IntAdd->IntMul"), Some(&1));
    assert!(!profile.opcode_counts.contains_key("StmtEnter"));
    assert!(!profile.opcode_counts.contains_key("StmtExit"));
}
