#![forbid(unsafe_code)]

use crate::builder::{FunctionBuilder, is_current_block_terminated};
use crate::types::lower_type;
use pseudolearn_ir::{BlockId, Operand, Operation, OriginEntry, ValueId, VariableId};
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::LocalId;
use std::collections::{HashMap, HashSet};

#[derive(Clone, Default)]
pub struct VariableEnvironment {
    pub values: HashMap<LocalId, ValueId>,
    pub cells: HashMap<LocalId, ValueId>,
    pub assigned: HashSet<LocalId>,
}

impl VariableEnvironment {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn bind_value(&mut self, local_id: LocalId, value: ValueId) {
        self.values.insert(local_id, value);
    }

    pub fn bind_cell(&mut self, local_id: LocalId, cell: ValueId) {
        self.cells.insert(local_id, cell);
    }

    pub fn mark_assigned(&mut self, local_id: LocalId) {
        self.assigned.insert(local_id);
    }

    pub fn is_assigned(&self, local_id: LocalId) -> bool {
        self.assigned.contains(&local_id)
    }

    pub fn get_value(&self, local_id: LocalId) -> Option<ValueId> {
        self.values.get(&local_id).copied()
    }

    pub fn get_cell(&self, local_id: LocalId) -> Option<ValueId> {
        self.cells.get(&local_id).copied()
    }
}

pub struct BranchMergeInputs<'context> {
    pub then_environment: &'context VariableEnvironment,
    pub else_environment: &'context VariableEnvironment,
    pub join_block: BlockId,
    pub then_block: BlockId,
    pub else_block: BlockId,
}

struct MergeJumpArguments {
    pub then_arguments: Vec<ValueId>,
    pub else_arguments: Vec<ValueId>,
}

struct MergeContext<'merge_lifetime> {
    pub join_environment: VariableEnvironment,
    pub jump_arguments: MergeJumpArguments,
    pub join_block: BlockId,
    pub origins: &'merge_lifetime mut Vec<OriginEntry>,
    pub module: &'merge_lifetime HirModule,
}

pub fn merge_branch_environments(
    inputs: BranchMergeInputs<'_>,
    builder: &mut FunctionBuilder,
    origins: &mut Vec<OriginEntry>,
    module: &HirModule,
) -> VariableEnvironment {
    let mut context = MergeContext {
        join_environment: VariableEnvironment::new(),
        jump_arguments: MergeJumpArguments {
            then_arguments: Vec::new(),
            else_arguments: Vec::new(),
        },
        join_block: inputs.join_block,
        origins,
        module,
    };

    let sorted_locals = collect_sorted_locals(&inputs);
    for local_id in sorted_locals {
        merge_single_local_value(local_id, &inputs, &mut context, builder);
    }

    for (local_id, &cell_value) in &inputs.then_environment.cells {
        context.join_environment.bind_cell(*local_id, cell_value);
    }

    emit_branch_jumps(builder, &inputs, context.jump_arguments);
    context.join_environment
}

fn collect_sorted_locals(inputs: &BranchMergeInputs<'_>) -> Vec<LocalId> {
    let mut sorted_locals: Vec<LocalId> = inputs
        .then_environment
        .values
        .keys()
        .chain(inputs.else_environment.values.keys())
        .copied()
        .collect::<HashSet<_>>()
        .into_iter()
        .collect();
    sorted_locals.sort_by_key(|local_id| local_id.0);
    sorted_locals
}

fn emit_branch_jumps(
    builder: &mut FunctionBuilder,
    inputs: &BranchMergeInputs<'_>,
    arguments: MergeJumpArguments,
) {
    emit_join_jump(
        builder,
        inputs.then_block,
        inputs.join_block,
        arguments.then_arguments,
    );
    emit_join_jump(
        builder,
        inputs.else_block,
        inputs.join_block,
        arguments.else_arguments,
    );
}

fn merge_single_local_value(
    local_id: LocalId,
    inputs: &BranchMergeInputs<'_>,
    context: &mut MergeContext<'_>,
    builder: &mut FunctionBuilder,
) {
    let then_value = inputs.then_environment.values.get(&local_id).copied();
    let else_value = inputs.else_environment.values.get(&local_id).copied();

    if let (Some(left), Some(right)) = (then_value, else_value) {
        if left == right {
            context.join_environment.bind_value(local_id, left);
        } else {
            create_join_parameter(local_id, (left, right), context, builder);
        }
    }
    if inputs.then_environment.is_assigned(local_id)
        && inputs.else_environment.is_assigned(local_id)
    {
        context.join_environment.mark_assigned(local_id);
    }
}

fn create_join_parameter(
    local_id: LocalId,
    values: (ValueId, ValueId),
    context: &mut MergeContext<'_>,
    builder: &mut FunctionBuilder,
) {
    let (left, right) = values;
    let parameter_value = builder.next_value();
    let parameter_type = get_local_ir_type(local_id, context.module);
    builder.add_block_parameter(context.join_block, parameter_value, parameter_type);
    let local_name = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.module.locals.get(local_index))
        .map(|local| local.name.clone())
        .unwrap_or_else(|| format!("v{}", local_id.0));
    context.origins.push(OriginEntry {
        visibility: None,
        function: builder.name.clone(),
        value: parameter_value,
        variable: VariableId(local_id.0),
        name: local_name,
    });
    context.jump_arguments.then_arguments.push(left);
    context.jump_arguments.else_arguments.push(right);
    context
        .join_environment
        .bind_value(local_id, parameter_value);
}

fn emit_join_jump(
    builder: &mut FunctionBuilder,
    source_block: BlockId,
    join_block: BlockId,
    arguments: Vec<ValueId>,
) {
    builder.set_current_block(source_block);
    if !is_current_block_terminated(builder) {
        let target = Operand::BlockTarget {
            target_block: join_block,
            arguments,
        };
        builder.emit_void(Operation::Jump, vec![target], None);
    }
}

pub fn get_local_ir_type(local_id: LocalId, module: &HirModule) -> pseudolearn_ir::IrType {
    usize::try_from(local_id.0)
        .ok()
        .and_then(|index| module.locals.get(index))
        .map(|local| lower_type(local.type_id, module))
        .unwrap_or(pseudolearn_ir::IrType::Unit)
}
