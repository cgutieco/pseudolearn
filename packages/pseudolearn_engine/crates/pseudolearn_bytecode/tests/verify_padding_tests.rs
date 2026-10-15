use pseudolearn_bytecode::{
    BytecodeError, BytecodeFunction, BytecodeModule, Instruction, Opcode, VerificationRule,
    compile_module, verify_bytecode,
};
use pseudolearn_ir::parse_module;

const BRANCHING_IR: &str = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  jump b1(%0)\nb1(%1: i64) mass 0:\n  return\n}\n";

const PADDING_ERROR: Result<(), BytecodeError> =
    Err(BytecodeError::Verification(VerificationRule::Padding));

fn compiled() -> Option<BytecodeModule> {
    let module = parse_module(BRANCHING_IR).ok()?;
    compile_module(&module)
        .ok()
        .map(|verified| verified.module().clone())
}

fn mutate(change: impl Fn(&mut BytecodeFunction)) -> Result<(), BytecodeError> {
    let mut module = compiled().ok_or(BytecodeError::InvalidModule)?;
    let function = module
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    change(function);
    function.probed = function.fast.clone();
    verify_bytecode(&module)
}

fn extra_instruction() -> Instruction {
    Instruction {
        opcode: Opcode::Unreachable,
        destination: None,
        operands: Vec::new(),
        span: None,
        return_point: None,
    }
}

#[test]
fn compiled_variants_are_padded_to_a_power_of_two() {
    let module = compiled();
    assert!(module.is_some());
    let Some(module) = module else {
        return;
    };
    for function in &module.functions {
        for variant in [&function.fast, &function.probed] {
            assert!(variant.instructions.len().is_power_of_two());
            let used = usize::try_from(variant.used_length).unwrap_or(usize::MAX);
            assert!(used <= variant.instructions.len());
            let tail = variant.instructions.get(used..).unwrap_or_default();
            assert!(tail.iter().all(|entry| entry.opcode == Opcode::Unreachable));
        }
    }
}

#[test]
fn unpadded_function_keeps_the_original_verification() {
    assert_eq!(mutate(|_| {}), Ok(()));
}

#[test]
fn rejects_length_that_is_not_a_power_of_two() {
    let result = mutate(|function| {
        let length = function.fast.instructions.len();
        function.fast.instructions.push(extra_instruction());
        if length == 1 {
            function.fast.instructions.push(extra_instruction());
        }
    });
    assert_eq!(result, PADDING_ERROR);
}

#[test]
fn rejects_tail_instruction_other_than_unreachable() {
    let result = mutate(|function| {
        let doubled = function.fast.instructions.len().saturating_mul(2);
        function
            .fast
            .instructions
            .resize(doubled, extra_instruction());
        if let Some(last) = function.fast.instructions.last_mut() {
            last.opcode = Opcode::Return;
        }
    });
    assert_eq!(result, PADDING_ERROR);
}

#[test]
fn rejects_empty_used_length() {
    let result = mutate(|function| function.fast.used_length = 0);
    assert_eq!(result, PADDING_ERROR);
}

#[test]
fn rejects_used_length_beyond_the_code() {
    let result = mutate(|function| function.fast.used_length = u32::MAX);
    assert_eq!(result, PADDING_ERROR);
}

#[test]
fn rejects_block_that_starts_in_the_padding() {
    let result = mutate(|function| {
        let doubled = function.fast.instructions.len().saturating_mul(2);
        function
            .fast
            .instructions
            .resize(doubled, extra_instruction());
        let tail_start = u32::try_from(doubled.saturating_sub(1)).unwrap_or(u32::MAX);
        if let Some(block) = function.fast.blocks.last_mut() {
            block.start_pc = tail_start;
        }
    });
    assert_eq!(
        result,
        Err(BytecodeError::Verification(VerificationRule::FunctionJump))
    );
}
