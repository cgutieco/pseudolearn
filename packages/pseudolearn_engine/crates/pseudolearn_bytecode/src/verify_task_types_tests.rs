use crate::{
    BytecodeFunction, BytecodeOperand, Instruction, Opcode, Register, RegisterClass, ValueType,
};

fn function() -> Result<BytecodeFunction, String> {
    let module = pseudolearn_ir::parse_module(
        "module P en\nfunc @main() -> i64 {\nb0() mass 0:\n%0 = const.i64 1\nreturn %0\n}\n",
    )
    .map_err(|error| format!("{error:?}"))?;
    let compiled = crate::compile_module(&module).map_err(|error| format!("{error:?}"))?;
    compiled
        .module()
        .functions
        .first()
        .cloned()
        .ok_or_else(|| "missing function".to_owned())
}

fn instruction(command: &str) -> Instruction {
    let register = Register {
        class: RegisterClass::Scalar,
        index: 0,
    };
    Instruction {
        opcode: Opcode::TaskChannel,
        destination: Some(register),
        operands: vec![
            BytecodeOperand::Identifier(command.to_owned()),
            BytecodeOperand::Type(ValueType::I64),
            BytecodeOperand::Register(register),
            BytecodeOperand::Register(register),
        ],
        span: None,
        return_point: None,
    }
}

#[test]
fn validates_task_operands_using_the_ir_type_contract() -> Result<(), String> {
    assert_eq!(
        super::verify_task_types::verify(&function()?, &instruction("new")),
        Ok(true)
    );
    assert!(super::verify_task_types::verify(&function()?, &instruction("unknown")).is_err());
    Ok(())
}

#[test]
fn rejects_task_result_class_mismatches_and_missing_operands() -> Result<(), String> {
    let function = function()?;
    let mut invalid = instruction("new");
    invalid.destination = Some(Register {
        class: RegisterClass::Reference,
        index: 0,
    });
    assert!(super::verify_task_types::verify(&function, &invalid).is_err());
    invalid = instruction("new");
    invalid.operands.pop();
    assert!(super::verify_task_types::verify(&function, &invalid).is_err());
    Ok(())
}
