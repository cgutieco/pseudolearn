use crate::{
    BytecodeError, BytecodeFunction, BytecodeOperand, CodeVariant, Instruction, Register,
    RegisterClass, VerificationRule,
};
use std::collections::BTreeSet;

pub(crate) fn verify(
    function: &BytecodeFunction,
    variant: &CodeVariant,
) -> Result<(), BytecodeError> {
    for (position, instruction) in variant.instructions.iter().enumerate() {
        let position = u32::try_from(position).map_err(|_| BytecodeError::InvalidModule)?;
        if safe_point(instruction)
            && (!variant.roots.contains_key(&position)
                || !variant.definitions.contains_key(&position))
        {
            return Err(BytecodeError::Verification(VerificationRule::RootMap));
        }
    }
    verify_definitions(function, variant)?;
    for (position, roots) in &variant.roots {
        let instruction = usize::try_from(*position)
            .ok()
            .and_then(|position| variant.instructions.get(position));
        if !instruction.is_some_and(safe_point) {
            return Err(BytecodeError::Verification(VerificationRule::RootMap));
        }
        let mut seen = BTreeSet::new();
        for root in roots {
            if root.class != RegisterClass::Reference
                || function.register_type(*root).is_none()
                || !seen.insert(root.index)
            {
                return Err(BytecodeError::Verification(VerificationRule::RootMap));
            }
        }
    }
    Ok(())
}

pub(crate) fn safe_point(instruction: &Instruction) -> bool {
    matches!(
        instruction.opcode.as_name(),
        "call"
            | "call.virtual"
            | "call.indirect"
            | "array.new"
            | "object.new"
            | "object.copy"
            | "text.concat"
            | "text.format"
            | "text.quote"
            | "collection.new"
            | "collection.store"
            | "collection.insert"
            | "collection.remove"
            | "in.read"
    )
}

pub(crate) fn generate(
    variant: &mut CodeVariant,
    origins: &[Register],
) -> Result<(), BytecodeError> {
    let live = crate::root_liveness::analyze(variant)?;
    let origin_slots = origins
        .iter()
        .filter(|register| register.class == RegisterClass::Reference)
        .map(|register| register.index)
        .collect::<BTreeSet<_>>();
    for (position, instruction) in variant.instructions.iter().take(live.len()).enumerate() {
        if safe_point(instruction) {
            let roots = live
                .get(position)
                .ok_or(BytecodeError::InvalidModule)?
                .union(&origin_slots)
                .map(|index| Register {
                    class: RegisterClass::Reference,
                    index: *index,
                })
                .collect();
            variant.roots.insert(
                u32::try_from(position).map_err(|_| BytecodeError::InvalidModule)?,
                roots,
            );
        }
    }
    Ok(())
}

fn verify_definitions(
    function: &BytecodeFunction,
    variant: &CodeVariant,
) -> Result<(), BytecodeError> {
    for (position, states) in &variant.definitions {
        if *position >= variant.used_length
            || states
                .keys()
                .any(|register| function.register_type(*register).is_none())
        {
            return Err(BytecodeError::Verification(VerificationRule::RootMap));
        }
        let instruction = usize::try_from(*position)
            .ok()
            .and_then(|position| variant.instructions.get(position))
            .ok_or(BytecodeError::InvalidModule)?;
        for operand in &instruction.operands {
            let registers = match operand {
                BytecodeOperand::Register(register) => std::slice::from_ref(register),
                BytecodeOperand::FunctionTarget { arguments, .. }
                | BytecodeOperand::BlockTarget { arguments, .. } => arguments,
                _ => &[],
            };
            if registers
                .iter()
                .any(|register| !states.contains_key(register))
            {
                return Err(BytecodeError::Verification(VerificationRule::RootMap));
            }
        }
    }
    Ok(())
}

pub(crate) fn expire(
    variant: &mut CodeVariant,
    visibility: &std::collections::BTreeMap<Register, pseudolearn_ir::IrSpan>,
) -> Result<(), BytecodeError> {
    let live = crate::root_liveness::analyze(variant)?;
    for (position, roots) in &mut variant.roots {
        let position = usize::try_from(*position).map_err(|_| BytecodeError::InvalidModule)?;
        let span = variant
            .instructions
            .get(position)
            .and_then(|instruction| instruction.span);
        roots.retain(|register| {
            visibility.get(register).is_none_or(|scope| {
                span.is_some_and(|span| scope.contains_start(span))
                    || live
                        .get(position)
                        .is_some_and(|live| live.contains(&register.index))
            })
        });
    }
    Ok(())
}
