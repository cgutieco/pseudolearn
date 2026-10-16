use pseudolearn_bytecode::{
    BytecodeError, BytecodeModule, BytecodeOperand, Opcode, Register, RegisterClass,
    VerificationRule, compile_text, verify_bytecode,
};

fn module(source: &str) -> Result<BytecodeModule, BytecodeError> {
    Ok(compile_text(source)?.module().clone())
}

fn instruction_index(module: &BytecodeModule, opcode: Opcode) -> Result<usize, BytecodeError> {
    module
        .functions
        .first()
        .and_then(|function| {
            function
                .fast
                .instructions
                .iter()
                .position(|instruction| instruction.opcode == opcode)
        })
        .ok_or(BytecodeError::InvalidModule)
}

fn reference_register(index: u16) -> Register {
    Register {
        class: RegisterClass::Reference,
        index,
    }
}

fn destination_for_opcode(
    module: &BytecodeModule,
    opcode: Opcode,
) -> Result<Register, BytecodeError> {
    module
        .functions
        .first()
        .and_then(|function| {
            function
                .fast
                .instructions
                .iter()
                .find(|instruction| instruction.opcode == opcode)
                .and_then(|instruction| instruction.destination)
        })
        .ok_or(BytecodeError::InvalidModule)
}

fn set_destination_type(
    module: &mut BytecodeModule,
    opcode: Opcode,
    value_type: pseudolearn_bytecode::ValueType,
) -> Result<(), BytecodeError> {
    let register = destination_for_opcode(module, opcode)?;
    let function = module
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let types = match register.class {
        RegisterClass::Scalar => &mut function.scalar_types,
        RegisterClass::Reference => &mut function.reference_types,
    };
    let destination = types
        .get_mut(usize::from(register.index))
        .ok_or(BytecodeError::InvalidModule)?;
    *destination = value_type;
    function.probed = function.fast.clone();
    Ok(())
}

fn replace_register_operand(
    module: &mut BytecodeModule,
    opcode: Opcode,
    operand_index: usize,
    register: Register,
) -> Result<(), BytecodeError> {
    let position = instruction_index(module, opcode)?;
    let function = module
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let instruction = function
        .fast
        .instructions
        .get_mut(position)
        .ok_or(BytecodeError::InvalidModule)?;
    *instruction
        .operands
        .get_mut(operand_index)
        .ok_or(BytecodeError::InvalidModule)? = BytecodeOperand::Register(register);
    function.probed = function.fast.clone();
    Ok(())
}

