#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeFunction, CodeVariant, Register, RegisterClass, ReturnPoint};

use crate::RuntimeValue;
use crate::frame::Frame;

#[test]
fn parallel_copy_preserves_register_cycles() {
    let function = BytecodeFunction {
        name: "cycle".to_owned(),
        parameters: Vec::new(),
        scalar_types: vec![
            pseudolearn_bytecode::ValueType::I64,
            pseudolearn_bytecode::ValueType::I64,
        ],
        reference_types: Vec::new(),
        constants: Vec::new(),
        fast: CodeVariant::default(),
        probed: CodeVariant::default(),
        return_points: Vec::<ReturnPoint>::new(),
    };
    let frame = Frame::new(0, &function, None, None);
    assert!(frame.is_ok());
    let Some(mut frame) = frame.ok() else {
        return;
    };
    let left = Register {
        class: RegisterClass::Scalar,
        index: 0,
    };
    let right = Register {
        class: RegisterClass::Scalar,
        index: 1,
    };
    assert!(frame.write(left, RuntimeValue::Scalar(17)).is_ok());
    assert!(frame.write(right, RuntimeValue::Scalar(29)).is_ok());
    assert!(frame.copy_parallel(&[left, right], &[right, left]).is_ok());
    assert_eq!(frame.read(left), Ok(RuntimeValue::Scalar(29)));
    assert_eq!(frame.read(right), Ok(RuntimeValue::Scalar(17)));
}

#[test]
fn rejects_register_reads_outside_the_allocated_bank() {
    let function = BytecodeFunction {
        name: "bank".to_owned(),
        parameters: Vec::new(),
        scalar_types: vec![pseudolearn_bytecode::ValueType::I64],
        reference_types: Vec::new(),
        constants: Vec::new(),
        fast: CodeVariant::default(),
        probed: CodeVariant::default(),
        return_points: Vec::<ReturnPoint>::new(),
    };
    let frame = Frame::new(0, &function, None, None);
    assert!(frame.is_ok());
    let Some(frame) = frame.ok() else {
        return;
    };
    let outside_register = Register {
        class: RegisterClass::Scalar,
        index: 2,
    };
    assert!(frame.read(outside_register).is_err());
}
