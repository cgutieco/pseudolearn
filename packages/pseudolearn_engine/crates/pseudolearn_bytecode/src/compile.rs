#![forbid(unsafe_code)]

use std::collections::{BTreeMap, BTreeSet};

mod compile_constants;
mod compile_instructions;
mod compile_operands;

use pseudolearn_ir::identities::InstructionId;
use pseudolearn_ir::{Function, IrType, Module, ValueClass, ValueId, verify_module};

use crate::error::BytecodeError;
use crate::model::{
    BytecodeFunction, BytecodeModule, CodeVariant, Constant, Register, RegisterClass,
    SuperInstruction, VerifiedBytecode,
};
use crate::verify_bytecode;
use compile_constants::ConstantPlan;

struct FunctionPlan<'module> {
    source: &'module Function,
    function_index: u16,
    function_names: &'module BTreeMap<String, u16>,
    registers: BTreeMap<ValueId, Register>,
    constants_by_value: BTreeMap<ValueId, Constant>,
    register_values: BTreeSet<ValueId>,
    constants: Vec<Constant>,
    return_point_ids: BTreeMap<InstructionId, u32>,
    fast_return_points: BTreeMap<u32, (u32, u32)>,
    probed_return_points: BTreeMap<u32, (u32, u32)>,
}

struct InstructionPlan<'plan, 'module> {
    function_names: &'module BTreeMap<String, u16>,
    registers: &'plan BTreeMap<ValueId, Register>,
    constants_by_value: &'plan BTreeMap<ValueId, Constant>,
    constants: &'plan mut Vec<Constant>,
    allow_immediate: bool,
}

struct RegisterAssignment {
    by_value: BTreeMap<ValueId, Register>,
    scalar_types: Vec<IrType>,
    reference_types: Vec<IrType>,
}

struct CompileOptions<'module> {
    function_names: &'module BTreeMap<String, u16>,
    superinstructions: &'module [SuperInstruction],
}

pub fn compile_module(module: &Module) -> Result<VerifiedBytecode, BytecodeError> {
    compile_module_with_superinstructions(module, &[])
}

pub fn compile_module_with_superinstructions(
    module: &Module,
    selected: &[SuperInstruction],
) -> Result<VerifiedBytecode, BytecodeError> {
    verify_module(module).map_err(BytecodeError::InvalidIr)?;
    let function_names = function_names(module)?;
    let options = CompileOptions {
        function_names: &function_names,
        superinstructions: selected,
    };
    let functions = compile_functions(module, &options)?;
    let bytecode = BytecodeModule {
        name: module.name.clone(),
        functions,
    };
    verify_bytecode(&bytecode)?;
    Ok(VerifiedBytecode::new(bytecode))
}

pub fn compile_text(source_text: &str) -> Result<VerifiedBytecode, BytecodeError> {
    compile_text_with_superinstructions(source_text, &[])
}

pub fn compile_text_with_superinstructions(
    source_text: &str,
    selected: &[SuperInstruction],
) -> Result<VerifiedBytecode, BytecodeError> {
    let module = pseudolearn_ir::parse_module(source_text).map_err(BytecodeError::InvalidText)?;
    compile_module_with_superinstructions(&module, selected)
}

fn function_names(module: &Module) -> Result<BTreeMap<String, u16>, BytecodeError> {
    let mut names = BTreeMap::new();
    for (index, function) in module.functions.iter().enumerate() {
        let function_index = u16::try_from(index).map_err(|_| BytecodeError::MissingFunction)?;
        names.insert(function.name.clone(), function_index);
        names.insert(
            function.name.trim_start_matches('@').to_owned(),
            function_index,
        );
    }
    Ok(names)
}

fn compile_functions(
    module: &Module,
    options: &CompileOptions<'_>,
) -> Result<Vec<BytecodeFunction>, BytecodeError> {
    let mut output = Vec::with_capacity(module.functions.len());
    for (index, source) in module.functions.iter().enumerate() {
        let function_index = u16::try_from(index).map_err(|_| BytecodeError::MissingFunction)?;
        output.push(compile_function(module, source, function_index, options)?);
    }
    Ok(output)
}

fn compile_function(
    module: &Module,
    source: &Function,
    function_index: u16,
    options: &CompileOptions<'_>,
) -> Result<BytecodeFunction, BytecodeError> {
    let value_types = collect_value_types(module, source)?;
    let constant_plan = compile_constants::analyze(source);
    let assignment = assign_registers(&value_types, &constant_plan)?;
    let mut plan = FunctionPlan {
        source,
        function_index,
        function_names: options.function_names,
        registers: assignment.by_value,
        constants_by_value: constant_plan.values,
        register_values: constant_plan.register_values,
        constants: Vec::new(),
        return_point_ids: compile_instructions::return_point_ids(source)?,
        fast_return_points: BTreeMap::new(),
        probed_return_points: BTreeMap::new(),
    };
    let fast = compile_variant(&mut plan, true, options.superinstructions)?;
    let probed = compile_variant(&mut plan, false, &[])?;
    let return_points = compile_instructions::return_points(&plan)?;
    Ok(BytecodeFunction {
        name: source.name.clone(),
        parameters: source
            .parameters
            .iter()
            .map(|(value, _)| register_for(&plan.registers, *value))
            .collect::<Result<Vec<_>, _>>()?,
        scalar_types: assignment.scalar_types,
        reference_types: assignment.reference_types,
        constants: plan.constants,
        fast,
        probed,
        return_points,
    })
}

fn collect_value_types(
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

fn infer_instruction_type(
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

fn assign_registers(
    value_types: &BTreeMap<ValueId, IrType>,
    constant_plan: &ConstantPlan,
) -> Result<RegisterAssignment, BytecodeError> {
    let mut registers = BTreeMap::new();
    let mut scalar_types = Vec::new();
    let mut reference_types = Vec::new();
    for (value, value_type) in value_types {
        if compile_constants::can_elide(
            *value,
            &constant_plan.values,
            &constant_plan.register_values,
        ) {
            continue;
        }
        let destination = if value_type.value_class() == ValueClass::Reference {
            assign_register(RegisterClass::Reference, value_type, &mut reference_types)?
        } else {
            assign_register(RegisterClass::Scalar, value_type, &mut scalar_types)?
        };
        registers.insert(*value, destination);
    }
    Ok(RegisterAssignment {
        by_value: registers,
        scalar_types,
        reference_types,
    })
}

fn assign_register(
    class: RegisterClass,
    value_type: &IrType,
    register_types: &mut Vec<IrType>,
) -> Result<Register, BytecodeError> {
    let index = u16::try_from(register_types.len()).map_err(|_| BytecodeError::TooManyRegisters)?;
    register_types.push(value_type.clone());
    Ok(Register { class, index })
}

fn compile_variant(
    plan: &mut FunctionPlan<'_>,
    fast: bool,
    selected: &[SuperInstruction],
) -> Result<CodeVariant, BytecodeError> {
    let mut variant = CodeVariant::default();
    for block in &plan.source.blocks {
        compile_instructions::append_block(plan, block, &mut variant, fast)?;
    }
    if fast && selected.contains(&SuperInstruction::CompareBranch) {
        compile_instructions::select_compare_branches(&mut variant)?;
    }
    Ok(variant)
}

pub(super) fn register_for(
    registers: &BTreeMap<ValueId, Register>,
    value: ValueId,
) -> Result<Register, BytecodeError> {
    registers
        .get(&value)
        .copied()
        .ok_or(BytecodeError::MissingValue)
}
