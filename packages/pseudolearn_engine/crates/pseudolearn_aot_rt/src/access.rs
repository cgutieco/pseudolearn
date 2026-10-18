use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::trap::Trap;
use pseudolearn_abi::Handle;
use pseudolearn_runtime::{array_dimensions, read_element, read_field, write_element, write_field};

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_array_load(
    context: *mut AotRuntimeContext,
    site: u32,
    array: u32,
    indices: *const i64,
) -> u32 {
    run_entry(context, site, |entry| array_load(entry, array, indices))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_array_store(
    context: *mut AotRuntimeContext,
    site: u32,
    array: u32,
    operands: *const i64,
) -> u32 {
    run_entry(context, site, |entry| array_store(entry, array, operands))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_object_load(
    context: *mut AotRuntimeContext,
    site: u32,
    object: u32,
    field: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let index = usize::try_from(field).map_err(|_| Trap::named("internalFault"))?;
        Ok(read_field(&entry.engine.heap, Handle(object), index)?)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_object_store(
    context: *mut AotRuntimeContext,
    site: u32,
    object: u32,
    operands: *const u64,
) -> u32 {
    run_entry(context, site, |entry| object_store(entry, object, operands))
}

pub(crate) fn array_rank(entry: &Entry<'_>, array: u32) -> Result<usize, Trap> {
    if array == 0 {
        return Err(Trap::named("uninitializedVariableRead"));
    }
    Ok(array_dimensions(&entry.engine.heap, Handle(array))?.len())
}

fn array_load(entry: &mut Entry<'_>, array: u32, indices: *const i64) -> Result<u64, Trap> {
    let rank = array_rank(entry, array)?;
    let indices = borrow_slice(indices, rank).ok_or_else(|| Trap::named("internalFault"))?;
    read_element(&entry.engine.heap, Handle(array), indices)
        .map_err(|error| array_trap(entry, array, indices, error))
}

fn array_store(entry: &mut Entry<'_>, array: u32, operands: *const i64) -> Result<u64, Trap> {
    let rank = array_rank(entry, array)?;
    let count = rank
        .checked_add(1)
        .ok_or_else(|| Trap::named("internalFault"))?;
    let slice = borrow_slice(operands, count).ok_or_else(|| Trap::named("internalFault"))?;
    let (value, indices) = slice
        .split_last()
        .ok_or_else(|| Trap::named("internalFault"))?;
    let word = u64::from_ne_bytes(value.to_ne_bytes());
    write_element(&mut entry.engine.heap, Handle(array), (indices, word))
        .map_err(|error| array_trap(entry, array, indices, error))?;
    Ok(0)
}

fn object_store(entry: &mut Entry<'_>, object: u32, operands: *const u64) -> Result<u64, Trap> {
    let slice = borrow_slice(operands, 2).ok_or_else(|| Trap::named("internalFault"))?;
    let [field, value] = slice else {
        return Err(Trap::named("internalFault"));
    };
    let index = usize::try_from(*field).map_err(|_| Trap::named("internalFault"))?;
    write_field(&mut entry.engine.heap, Handle(object), (index, *value))?;
    Ok(0)
}

pub(crate) fn array_trap(
    entry: &Entry<'_>,
    array: u32,
    indices: &[i64],
    error: pseudolearn_runtime::MemoryError,
) -> Trap {
    let trap: Trap = error.into();
    if let Ok(dimensions) = array_dimensions(&entry.engine.heap, Handle(array)) {
        for (index, size) in indices.iter().zip(dimensions) {
            if u64::try_from(*index).is_err()
                || u64::try_from(*index).is_ok_and(|index| index >= *size)
            {
                return trap.argument("index", index).argument("size", size);
            }
        }
    }
    trap
}
