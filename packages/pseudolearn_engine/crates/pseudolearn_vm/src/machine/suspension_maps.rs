use super::LoadedFunction;
use super::task_spill::SpilledFrame;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::Handle;

type LiveMaps<'map> = (&'map [u16], &'map [(u16, bool)]);

pub(super) fn plan(
    function: &LoadedFunction,
    (position, function_index): (usize, usize),
    bases: (usize, usize),
    probed: bool,
) -> Result<SpilledFrame, Fault> {
    let (scalar_map, reference_map) = maps(function, position, probed)?;
    let absolute =
        |base: usize, slot: u16| base.checked_add(usize::from(slot)).ok_or(INVALID_BYTECODE);
    Ok(SpilledFrame {
        handle: Handle(0),
        function: function_index,
        position,
        bases,
        capacity: function.continuation_capacity,
        scalars: scalar_map
            .iter()
            .map(|slot| absolute(bases.0, *slot))
            .collect::<Result<_, _>>()?,
        references: reference_map
            .iter()
            .filter(|(_, cell)| !*cell)
            .map(|(slot, _)| absolute(bases.1, *slot))
            .collect::<Result<_, _>>()?,
        cells: reference_map
            .iter()
            .filter(|(_, cell)| *cell)
            .map(|(slot, _)| absolute(bases.1, *slot))
            .collect::<Result<_, _>>()?,
    })
}

fn maps(function: &LoadedFunction, position: usize, probed: bool) -> Result<LiveMaps<'_>, Fault> {
    let live = if probed {
        &function.probed_scalar_live
    } else {
        &function.scalar_live
    };
    let scalar_map = live.get(position).ok_or(INVALID_BYTECODE)?;
    let maps = if probed {
        &function.probed_roots
    } else {
        &function.roots
    };
    let live = if probed {
        &function.probed_reference_live
    } else {
        &function.reference_live
    };
    let reference_map = maps
        .get(&position)
        .or_else(|| live.get(position))
        .ok_or(INVALID_BYTECODE)?;
    Ok((scalar_map, reference_map))
}

pub(super) fn merge_plans(plans: Vec<SpilledFrame>) -> Vec<SpilledFrame> {
    let mut merged: Vec<SpilledFrame> = Vec::new();
    for plan in plans {
        if let Some(frame) = merged
            .iter_mut()
            .find(|frame| frame.function == plan.function && frame.bases == plan.bases)
        {
            frame.position = plan.position;
            frame.scalars.extend(plan.scalars);
            frame.references.extend(plan.references);
            frame.cells.extend(plan.cells);
            frame.scalars.sort_unstable();
            frame.scalars.dedup();
            frame.references.sort_unstable();
            frame.references.dedup();
            frame.cells.sort_unstable();
            frame.cells.dedup();
        } else {
            merged.push(plan);
        }
    }
    merged.sort_by_key(|frame| frame.bases);
    merged
}
