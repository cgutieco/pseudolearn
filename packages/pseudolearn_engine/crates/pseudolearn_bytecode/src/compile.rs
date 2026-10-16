#![forbid(unsafe_code)]

use std::collections::{BTreeMap, BTreeSet};

mod compile_constants;
mod compile_instructions;
mod compile_operands;
mod compile_padding;
mod compile_superinstructions;
mod registers;
use registers::{assign_registers, collect_value_types};

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
    compile_module_with_superinstructions(module, &[SuperInstruction::CompareBranch])
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
        vocabulary: module.vocabulary.clone(),
        classes: crate::classes::compile(module, &function_names)?,
        functions,
    };
    verify_bytecode(&bytecode)?;
    Ok(VerifiedBytecode::new(bytecode))
}

pub fn compile_text(source_text: &str) -> Result<VerifiedBytecode, BytecodeError> {
    let module = pseudolearn_ir::parse_module(source_text).map_err(BytecodeError::InvalidText)?;
    compile_module(&module)
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
    let mut constant_plan = compile_constants::analyze(source);
    let origins = module
        .origins
        .entries
        .iter()
        .filter(|origin| origin.function == source.name)
        .collect::<Vec<_>>();
    constant_plan
        .register_values
        .extend(origins.iter().map(|origin| origin.value));
    let assignment = assign_registers(&value_types, &constant_plan, &origins)?;
    let (origin_registers, names) = source_names(&origins, &assignment);
    let mut plan = FunctionPlan {
        source,
        function_index,
        function_names: options.function_names,
        registers: assignment.by_value.clone(),
        constants_by_value: constant_plan.values,
        register_values: constant_plan.register_values,
        constants: Vec::new(),
        return_point_ids: compile_instructions::return_point_ids(source)?,
        fast_return_points: BTreeMap::new(),
        probed_return_points: BTreeMap::new(),
    };
    let (fast, probed) = compile_twins(&mut plan, options.superinstructions, &origin_registers)?;
    let return_points = compile_instructions::return_points(&plan)?;
    finish_function(
        source,
        (assignment, names),
        (fast, probed),
        (plan, return_points),
    )
}

fn finish_function(
    source: &Function,
    (assignment, names): (RegisterAssignment, BTreeMap<Register, String>),
    (fast, probed): (CodeVariant, CodeVariant),
    (plan, return_points): (FunctionPlan<'_>, Vec<crate::ReturnPoint>),
) -> Result<BytecodeFunction, BytecodeError> {
    Ok(BytecodeFunction {
        declaration_span: source.declaration_span,
        names,
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
        compile_superinstructions::select_compare_branches(&mut variant)?;
    }
    if fast && selected.contains(&SuperInstruction::FusedArithmetic) {
        compile_superinstructions::select_arithmetic_superinstructions(&mut variant)?;
    }
    compile_padding::pad_variant(&mut variant)?;
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

fn source_names(
    origins: &[&pseudolearn_ir::OriginEntry],
    assignment: &RegisterAssignment,
) -> (Vec<Register>, BTreeMap<Register, String>) {
    let registers = origins
        .iter()
        .filter_map(|origin| assignment.by_value.get(&origin.value).copied())
        .collect();
    let names = origins
        .iter()
        .filter_map(|origin| {
            assignment
                .by_value
                .get(&origin.value)
                .map(|register| (*register, origin.name.clone()))
        })
        .collect();
    (registers, names)
}

fn compile_twins(
    plan: &mut FunctionPlan<'_>,
    selected: &[SuperInstruction],
    origins: &[Register],
) -> Result<(CodeVariant, CodeVariant), BytecodeError> {
    let mut fast = compile_variant(plan, true, selected)?;
    let mut probed = compile_variant(plan, false, &[])?;
    crate::roots::generate(&mut fast, origins)?;
    crate::roots::generate(&mut probed, origins)?;
    Ok((fast, probed))
}
