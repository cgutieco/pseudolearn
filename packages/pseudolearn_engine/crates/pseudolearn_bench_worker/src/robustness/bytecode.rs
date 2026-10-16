use super::campaigns::{Outcome, finding};
use super::mutation::Generator;
use super::sources::Source;
use pseudolearn_bytecode::{BytecodeModule, BytecodeOperand, Register, verify_bytecode};

pub fn bytecode_case(source: &Source, generator: &mut Generator) -> Outcome {
    let Ok(module) =
        pseudolearn_api::compile_source_to_module(&source.program, &source.profile, "strict")
    else {
        return Outcome::NotApplicable;
    };
    let Ok(verified) = pseudolearn_bytecode::compile_module(&module) else {
        return Outcome::NotApplicable;
    };
    let mut corrupted: BytecodeModule = verified.module().clone();
    let kind = generator.below(5);
    if !corrupt(&mut corrupted, kind, generator) {
        return Outcome::NotApplicable;
    }
    match verify_bytecode(&corrupted) {
        Err(_) => Outcome::Rejected,
        Ok(()) => Outcome::Finding(finding(
            "corrupted_bytecode_accepted",
            u64::try_from(kind).unwrap_or(0),
            &format!("corruption {kind} of {}", source.program),
        )),
    }
}

fn corrupt(module: &mut BytecodeModule, kind: usize, generator: &mut Generator) -> bool {
    let function_count = module.functions.len();
    let position = generator.below(function_count);
    let Some(function) = module.functions.get_mut(position) else {
        return false;
    };
    let count = function.fast.instructions.len();
    let Some(instruction) = function.fast.instructions.get_mut(generator.below(count)) else {
        return false;
    };
    let invalid = u16::MAX;
    match kind {
        0 => match instruction.destination.as_mut() {
            Some(register) => poison(register, invalid),
            None => return false,
        },
        1 => return corrupt_operand(&mut instruction.operands, invalid, 0),
        2 => return corrupt_operand(&mut instruction.operands, invalid, 1),
        3 => return corrupt_operand(&mut instruction.operands, invalid, 2),
        _ => return truncate_used_region(function),
    }
    true
}

fn truncate_used_region(function: &mut pseudolearn_bytecode::BytecodeFunction) -> bool {
    let used = function.fast.used_length;
    if used < 2 {
        return false;
    }
    function.fast.used_length = used.saturating_sub(1);
    true
}

fn poison(register: &mut Register, invalid: u16) {
    register.index = invalid;
}

fn corrupt_operand(operands: &mut [BytecodeOperand], invalid: u16, variant: usize) -> bool {
    for operand in operands.iter_mut() {
        match (variant, operand) {
            (0, BytecodeOperand::Register(register)) => {
                poison(register, invalid);
                return true;
            }
            (1, BytecodeOperand::Constant(index)) => {
                *index = invalid;
                return true;
            }
            (2, BytecodeOperand::FunctionTarget { function_index, .. }) => {
                *function_index = invalid;
                return true;
            }
            _ => {}
        }
    }
    false
}
