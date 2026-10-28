#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeOperand, Instruction, Opcode, Register, RegisterClass, ValueType,
};

use super::DecodeContext;
use crate::VmTrap;
use crate::dispatch::Op;
use crate::load::edges::add_edge;
use crate::load::operands::{first_register, scalar_source};
use crate::load::{CallSite, LoadedFunction, Move, Source, invalid_bytecode};

struct CallSiteDefinition {
    function: usize,
    return_point: usize,
    arguments_start: usize,
    targets_by_class: Vec<Option<u16>>,
}

pub(super) fn decode(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    (program_counter, probed): (u32, bool),
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    match instruction.opcode {
        Opcode::Jump => {
            let edge = add_edge(
                context,
                loaded,
                (program_counter, probed),
                instruction.operands.first(),
            )?;
            Ok(Op::Jump { edge })
        }
        Opcode::Branch => decode_branch(context, loaded, (program_counter, probed), instruction),
        Opcode::Switch => {
            super::switch::decode(context, loaded, (program_counter, probed), instruction)
        }
        Opcode::Call | Opcode::CallVirtual | Opcode::CallIndirect | Opcode::CallSuspendible => {
            decode_call(context, loaded, instruction)
        }
        Opcode::TaskScopeOpen
        | Opcode::TaskSpawn
        | Opcode::TaskAwait
        | Opcode::TaskScopeJoin
        | Opcode::TaskYieldCheck => super::task_control::decode(context, loaded, instruction),
        Opcode::Return => decode_return(instruction),
        Opcode::LoopCheckStep => decode_check_step(context, instruction),
        Opcode::TrapMissingReturn => Ok(Op::MissingReturn),
        Opcode::Unreachable => Ok(Op::Unreachable),
        _ => Ok(Op::Unsupported),
    }
}

fn decode_branch(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    (program_counter, probed): (u32, bool),
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let condition = first_register(instruction)?;
    if condition.class != RegisterClass::Scalar {
        return Err(invalid_bytecode());
    }
    let then_edge = add_edge(
        context,
        loaded,
        (program_counter, probed),
        instruction.operands.get(1),
    )?;
    let else_edge = add_edge(
        context,
        loaded,
        (program_counter, probed),
        instruction.operands.get(2),
    )?;
    Ok(Op::Branch {
        condition: condition.index,
        then_edge,
        else_edge,
    })
}

pub(super) fn decode_call(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let return_point = instruction.return_point.ok_or_else(invalid_bytecode)?;
    let return_point_index = usize::try_from(return_point).map_err(|_| invalid_bytecode())?;
    if let Some(existing_site) = existing_call_site(loaded, return_point_index)? {
        return Ok(existing_site);
    }
    let definition = call_site_definition(context, loaded, instruction, return_point_index)?;
    register_call_site(loaded, instruction, definition)
}

fn call_site_definition(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
    return_point: usize,
) -> Result<CallSiteDefinition, VmTrap> {
    let Some(BytecodeOperand::FunctionTarget {
        function_index,
        arguments,
    }) = instruction.operands.last()
    else {
        return Err(invalid_bytecode());
    };
    let callee = context
        .module
        .functions
        .get(usize::from(*function_index))
        .ok_or_else(invalid_bytecode)?;
    if callee.parameters.len() != arguments.len() {
        return Err(invalid_bytecode());
    }
    let arguments_start = loaded.moves.len();
    append_arguments(context, loaded, arguments, (callee, instruction))?;
    let function_index = usize::from(*function_index);
    let targets_by_class = if instruction.opcode == Opcode::CallVirtual {
        virtual_targets(context, function_index)?
    } else if instruction.opcode == Opcode::CallIndirect {
        crate::load::indirect_targets::collect(context.module, function_index)
    } else {
        Vec::new()
    };
    Ok(CallSiteDefinition {
        function: function_index,
        return_point,
        arguments_start,
        targets_by_class,
    })
}

fn existing_call_site(
    loaded: &LoadedFunction,
    return_point_index: usize,
) -> Result<Option<Op>, VmTrap> {
    if let Some(existing_index) = loaded
        .calls
        .iter()
        .position(|call| call.return_point == return_point_index)
    {
        let site = u32::try_from(existing_index).map_err(|_| invalid_bytecode())?;
        return Ok(Some(Op::Call { site }));
    }
    Ok(None)
}

fn register_call_site(
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
    definition: CallSiteDefinition,
) -> Result<Op, VmTrap> {
    let receiver = if instruction.opcode == Opcode::CallVirtual {
        Some(first_register(instruction)?.index)
    } else {
        None
    };
    let targets_start = loaded.virtual_targets.len();
    loaded.virtual_targets.extend(definition.targets_by_class);
    let targets_end = loaded.virtual_targets.len();
    let site = CallSite {
        indirect: if instruction.opcode == Opcode::CallIndirect {
            Some(first_register(instruction)?.index)
        } else {
            None
        },
        function: definition.function,
        destination: instruction.destination,
        return_point: definition.return_point,
        arguments_start: definition.arguments_start,
        arguments_end: loaded.moves.len(),
        receiver,
        targets_start,
        targets_end,
    };
    let index = u32::try_from(loaded.calls.len()).map_err(|_| invalid_bytecode())?;
    loaded.calls.push(site);
    Ok(Op::Call { site: index })
}

fn virtual_targets(
    context: &DecodeContext<'_>,
    function_index: usize,
) -> Result<Vec<Option<u16>>, VmTrap> {
    let function = context
        .module
        .functions
        .get(function_index)
        .ok_or_else(invalid_bytecode)?;
    let method = function
        .name
        .rsplit_once('.')
        .map(|(_, method)| method)
        .ok_or_else(invalid_bytecode)?;
    Ok(context
        .module
        .classes
        .iter()
        .map(|class| class.methods.get(method).copied())
        .collect())
}

fn append_arguments(
    context: &DecodeContext<'_>,
    loaded: &mut LoadedFunction,
    arguments: &[Register],
    (callee, instruction): (&BytecodeFunction, &Instruction),
) -> Result<(), VmTrap> {
    for (source, destination) in arguments.iter().zip(&callee.parameters) {
        if source.class != destination.class {
            return Err(invalid_bytecode());
        }
        let integer = callee.register_type(*destination) == Some(&ValueType::I64);
        loaded.moves.push(Move {
            source: source.index,
            destination: destination.index,
            class: source.class,
            definition: crate::load::definitions::source_definition(
                context,
                (instruction, *source),
                integer,
            ),
        });
    }
    Ok(())
}

fn decode_return(instruction: &Instruction) -> Result<Op, VmTrap> {
    match instruction.operands.first() {
        None => Ok(Op::ReturnUnit),
        Some(BytecodeOperand::Register(register)) => Ok(match register.class {
            RegisterClass::Scalar => Op::ReturnScalar {
                source: register.index,
            },
            RegisterClass::Reference => Op::ReturnReference {
                source: register.index,
            },
        }),
        Some(_) => Err(invalid_bytecode()),
    }
}

fn decode_check_step(context: &DecodeContext<'_>, instruction: &Instruction) -> Result<Op, VmTrap> {
    let operand = instruction.operands.first().ok_or_else(invalid_bytecode)?;
    match scalar_source(context.function, operand) {
        Some(Source::Register(source)) => Ok(Op::CheckStepRegister { source }),
        Some(Source::Immediate(word)) => Ok(Op::CheckStepImmediate { word }),
        None => Err(invalid_bytecode()),
    }
}
