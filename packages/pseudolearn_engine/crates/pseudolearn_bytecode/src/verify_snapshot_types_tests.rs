use crate::{BytecodeFunction, BytecodeOperand, Constant, Instruction, Opcode, ValueType};

fn fixture() -> Result<(BytecodeFunction, Instruction), String> {
    let source = "module P en\nfunc @main() -> unit {\nb0() mass 0:\n %0 = const.str \"text\" @1:1-1:2\n %1 = cell.local str\n snapshot.copy 1, %0, %1 @1:1-1:2\n return\n}\n";
    let compiled = crate::compile_text(source).map_err(|error| format!("{error:?}"))?;
    let function = compiled
        .module()
        .functions
        .first()
        .cloned()
        .ok_or("Missing function")?;
    let instruction = function
        .fast
        .instructions
        .iter()
        .find(|instruction| instruction.opcode == Opcode::SnapshotCopy)
        .cloned()
        .ok_or("Missing snapshot instruction")?;
    Ok((function, instruction))
}

#[test]
fn verifies_snapshot_counts_and_rejects_overflow() -> Result<(), String> {
    let (mut function, mut instruction) = fixture()?;
    assert_eq!(
        super::verify_snapshot_types::verify(&function, &instruction),
        Ok(())
    );
    let Some(BytecodeOperand::Constant(index)) = instruction.operands.first() else {
        return Err("Missing count".to_owned());
    };
    let count = function
        .constants
        .get_mut(usize::from(*index))
        .ok_or("Missing constant")?;
    *count = Constant::I64(i64::MAX);
    assert!(super::verify_snapshot_types::verify(&function, &instruction).is_err());
    instruction.operands.clear();
    assert!(super::verify_snapshot_types::verify(&function, &instruction).is_err());
    Ok(())
}

#[test]
fn rejects_snapshot_destination_cells_of_another_type() -> Result<(), String> {
    let (mut function, instruction) = fixture()?;
    let Some(BytecodeOperand::Register(destination)) = instruction.operands.last() else {
        return Err("Missing destination".to_owned());
    };
    let kind = function
        .reference_types
        .get_mut(usize::from(destination.index))
        .ok_or("Missing register")?;
    *kind = ValueType::Cell(Box::new(ValueType::I64));
    assert!(super::verify_snapshot_types::verify(&function, &instruction).is_err());
    Ok(())
}
