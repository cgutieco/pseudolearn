use crate::cells::store_word;
use crate::context::AotRuntimeContext;
use crate::guard::{borrow_slice, run_entry};
use crate::trap::Trap;
use pseudolearn_runtime::Handle;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_snapshot_copy(
    context: *mut AotRuntimeContext,
    site: u32,
    count: u32,
    buffer: *const u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let count = usize::try_from(count).map_err(|_| internal())?;
        let words = borrow_slice(buffer, count.saturating_mul(2)).ok_or_else(internal)?;
        let (sources, cells) = words.split_at_checked(count).ok_or_else(internal)?;
        let handles = sources
            .iter()
            .map(|word| u32::try_from(*word).map(Handle).map_err(|_| internal()))
            .collect::<Result<Vec<_>, _>>()?;
        let roots = entry.roots()?;
        let copied =
            pseudolearn_runtime::snapshot_copy_many(&mut entry.engine.heap, &handles, &roots)?;
        for (cell, handle) in cells.iter().zip(copied) {
            let cell = u32::try_from(*cell).map_err(|_| internal())?;
            store_word(entry, cell, u64::from(handle.0))?;
        }
        Ok(0)
    })
}

fn internal() -> Trap {
    Trap::named("internalFault")
}
