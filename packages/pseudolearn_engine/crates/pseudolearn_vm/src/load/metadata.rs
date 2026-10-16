use super::{invalid_bytecode, memory};
use crate::VmTrap;
use pseudolearn_bytecode::{BytecodeFunction, BytecodeModule, Constant, ValueType};
use pseudolearn_runtime::ObjectLayout;
use std::collections::{BTreeMap, BTreeSet};
use std::sync::Arc;

pub(super) fn literals(module: &BytecodeModule) -> Vec<String> {
    module
        .functions
        .iter()
        .flat_map(|function| &function.constants)
        .filter_map(|constant| {
            if let Constant::Str(text) = constant {
                Some(text.clone())
            } else {
                None
            }
        })
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect()
}

pub(super) fn layouts(module: &BytecodeModule) -> Result<Vec<Arc<ObjectLayout>>, VmTrap> {
    module
        .classes
        .iter()
        .enumerate()
        .map(|(index, class)| {
            Ok(Arc::new(ObjectLayout {
                class: u32::try_from(index).map_err(|_| invalid_bytecode())?,
                fields: class
                    .fields
                    .iter()
                    .map(|(_, kind)| memory::value_kind(kind))
                    .collect(),
                dense: class.dense_integers,
                references: class
                    .references
                    .iter()
                    .map(|offset| usize::try_from(*offset).map_err(|_| invalid_bytecode()))
                    .collect::<Result<_, _>>()?,
            }))
        })
        .collect()
}

pub(super) fn roots(
    function: &BytecodeFunction,
) -> Result<BTreeMap<usize, Vec<(u16, bool)>>, VmTrap> {
    function
        .fast
        .roots
        .iter()
        .map(|(position, roots)| {
            Ok((
                usize::try_from(*position).map_err(|_| invalid_bytecode())?,
                roots
                    .iter()
                    .map(|register| {
                        (
                            register.index,
                            matches!(function.register_type(*register), Some(ValueType::Cell(_))),
                        )
                    })
                    .collect(),
            ))
        })
        .collect()
}

pub(super) fn spans(
    function: &BytecodeFunction,
    probed: bool,
) -> Vec<Option<pseudolearn_bytecode::SourceSpan>> {
    let variant = if probed {
        &function.probed
    } else {
        &function.fast
    };
    variant
        .instructions
        .iter()
        .map(|instruction| instruction.span)
        .collect()
}

pub(super) fn entry_mass(function: &BytecodeFunction) -> u64 {
    function
        .fast
        .blocks
        .first()
        .map_or(0, |block| u64::from(block.mass))
}
