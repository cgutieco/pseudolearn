use pseudolearn_bytecode::{
    BytecodeOperand, SuperInstruction, compile_module, compile_module_with_superinstructions,
};
use pseudolearn_ir::parse_module;

const SIMPLE_IR: &str = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n";

#[test]
fn compiles_verified_ir_to_shared_bytecode_twins() {
    let parsed = parse_module(SIMPLE_IR);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return;
    };
    let compiled = compile_module(&module);
    assert!(compiled.is_ok(), "{compiled:?}");
    let Some(verified) = compiled.ok() else {
        return;
    };
    let function = verified.module().functions.first();
    assert!(function.is_some());
    if let Some(function) = function {
        assert_eq!(function.fast.blocks.len(), 4);
        assert_eq!(function.fast.blocks.len(), function.probed.blocks.len());
        assert!(function.fast.used_length < function.probed.used_length);
        assert!(!function.fast.superinstructions.is_empty());
        assert!(function.fast.instructions.len().is_power_of_two());
        assert!(function.fast.instructions.iter().all(|instruction| {
            !matches!(
                instruction.opcode.as_name(),
                "stmt.enter" | "stmt.exit" | "decide.bool"
            )
        }));
        assert!(function.probed.instructions.iter().any(|instruction| {
            matches!(
                instruction.opcode.as_name(),
                "stmt.enter" | "stmt.exit" | "decide.bool"
            )
        }));
        assert!(
            function
                .constants
                .iter()
                .any(|constant| { matches!(constant, pseudolearn_bytecode::Constant::I64(0)) })
        );
        assert!(function.fast.instructions.iter().any(|instruction| {
            instruction
                .operands
                .iter()
                .any(|operand| matches!(operand, BytecodeOperand::BlockTarget { .. }))
        }));
    }
}

#[test]
fn compiles_calls_with_return_point_identity() {
    let source = "module P es\nfunc @callee() -> unit {\nb0() mass 0:\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  call @callee() @1:1-1:5\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return;
    };
    let compiled = compile_module(&module);
    assert!(compiled.is_ok());
    let Some(verified) = compiled.ok() else {
        return;
    };
    let caller = verified.module().functions.get(1);
    assert!(caller.is_some());
    if let Some(caller) = caller {
        assert_eq!(caller.return_points.len(), 1);
        if let Some(point) = caller.return_points.first() {
            assert_eq!(point.fast_program_counter, point.probed_program_counter);
        }
    }
}

#[test]
fn compiles_scalar_constants_as_immediate_operands() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 20\n  %1 = const.i64 22\n  %2 = int.add %0, %1 @1:1-1:2\n  out.write %2, newline @1:1-1:2\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return;
    };
    let compiled = compile_module(&module);
    assert!(compiled.is_ok(), "{compiled:?}");
    let Some(verified) = compiled.ok() else {
        return;
    };
    let Some(function) = verified.module().functions.first() else {
        return;
    };
    assert!(
        function
            .fast
            .instructions
            .iter()
            .all(|instruction| { instruction.opcode != pseudolearn_bytecode::Opcode::ConstI64 })
    );
    let addition = function
        .fast
        .instructions
        .iter()
        .find(|instruction| instruction.opcode == pseudolearn_bytecode::Opcode::IntAdd);
    assert!(addition.is_some());
    if let Some(addition) = addition {
        assert!(
            addition
                .operands
                .iter()
                .all(|operand| { matches!(operand, BytecodeOperand::Constant(_)) })
        );
    }
}

#[test]
fn selects_profiled_compare_branch_superinstructions_only_for_fast_code() {
    let parsed = parse_module(SIMPLE_IR);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return;
    };
    let compiled =
        compile_module_with_superinstructions(&module, &[SuperInstruction::CompareBranch]);
    assert!(compiled.is_ok(), "{compiled:?}");
    let Some(verified) = compiled.ok() else {
        return;
    };
    let Some(function) = verified.module().functions.first() else {
        return;
    };
    assert!(!function.fast.superinstructions.is_empty());
    assert!(function.probed.superinstructions.is_empty());
}

#[test]
fn selects_fused_arithmetic_superinstructions() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = const.i64 3\n  %2 = int.add %0, %1 @1:1-1:5\n  %3 = int.mul %2, %0 @1:6-1:10\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return;
    };
    let compiled =
        compile_module_with_superinstructions(&module, &[SuperInstruction::FusedArithmetic]);
    assert!(compiled.is_ok(), "{compiled:?}");
    let Some(verified) = compiled.ok() else {
        return;
    };
    let Some(function) = verified.module().functions.first() else {
        return;
    };
    assert!(!function.fast.superinstructions.is_empty());
    assert!(function.probed.superinstructions.is_empty());
}