#[test]
fn rejects_array_load_with_non_integer_index() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main(%0: array<i64, 1>) -> unit {\nb0() mass 0:\n  %1 = const.str \"x\"\n  %2 = text.concat %1, %1 @1:1-1:2\n  out.write %2 @1:1-1:2\n  %3 = const.i64 0\n  %4 = array.load %0, %3 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    let position = instruction_index(&candidate, Opcode::ArrayLoad)?;
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let invalid_index = function
        .fast
        .instructions
        .iter()
        .find(|instruction| instruction.opcode == Opcode::ConstStr)
        .and_then(|instruction| instruction.destination)
        .ok_or(BytecodeError::InvalidModule)?;
    let instruction = function
        .fast
        .instructions
        .get_mut(position)
        .ok_or(BytecodeError::InvalidModule)?;
    *instruction
        .operands
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)? = BytecodeOperand::Register(invalid_index);
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_array_creation_with_non_array_destination() -> Result<(), BytecodeError> {
    let source = "module P es\nclass C {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = array.new i64, %0 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::ArrayNew,
        pseudolearn_bytecode::ValueType::Str,
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_array_store_with_incompatible_element_type() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = array.new i64, %0 @1:1-1:2\n  %2 = const.i64 0\n  array.store %1, %2, %2 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    let invalid_value = destination_for_opcode(&candidate, Opcode::ArrayNew)?;
    replace_register_operand(&mut candidate, Opcode::ArrayStore, 2, invalid_value)?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_array_cell_with_incompatible_element_type() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main(%0: array<i64, 1>) -> unit {\nb0() mass 0:\n  %1 = const.i64 0\n  %2 = cell.element %0, %1 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::CellElement,
        pseudolearn_bytecode::ValueType::Cell(Box::new(pseudolearn_bytecode::ValueType::Str)),
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_field_cell_with_incompatible_field_type() -> Result<(), BytecodeError> {
    let source = "module P es\nclass C { value: i64 }\nfunc @main(%0: obj<C>) -> unit {\nb0() mass 0:\n  %1 = cell.field %0, value\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::CellField,
        pseudolearn_bytecode::ValueType::Cell(Box::new(pseudolearn_bytecode::ValueType::Str)),
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_local_cell_with_incompatible_value_type() -> Result<(), BytecodeError> {
    let source =
        "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local i64\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::CellLocal,
        pseudolearn_bytecode::ValueType::Cell(Box::new(pseudolearn_bytecode::ValueType::Str)),
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_cell_store_with_incompatible_value_type() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local i64\n  %1 = const.i64 2\n  %2 = const.str \"x\"\n  cell.store %0, %1\n  return\n}\n";
    let mut candidate = module(source)?;
    let position = instruction_index(&candidate, Opcode::CellStore)?;
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let instruction = function
        .fast
        .instructions
        .get_mut(position)
        .ok_or(BytecodeError::InvalidModule)?;
    *instruction
        .operands
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)? = BytecodeOperand::Register(reference_register(0));
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn accepts_subtype_at_block_edge_and_rejects_unrelated_type() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nclass Other {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new Derived @1:1-1:2\n  jump b1(%0)\nb1(%1: obj<Base>) mass 0:\n  return\n}\n";
    let mut candidate = module(source)?;
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let actual = function
        .reference_types
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    *actual = pseudolearn_bytecode::ValueType::Object("Other".to_owned());
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_cell_load_with_wrong_destination_type() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local i64\n  %1 = cell.load %0 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    let position = instruction_index(&candidate, Opcode::CellLoad)?;
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let instruction = function
        .fast
        .instructions
        .get_mut(position)
        .ok_or(BytecodeError::InvalidModule)?;
    instruction.destination = Some(reference_register(0));
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_object_creation_with_incompatible_destination_type() -> Result<(), BytecodeError> {
    let source = "module P es\nclass C {}\nclass D {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::ObjectNew,
        pseudolearn_bytecode::ValueType::Object("D".to_owned()),
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_object_copy_with_different_destination_type() -> Result<(), BytecodeError> {
    let source = "module P es\nclass C {}\nclass D {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @1:1-1:2\n  %1 = object.copy %0 @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::ObjectCopy,
        pseudolearn_bytecode::ValueType::Object("D".to_owned()),
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_reference_comparison_with_scalar_operand() -> Result<(), BytecodeError> {
    let source = "module P es\nclass C {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @1:1-1:2\n  %1 = const.i64 0\n  %2 = ref.cmp eq, %0, %0\n  return\n}\n";
    let mut candidate = module(source)?;
    let scalar = Register {
        class: RegisterClass::Scalar,
        index: 0,
    };
    replace_register_operand(&mut candidate, Opcode::RefCmp, 2, scalar)?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn rejects_random_instruction_with_non_real_destination() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = host.random @1:1-1:2\n  return\n}\n";
    let mut candidate = module(source)?;
    set_destination_type(
        &mut candidate,
        Opcode::HostRandom,
        pseudolearn_bytecode::ValueType::I64,
    )?;
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn accepts_subtype_stores_through_base_typed_cells() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nclass Other {}\nfunc @main(%0: cell<obj<Base>>) -> unit {\nb0() mass 0:\n  %1 = object.new Derived @1:1-1:2\n  cell.store %0, %1\n  return\n}\n";
    let mut candidate = module(source)?;
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let actual = function
        .reference_types
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)?;
    *actual = pseudolearn_bytecode::ValueType::Object("Other".to_owned());
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}

#[test]
fn accepts_related_types_at_control_flow_joins() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nclass First : Base {}\nclass Second : Base {}\nclass Other {}\nfunc @main(%0: bool) -> unit {\nb0() mass 0:\n  %1 = object.new First @1:1-1:2\n  %2 = object.new Second @1:1-1:2\n  branch %0, b1(%1), b1(%2)\nb1(%3: obj<Base>) mass 0:\n  return\n}\n";
    let mut candidate = module(source)?;
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let first_edge_value = function
        .reference_types
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    *first_edge_value = pseudolearn_bytecode::ValueType::Object("Other".to_owned());
    function.probed = function.fast.clone();
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::Verification(VerificationRule::ValueClass))
    );
    Ok(())
}
