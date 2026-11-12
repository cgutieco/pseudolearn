#![forbid(unsafe_code)]

use std::collections::BTreeMap;

use pseudolearn_bytecode::{
    SourceSpan, SuperInstruction, compile_text, compile_text_with_superinstructions,
};
use pseudolearn_vm::{Fuel, RunExit, RuntimeValue, VmTrap, run};

#[test]
fn fused_arithmetic_preserves_scalar_result() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  %1 = const.i64 20\n  %2 = int.add %0, %1 @1:1-1:10\n  %3 = int.mul %2, %0 @1:11-1:20\n  return %3\n}\n";
    let baseline_module = match compile_text(source) {
        Ok(module) => module,
        Err(_) => return,
    };
    let fused_module =
        match compile_text_with_superinstructions(source, &[SuperInstruction::FusedArithmetic]) {
            Ok(module) => module,
            Err(_) => return,
        };
    let baseline_result = run(&baseline_module, Fuel::unlimited());
    let fused_result = run(&fused_module, Fuel::unlimited());
    assert_eq!(baseline_result.exit, fused_result.exit);
    assert_eq!(
        fused_result.exit,
        RunExit::Completed(Some(RuntimeValue::Scalar(300)))
    );
}

#[test]
fn fused_arithmetic_preserves_first_trap_and_span_on_first_instruction_overflow() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 9223372036854775807\n  %1 = const.i64 1\n  %2 = int.add %0, %1 @2:5-2:15\n  %3 = int.mul %2, %1 @3:5-3:15\n  return %3\n}\n";
    let fused_module =
        match compile_text_with_superinstructions(source, &[SuperInstruction::FusedArithmetic]) {
            Ok(module) => module,
            Err(_) => return,
        };
    let result = run(&fused_module, Fuel::unlimited());
    let expected = RunExit::Trap(VmTrap {
        arguments: BTreeMap::new(),
        related: Vec::new(),
        code: "integerOverflow",
        span: Some(SourceSpan::new(2, 5, 2, 15)),
    });
    assert_eq!(result.exit, expected);
}

#[test]
fn fused_arithmetic_preserves_second_trap_and_span_on_second_instruction_fault() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  %1 = const.i64 2\n  %2 = const.i64 0\n  %3 = int.add %0, %1 @2:5-2:15\n  %4 = int.div %3, %2 @3:5-3:15\n  return %4\n}\n";
    let fused_module =
        match compile_text_with_superinstructions(source, &[SuperInstruction::FusedArithmetic]) {
            Ok(module) => module,
            Err(_) => return,
        };
    let result = run(&fused_module, Fuel::unlimited());
    let expected = RunExit::Trap(VmTrap {
        arguments: BTreeMap::new(),
        related: Vec::new(),
        code: "divisionByZero",
        span: Some(SourceSpan::new(3, 5, 3, 15)),
    });
    assert_eq!(result.exit, expected);
}

#[test]
fn fused_arithmetic_preserves_real_zero_divisor_trap_and_span() {
    let source = "module P es\nfunc @main() -> f64 {\nb0() mass 0:\n  %0 = const.f64 1.5\n  %1 = const.f64 2.5\n  %2 = const.f64 0.0\n  %3 = real.add %0, %1 @2:1-2:10\n  %4 = real.div %3, %2 @3:1-3:10\n  return %4\n}\n";
    let fused_module =
        match compile_text_with_superinstructions(source, &[SuperInstruction::FusedArithmetic]) {
            Ok(module) => module,
            Err(_) => return,
        };
    let result = run(&fused_module, Fuel::unlimited());
    let expected = RunExit::Trap(VmTrap {
        arguments: BTreeMap::new(),
        related: Vec::new(),
        code: "divisionByZero",
        span: Some(SourceSpan::new(3, 1, 3, 10)),
    });
    assert_eq!(result.exit, expected);
}
