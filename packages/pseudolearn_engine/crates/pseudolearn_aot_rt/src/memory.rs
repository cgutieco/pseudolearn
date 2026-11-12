use crate::context::AotRuntimeContext;
use crate::format::handle_of;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::kinds::{RANK_SHIFT, kind_code, kind_from_code};
use crate::trap::Trap;
use pseudolearn_runtime::{
    copy_object, new_array, new_object_shared, object_allocation_cells, object_layout_cells,
};

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_array_new(
    context: *mut AotRuntimeContext,
    site: u32,
    descriptor: u32,
    dimensions: *const i64,
) -> u32 {
    let rank = usize::try_from(descriptor.wrapping_shr(RANK_SHIFT)).unwrap_or(0);
    let extents = borrow_slice(dimensions, rank);
    run_entry(context, site, |entry| array_new(entry, descriptor, extents))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_object_new(context: *mut AotRuntimeContext, site: u32, class: u32) -> u32 {
    run_entry(context, site, |entry| object_new(entry, class))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_object_copy(
    context: *mut AotRuntimeContext,
    site: u32,
    source: u32,
) -> u32 {
    run_entry(context, site, |entry| object_copy(entry, source))
}

fn array_new(entry: &mut Entry<'_>, descriptor: u32, extents: Option<&[i64]>) -> Result<u64, Trap> {
    let extents = extents.ok_or_else(|| Trap::named("internalFault"))?;
    let kind = kind_from_code(kind_code(descriptor))?;
    if let Some(size) = extents.iter().find(|size| **size < 0) {
        return Err(Trap::named("negativeArraySize").argument("size", size));
    }
    let cells = extents
        .iter()
        .try_fold(1_u64, |total, extent| {
            u64::try_from(*extent)
                .ok()
                .and_then(|extent| total.checked_mul(extent))
        })
        .and_then(|total| total.checked_add(1))
        .ok_or_else(|| Trap::named("resourceLimit"))?;
    let roots = entry.allocation_roots(cells)?;
    let handle = new_array(&mut entry.engine.heap, kind, extents, &roots)?;
    Ok(u64::from(handle.0))
}

fn object_new(entry: &mut Entry<'_>, class: u32) -> Result<u64, Trap> {
    let layout = usize::try_from(class)
        .ok()
        .and_then(|index| entry.engine.layouts.get(index))
        .and_then(Option::clone)
        .ok_or_else(|| Trap::named("internalFault"))?;
    let roots = entry.allocation_roots(object_layout_cells(&layout)?)?;
    let handle = new_object_shared(&mut entry.engine.heap, layout, &roots)?;
    Ok(u64::from(handle.0))
}

fn object_copy(entry: &mut Entry<'_>, source: u32) -> Result<u64, Trap> {
    let roots = entry.allocation_roots(object_allocation_cells(
        &entry.engine.heap,
        handle_of(u64::from(source))?,
    )?)?;
    let handle = copy_object(
        &mut entry.engine.heap,
        handle_of(u64::from(source))?,
        &roots,
    )?;
    Ok(u64::from(handle.0))
}
