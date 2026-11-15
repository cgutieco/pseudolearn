use super::{DecodeContext, LoadedFunction, invalid_bytecode};
use crate::{
    VmTrap,
    dispatch::{Op, TaskOp},
};
use pseudolearn_bytecode::{BytecodeOperand, Instruction, Opcode, Register, ValueType};
use pseudolearn_runtime::VectorLayout;

#[derive(Clone, Debug, PartialEq)]
pub(crate) enum TaskSite {
    Outcome {
        failure: bool,
        values: Vec<Register>,
    },
    ScopeResult {
        scope: Register,
        destination: Register,
        layout: VectorLayout,
    },
    CancelPoint {
        edge: u32,
    },
    ScopeBoundary {
        scope: Register,
        edge: u32,
    },
}

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    location: (u32, bool),
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let (site, operation) = match instruction.opcode {
        Opcode::TaskOutcome => (outcome(instruction)?, 0),
        Opcode::TaskScopeResult => (scope_result(context, instruction)?, 1),
        Opcode::TaskCancelPoint => {
            let edge = super::super::edges::add_edge(
                context,
                loaded,
                location,
                instruction.operands.first(),
            )?;
            (TaskSite::CancelPoint { edge }, 2)
        }
        Opcode::TaskScopeBoundary => {
            let scope = super::super::operands::first_register(instruction)?;
            let edge = super::super::edges::add_edge(
                context,
                loaded,
                location,
                instruction.operands.get(1),
            )?;
            (TaskSite::ScopeBoundary { scope, edge }, 3)
        }
        _ => return Err(invalid_bytecode()),
    };
    let index = u32::try_from(loaded.task_sites.len()).map_err(|_| invalid_bytecode())?;
    loaded.task_sites.push(site);
    match operation {
        0 => Ok(Op::Task(TaskOp::Outcome { site: index })),
        1 => Ok(Op::Task(TaskOp::ScopeResult { site: index })),
        2 => Ok(Op::Task(TaskOp::CancelPoint { site: index })),
        _ => Ok(Op::Task(TaskOp::ScopeBoundary { site: index })),
    }
}

fn outcome(instruction: &Instruction) -> Result<TaskSite, VmTrap> {
    let [BytecodeOperand::Identifier(status), values @ ..] = instruction.operands.as_slice() else {
        return Err(invalid_bytecode());
    };
    let values = values
        .iter()
        .map(|value| match value {
            BytecodeOperand::Register(register) => Ok(*register),
            _ => Err(invalid_bytecode()),
        })
        .collect::<Result<Vec<_>, _>>()?;
    Ok(TaskSite::Outcome {
        failure: status == "error",
        values,
    })
}

fn scope_result(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
) -> Result<TaskSite, VmTrap> {
    let [
        BytecodeOperand::Register(scope),
        BytecodeOperand::Type(ValueType::Object(name)),
    ] = instruction.operands.as_slice()
    else {
        return Err(invalid_bytecode());
    };
    let layout = vector_layout(context, name)?;
    Ok(TaskSite::ScopeResult {
        scope: *scope,
        destination: instruction.destination.ok_or_else(invalid_bytecode)?,
        layout,
    })
}

fn vector_layout(context: &DecodeContext<'_>, name: &str) -> Result<VectorLayout, VmTrap> {
    let (index, class) = context
        .module
        .classes
        .iter()
        .enumerate()
        .find(|(_, class)| class.name == name)
        .ok_or_else(invalid_bytecode)?;
    let descriptor = pseudolearn_bytecode::collection_metadata::collection_fields(
        name,
        class
            .fields
            .iter()
            .map(|(name, kind)| (name.as_str(), kind)),
    )
    .ok_or_else(invalid_bytecode)?;
    let references = descriptor
        .leaves
        .iter()
        .filter(|kind| {
            super::super::memory::value_kind(kind) == pseudolearn_runtime::ValueKind::Reference
        })
        .count();
    Ok(VectorLayout {
        scalar_words: u32::try_from(descriptor.leaves.len().saturating_sub(references))
            .map_err(|_| invalid_bytecode())?,
        reference_words: u32::try_from(references).map_err(|_| invalid_bytecode())?,
        type_identity: u32::try_from(index).map_err(|_| invalid_bytecode())?,
    })
}
