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
    probed: bool,
) -> Result<BTreeMap<usize, Vec<(u16, bool)>>, VmTrap> {
    let variant = if probed {
        &function.probed
    } else {
        &function.fast
    };
    variant
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

pub(super) fn scalar_live(
    variant: &pseudolearn_bytecode::CodeVariant,
) -> Result<Vec<Vec<u16>>, VmTrap> {
    pseudolearn_bytecode::root_liveness::analyze_slots(
        variant,
        pseudolearn_bytecode::RegisterClass::Scalar,
    )
    .map(|maps| {
        maps.into_iter()
            .map(|map| map.into_iter().collect())
            .collect()
    })
    .map_err(|_| invalid_bytecode())
}

pub(super) fn reference_live(
    function: &BytecodeFunction,
    probed: bool,
) -> Result<Vec<Vec<(u16, bool)>>, VmTrap> {
    let variant = if probed {
        &function.probed
    } else {
        &function.fast
    };
    pseudolearn_bytecode::root_liveness::analyze_slots(
        variant,
        pseudolearn_bytecode::RegisterClass::Reference,
    )
    .map(|maps| {
        maps.into_iter()
            .map(|map| {
                map.into_iter()
                    .map(|index| {
                        let register = pseudolearn_bytecode::Register {
                            class: pseudolearn_bytecode::RegisterClass::Reference,
                            index,
                        };
                        (
                            index,
                            matches!(function.register_type(register), Some(ValueType::Cell(_))),
                        )
                    })
                    .collect()
            })
            .collect()
    })
    .map_err(|_| invalid_bytecode())
}

type LivePoint<'map> = (&'map Vec<u16>, Option<&'map Vec<(u16, bool)>>);

pub(super) fn continuation_capacity(function: &super::LoadedFunction) -> (usize, usize) {
    let cleanup = cleanup_slots(function);
    let fast = live_points(
        &function.scalar_live,
        &function.roots,
        &function.reference_live,
    );
    let probed = live_points(
        &function.probed_scalar_live,
        &function.probed_roots,
        &function.probed_reference_live,
    );
    fast.chain(probed)
        .fold((0_usize, 0_usize), |maximum, point| {
            let (scalars, references) = point_size(point, &cleanup);
            (maximum.0.max(scalars), maximum.1.max(references))
        })
}

fn live_points<'map>(
    scalar_live: &'map [Vec<u16>],
    roots: &'map std::collections::BTreeMap<usize, Vec<(u16, bool)>>,
    reference_live: &'map [Vec<(u16, bool)>],
) -> impl Iterator<Item = LivePoint<'map>> {
    scalar_live
        .iter()
        .enumerate()
        .map(move |(position, scalar)| {
            (
                scalar,
                roots
                    .get(&position)
                    .or_else(|| reference_live.get(position)),
            )
        })
}

fn point_size(
    (scalars, references): LivePoint<'_>,
    (cleanup_scalars, cleanup_references): &(BTreeSet<u16>, BTreeSet<(u16, bool)>),
) -> (usize, usize) {
    let scalars: BTreeSet<_> = scalars.iter().chain(cleanup_scalars).copied().collect();
    let references: BTreeSet<_> = references
        .into_iter()
        .flatten()
        .chain(cleanup_references)
        .copied()
        .collect();
    let cells = references.iter().filter(|(_, cell)| *cell).count();
    (
        scalars.len().saturating_add(cells.saturating_mul(2)),
        references.len(),
    )
}

fn cleanup_slots(function: &super::LoadedFunction) -> (BTreeSet<u16>, BTreeSet<(u16, bool)>) {
    let mut scalars = BTreeSet::new();
    let mut references = BTreeSet::new();
    for site in &function.task_sites {
        let edge = match site {
            super::TaskSite::CancelPoint { edge } | super::TaskSite::ScopeBoundary { edge, .. } => {
                *edge
            }
            _ => continue,
        };
        let Some(target) = usize::try_from(edge)
            .ok()
            .and_then(|index| function.edges.get(index))
            .map(|edge| edge.target)
        else {
            continue;
        };
        for maps in [&function.scalar_live, &function.probed_scalar_live] {
            scalars.extend(maps.get(target).into_iter().flatten());
        }
        for maps in [&function.reference_live, &function.probed_reference_live] {
            references.extend(maps.get(target).into_iter().flatten());
        }
    }
    (scalars, references)
}
