use super::*;

pub(super) fn collect_value_types(
    module: &Module,
    function: &Function,
) -> Result<BTreeMap<ValueId, IrType>, BytecodeError> {
    let mut value_types = BTreeMap::new();
    for (value, value_type) in &function.parameters {
        value_types.insert(*value, value_type.clone());
    }
    for block in &function.blocks {
        for (value, value_type) in &block.parameters {
            value_types.insert(*value, value_type.clone());
        }
        for identifier in &block.instructions {
            infer_instruction_type(module, function, *identifier, &mut value_types)?;
        }
    }
    Ok(value_types)
}

pub(super) fn infer_instruction_type(
    module: &Module,
    function: &Function,
    identifier: pseudolearn_ir::InstructionId,
    value_types: &mut BTreeMap<ValueId, IrType>,
) -> Result<(), BytecodeError> {
    let operation = function
        .columns
        .operation(identifier)
        .ok_or(BytecodeError::UnsupportedOperation)?;
    let operands = function.columns.operands(identifier);
    let inferred = pseudolearn_ir::type_checker::check_instruction_types(
        operation,
        operands,
        |value| value_types.get(&value).cloned(),
        module,
    )
    .map_err(|_| BytecodeError::InvalidIr("IR instruction type inference failed"))?;
    if let Some(result) = function.columns.result(identifier) {
        let value_type = inferred.ok_or(BytecodeError::MissingValue)?;
        value_types.insert(result, value_type);
    }
    Ok(())
}

pub(super) fn assign_registers(
    value_types: &BTreeMap<ValueId, IrType>,
    constant_plan: &ConstantPlan,
    origins: &[&pseudolearn_ir::OriginEntry],
) -> Result<RegisterAssignment, BytecodeError> {
    let mut registers = BTreeMap::new();
    let mut scalar_types = Vec::new();
    let mut reference_types = Vec::new();
    let mut variables = BTreeMap::new();
    for (value, value_type) in value_types {
        if compile_constants::can_elide(
            *value,
            &constant_plan.values,
            &constant_plan.register_values,
        ) {
            continue;
        }
        let variable = origins
            .iter()
            .find(|origin| origin.value == *value)
            .map(|origin| origin.variable);
        if let Some(register) = variable
            .and_then(|variable| variables.get(&variable))
            .copied()
        {
            registers.insert(*value, register);
            continue;
        }
        let destination = next_register(value_type, (&mut scalar_types, &mut reference_types))?;
        registers.insert(*value, destination);
        if let Some(variable) = variable {
            variables.insert(variable, destination);
        }
    }
    Ok(RegisterAssignment {
        by_value: registers,
        scalar_types,
        reference_types,
    })
}

pub(super) fn assign_register(
    class: RegisterClass,
    value_type: &IrType,
    register_types: &mut Vec<IrType>,
) -> Result<Register, BytecodeError> {
    let index = u16::try_from(register_types.len()).map_err(|_| BytecodeError::TooManyRegisters)?;
    register_types.push(value_type.clone());
    Ok(Register { class, index })
}

fn next_register(
    value_type: &IrType,
    (scalars, references): (&mut Vec<IrType>, &mut Vec<IrType>),
) -> Result<Register, BytecodeError> {
    if value_type.value_class() == ValueClass::Reference {
        assign_register(RegisterClass::Reference, value_type, references)
    } else {
        assign_register(RegisterClass::Scalar, value_type, scalars)
    }
}
