use crate::access::array_rank;
use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::kinds::kind_from_code;
use crate::trap::Trap;
use pseudolearn_abi::Handle;
use pseudolearn_runtime::{
    MemoryCell, ValueKind, element_cell, field_cell, read_memory_cell, write_memory_cell,
};

#[derive(Clone, Copy, Debug)]
pub(crate) enum CellTarget {
    Local {
        kind: ValueKind,
        word: u64,
        defined: bool,
    },
    Managed(MemoryCell),
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_local(context: *mut AotRuntimeContext, site: u32, kind: u32) -> u32 {
    run_entry(context, site, |entry| {
        let kind = kind_from_code(kind)?;
        publish(
            entry,
            CellTarget::Local {
                kind,
                word: kind.absent(),
                defined: false,
            },
        )
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_element(
    context: *mut AotRuntimeContext,
    site: u32,
    array: u32,
    indices: *const i64,
) -> u32 {
    run_entry(context, site, |entry| {
        let rank = array_rank(entry, array)?;
        let indices = borrow_slice(indices, rank).ok_or_else(|| Trap::named("internalFault"))?;
        let cell = element_cell(&entry.engine.heap, Handle(array), indices)?;
        publish(entry, CellTarget::Managed(cell))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_field(
    context: *mut AotRuntimeContext,
    site: u32,
    object: u32,
    field: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let index = usize::try_from(field).map_err(|_| Trap::named("internalFault"))?;
        let cell = field_cell(&entry.engine.heap, Handle(object), index)?;
        publish(entry, CellTarget::Managed(cell))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_load(context: *mut AotRuntimeContext, site: u32, cell: u32) -> u32 {
    run_entry(context, site, |entry| match target(entry, cell)? {
        CellTarget::Managed(managed) => Ok(read_memory_cell(&entry.engine.heap, managed)?),
        CellTarget::Local {
            kind,
            word,
            defined,
        } => local_value(kind, word, defined),
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_store(
    context: *mut AotRuntimeContext,
    site: u32,
    cell: u32,
    word: u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let slot = slot_of(cell)?;
        match target(entry, cell)? {
            CellTarget::Managed(managed) => {
                write_memory_cell(&mut entry.engine.heap, managed, word)?;
            }
            CellTarget::Local { kind, .. } => {
                let stored = CellTarget::Local {
                    kind,
                    word,
                    defined: true,
                };
                *entry
                    .engine
                    .cells
                    .get_mut(slot)
                    .ok_or_else(|| Trap::named("internalFault"))? = stored;
            }
        }
        Ok(0)
    })
}

fn publish(entry: &mut Entry<'_>, target: CellTarget) -> Result<u64, Trap> {
    entry
        .engine
        .cells
        .try_reserve(1)
        .map_err(|_| Trap::named("internalFault"))?;
    entry.engine.cells.push(target);
    u64::try_from(entry.engine.cells.len()).map_err(|_| Trap::named("internalFault"))
}

fn slot_of(cell: u32) -> Result<usize, Trap> {
    cell.checked_sub(1)
        .and_then(|index| usize::try_from(index).ok())
        .ok_or_else(|| Trap::named("internalFault"))
}

fn target(entry: &Entry<'_>, cell: u32) -> Result<CellTarget, Trap> {
    entry
        .engine
        .cells
        .get(slot_of(cell)?)
        .copied()
        .ok_or_else(|| Trap::named("internalFault"))
}

fn local_value(kind: ValueKind, word: u64, defined: bool) -> Result<u64, Trap> {
    let present = match kind {
        ValueKind::Integer => defined,
        ValueKind::Real => !f64::from_bits(word).is_nan(),
        _ => word != kind.absent(),
    };
    if present {
        Ok(word)
    } else {
        Err(Trap::named("uninitializedVariableRead"))
    }
}

pub(crate) fn rooted_handles(cells: &[CellTarget]) -> impl Iterator<Item = Handle> + '_ {
    cells
        .iter()
        .filter_map(|cell| match cell {
            CellTarget::Local {
                kind: ValueKind::Reference,
                word,
                ..
            } => u32::try_from(*word).ok().filter(|handle| *handle != 0),
            _ => None,
        })
        .map(Handle)
}
