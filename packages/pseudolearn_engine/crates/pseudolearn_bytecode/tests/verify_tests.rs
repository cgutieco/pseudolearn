use pseudolearn_bytecode::{
    BytecodeError, BytecodeOperand, Opcode, Register, RegisterClass, ValueType, VerificationRule,
    compile_module, verify_bytecode,
};
use pseudolearn_ir::{BlockId, parse_module};

const SCALAR_IR: &str = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  jump b1(%0)\nb1(%1: i64) mass 0:\n  return\n}\n";

fn compiled_scalar() -> pseudolearn_bytecode::BytecodeModule {
    let parsed = parse_module(SCALAR_IR);
    assert!(parsed.is_ok());
    let Some(module) = parsed.ok() else {
        return panic_free_fallback();
    };
    let compiled = compile_module(&module);
    assert!(compiled.is_ok());
    compiled
        .ok()
        .map(|verified| verified.module().clone())
        .unwrap_or_else(panic_free_fallback)
}

fn panic_free_fallback() -> pseudolearn_bytecode::BytecodeModule {
    pseudolearn_bytecode::BytecodeModule {
        name: String::new(),
        vocabulary: String::new(),
        profiles: Vec::new(),
        classes: Vec::new(),
        functions: Vec::new(),
    }
}

#[test]
fn rejects_register_outside_window() {
    let mut module = compiled_scalar();
    let candidate = module.functions.first_mut();
    assert!(candidate.is_some());
    let Some(function) = candidate else {
        return;
    };
    let candidate = function.fast.instructions.first_mut();
    assert!(candidate.is_some());
    let Some(instruction) = candidate else {
        return;
    };
    let candidate = instruction.operands.first_mut();
    assert!(candidate.is_some());
    let Some(operand) = candidate else {
        return;
    };
    *operand = BytecodeOperand::Register(Register {
        class: RegisterClass::Scalar,
        index: u16::MAX,
    });
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&module),
        Err(BytecodeError::Verification(VerificationRule::OperandWindow))
    );
}

#[test]
fn rejects_jump_to_block_outside_function() {
    let mut module = compiled_scalar();
    let candidate = module.functions.first_mut();
    assert!(candidate.is_some());
    let Some(function) = candidate else {
        return;
    };
    let candidate = function.fast.instructions.get_mut(1);
    assert!(candidate.is_some());
    let Some(instruction) = candidate else {
        return;
    };
    let candidate = instruction.operands.first_mut();
    assert!(candidate.is_some());
    let Some(operand) = candidate else {
        return;
    };
    *operand = BytecodeOperand::BlockTarget {
        target: BlockId(u32::MAX),
        arguments: Vec::new(),
    };
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&module),
        Err(BytecodeError::Verification(VerificationRule::FunctionJump))
    );
}

#[test]
fn rejects_incompatible_block_argument_class() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = const.i64 1\n  %2 = int.add %1, %1 @1:1-1:2\n  jump b1(%0)\nb1(%3: str) mass 0:\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    let candidate = parsed.as_ref().ok().cloned();
    assert!(candidate.is_some());
    let Some(ir_module) = candidate else {
        return;
    };
    let compiled = compile_module(&ir_module);
    assert!(compiled.is_ok());
    let candidate = compiled.as_ref().ok().cloned();
    assert!(candidate.is_some());
    let Some(verified) = candidate else {
        return;
    };
    let mut module = verified.module().clone();
    let candidate = module.functions.first_mut();
    assert!(candidate.is_some());
    let Some(function) = candidate else {
        return;
    };
    let candidate = function.fast.instructions.get_mut(2);
    assert!(candidate.is_some());
    let Some(instruction) = candidate else {
        return;
    };
    let candidate = instruction.operands.first_mut();
    assert!(candidate.is_some());
    if let Some(BytecodeOperand::BlockTarget { arguments, .. }) = candidate {
        let source = arguments.first_mut();
        assert!(source.is_some());
        if let Some(source) = source {
            *source = Register {
                class: RegisterClass::Scalar,
                index: 0,
            };
        }
    }
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&module),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
}

