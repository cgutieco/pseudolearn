use crate::access::array_rank;
use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::kinds::kind_from_code;
use crate::trap::Trap;
use pseudolearn_abi::Handle;
use pseudolearn_runtime::{
    MemoryCell, ValueKind, element_cell, field_cell, read_memory_cell, write_memory_cell,
};
use std::mem::offset_of;

#[derive(Clone, Copy, Debug)]
pub(crate) enum CellTarget {
    Local {
        kind: ValueKind,
        word: u64,
        defined: bool,
        origin_site: u32,
    },
    Managed {
        cell: MemoryCell,
        origin_site: u32,
    },
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub(crate) struct CellSlot {
    word: u64,
    readable: u64,
    target: CellTarget,
}

pub const CELL_SLOT_BYTES: usize = size_of::<CellSlot>();
pub const CELL_SLOT_WORD_OFFSET: usize = offset_of!(CellSlot, word);
pub const CELL_SLOT_READABLE_OFFSET: usize = offset_of!(CellSlot, readable);

impl CellSlot {
    fn new(target: CellTarget) -> Self {
        match target {
            CellTarget::Local {
                kind,
                word,
                defined,
                ..
            } if local_value(kind, word, defined).is_ok() => Self {
                word,
                readable: 1,
                target,
            },
            _ => Self {
                word: 0,
                readable: 0,
                target,
            },
        }
    }
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
                origin_site: site,
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
        let cell = element_cell(&entry.engine.heap, Handle(array), indices)
            .map_err(|error| crate::access::array_trap(entry, array, indices, error))?;
        publish(
            entry,
            CellTarget::Managed {
                cell,
                origin_site: site,
            },
        )
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
        publish(
            entry,
            CellTarget::Managed {
                cell,
                origin_site: site,
            },
        )
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_load(context: *mut AotRuntimeContext, site: u32, cell: u32) -> u32 {
    run_entry(context, site, |entry| {
        #[cfg(feature = "telemetry")]
        entry
            .engine
            .record(|statistics| statistics.cell_loads = statistics.cell_loads.saturating_add(1));
        match target(entry, cell)? {
            CellTarget::Managed { cell, origin_site } => read_memory_cell(&entry.engine.heap, cell)
                .map_err(|error| named_cell_trap(entry, origin_site, error.into())),
            CellTarget::Local {
                kind,
                word,
                defined,
                origin_site,
            } => local_value(kind, word, defined)
                .map_err(|trap| named_cell_trap(entry, origin_site, trap)),
        }
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
        #[cfg(feature = "telemetry")]
        entry
            .engine
            .record(|statistics| statistics.cell_stores = statistics.cell_stores.saturating_add(1));
        let slot = slot_of(cell)?;
        match target(entry, cell)? {
            CellTarget::Managed { cell, .. } => {
                write_memory_cell(&mut entry.engine.heap, cell, word)?;
            }
            CellTarget::Local {
                kind, origin_site, ..
            } => {
                let stored = CellTarget::Local {
                    kind,
                    word,
                    defined: true,
                    origin_site,
                };
                *entry
                    .engine
                    .cells
                    .get_mut(slot)
                    .ok_or_else(|| Trap::named("internalFault"))? = CellSlot::new(stored);
            }
        }
        Ok(0)
    })
}

fn publish(entry: &mut Entry<'_>, target: CellTarget) -> Result<u64, Trap> {
    #[cfg(feature = "telemetry")]
    entry
        .engine
        .record(|statistics| statistics.cells_created = statistics.cells_created.saturating_add(1));
    entry
        .engine
        .cells
        .try_reserve(1)
        .map_err(|_| Trap::named("internalFault"))?;
    entry.engine.cells.push(CellSlot::new(target));
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
        .map(|slot| slot.target)
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

pub(crate) fn rooted_handles(cells: &[CellSlot]) -> impl Iterator<Item = Handle> + '_ {
    cells
        .iter()
        .filter_map(|slot| match &slot.target {
            CellTarget::Local {
                kind: ValueKind::Reference,
                word,
                ..
            } => u32::try_from(*word).ok().filter(|handle| *handle != 0),
            CellTarget::Managed { cell, .. } => Some(cell.owner.0).filter(|handle| *handle != 0),
            _ => None,
        })
        .map(Handle)
}

fn named_cell_trap(entry: &Entry<'_>, site: u32, trap: Trap) -> Trap {
    if trap.code.map(|code| code.as_str()) == Some("uninitializedVariableRead")
        && let Some(lexeme) = entry.engine.site_lexeme(site)
    {
        trap.argument("lexeme", lexeme)
    } else {
        trap
    }
}
