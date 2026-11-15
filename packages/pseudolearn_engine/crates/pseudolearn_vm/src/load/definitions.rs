use super::{Definition, definedness::StaticState, instructions::DecodeContext};
use pseudolearn_bytecode::{DefinitionState, Instruction, Register};

pub(super) fn source_state(
    context: &DecodeContext<'_>,
    instruction: &Instruction,
    register: Register,
) -> StaticState {
    let state = [&context.function.fast, &context.function.probed]
        .into_iter()
        .find_map(|variant| {
            let position = variant
                .instructions
                .iter()
                .position(|candidate| std::ptr::eq(candidate, instruction))?;
            variant
                .definitions
                .get(&u32::try_from(position).ok()?)?
                .get(&register)
        });
    match state {
        Some(DefinitionState::Defined) => StaticState::Defined,
        Some(DefinitionState::Undefined) => StaticState::Undefined,
        Some(DefinitionState::Dynamic) => StaticState::Dynamic,
        None => context.definedness.state(register),
    }
}

pub(super) fn source_definition(
    context: &DecodeContext<'_>,
    (instruction, source): (&Instruction, Register),
    tracked: bool,
) -> Definition {
    if !tracked {
        return Definition::Untracked;
    }
    match source_state(context, instruction, source) {
        StaticState::Defined => Definition::Defined,
        StaticState::Undefined => Definition::Undefined,
        StaticState::Dynamic => Definition::Copied,
    }
}