#[test]
fn accepts_subclass_values_in_base_type_arrays() {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = array.new array<obj<Base>, 1>, %0 @1:1-1:2\n  %2 = object.new Derived @1:1-1:2\n  %3 = const.i64 0\n  array.store %1, %3, %2 @1:1-1:2\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert!(compile_module(&module).is_ok());
    }
}

#[test]
fn rejects_unrelated_values_in_base_type_arrays() {
    let source = "module P es\nclass Base {}\nclass Other {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = array.new array<obj<Other>, 1>, %0 @1:1-1:2\n  %2 = object.new Other @1:1-1:2\n  %3 = const.i64 0\n  array.store %1, %3, %2 @1:1-1:2\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        let compiled = compile_module(&module);
        assert!(compiled.is_ok());
        let candidate = compiled.ok().map(|verified| verified.module().clone());
        assert!(candidate.is_some());
        let Some(mut compiled_module) = candidate else {
            return;
        };
        let function = compiled_module.functions.first_mut();
        assert!(function.is_some());
        let Some(function) = function else {
            return;
        };
        let instruction = function
            .fast
            .instructions
            .iter_mut()
            .find(|instruction| instruction.opcode == Opcode::ArrayNew);
        assert!(instruction.is_some());
        let Some(instruction) = instruction else {
            return;
        };
        let destination = instruction.destination;
        let array_type = ValueType::Array {
            element: Box::new(ValueType::Object("Base".to_owned())),
            dimension_rank: 1,
        };
        let operand = instruction.operands.first_mut();
        assert!(operand.is_some());
        if let Some(BytecodeOperand::Type(value_type)) = operand {
            *value_type = array_type.clone();
        }
        let Some(destination) = destination else {
            return;
        };
        let register_type = function
            .reference_types
            .get_mut(usize::from(destination.index));
        assert!(register_type.is_some());
        if let Some(register_type) = register_type {
            *register_type = array_type;
        }
        function.probed = function.fast.clone();
        assert_eq!(
            verify_bytecode(&compiled_module),
            Err(BytecodeError::Verification(VerificationRule::ValueClass))
        );
    }
}

#[test]
fn rejects_call_without_return_point() {
    let source = "module P es\nfunc @callee() -> unit {\nb0() mass 0:\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  call @callee() @1:1-1:5\n  return\n}\n";
    let parsed = parse_module(source);
    assert!(parsed.is_ok());
    let candidate = parsed.as_ref().ok().cloned();
    assert!(candidate.is_some());
    let Some(ir_module) = candidate else {
        return;
    };
    let compiled = compile_module(&ir_module);
    assert!(compiled.is_ok());
    let candidate = compiled.as_ref().ok().cloned();
    assert!(candidate.is_some());
    let Some(verified) = candidate else {
        return;
    };
    let mut module = verified.module().clone();
    let candidate = module.functions.get_mut(1);
    assert!(candidate.is_some());
    let Some(caller) = candidate else {
        return;
    };
    let candidate = caller.fast.instructions.first_mut();
    assert!(candidate.is_some());
    if let Some(instruction) = candidate {
        instruction.return_point = None;
    }
    caller.probed = caller.fast.clone();
    assert_eq!(
        verify_bytecode(&module),
        Err(BytecodeError::Verification(VerificationRule::ReturnPoint))
    );
}

#[test]
fn rejects_superinstruction_with_an_incompatible_opcode_pair() {
    let mut module = compiled_scalar();
    let Some(function) = module.functions.first_mut() else {
        return;
    };
    function.fast.superinstructions.insert(0, 1);
    assert_eq!(
        verify_bytecode(&module),
        Err(BytecodeError::Verification(
            VerificationRule::SuperInstruction
        ))
    );
}
